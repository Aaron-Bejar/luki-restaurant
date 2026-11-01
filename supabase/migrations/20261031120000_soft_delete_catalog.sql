-- Baja lógica: no altera detalles ni sus referencias históricas.
alter table public.categoria drop constraint categoria_siempre_activa_check;
alter table public.carta add column eliminado boolean not null default false;
alter table public.carta drop constraint carta_categoria_id_fkey;
alter table public.carta add constraint carta_categoria_id_fkey foreign key (categoria_id) references public.categoria(id) on delete restrict;
alter table public.detalle_pedido drop constraint detalle_pedido_carta_id_fkey;
alter table public.detalle_pedido add constraint detalle_pedido_carta_id_fkey foreign key (carta_id) references public.carta(id) on delete restrict;

create or replace function public.listar_categorias(p_token_sesion text) returns setof public.categoria
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.categoria where activo order by nombre; end; $$;
create or replace function public.listar_categorias_activas(p_token_sesion text) returns setof public.categoria
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.categoria where activo order by nombre; end; $$;
create or replace function public.listar_carta(p_token_sesion text) returns setof public.carta
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select p.* from public.carta p join public.categoria c on c.id=p.categoria_id where c.activo and not p.eliminado order by p.categoria_id,p.nombre; end; $$;
create or replace function public.listar_carta_activa(p_token_sesion text) returns setof public.carta
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select p.* from public.carta p join public.categoria c on c.id=p.categoria_id where c.activo and p.activo and not p.eliminado order by p.nombre; end; $$;
create or replace function public.eliminar_categoria(p_token_sesion text,p_categoria_id integer) returns void
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); update public.categoria set activo=false where id=p_categoria_id and activo; if not found then raise exception 'La categoría no existe o ya está eliminada.' using errcode='P0002'; end if; end; $$;
create function public.restaurar_categoria(p_token_sesion text,p_categoria_id integer) returns void
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); update public.categoria set activo=true where id=p_categoria_id and not activo; if not found then raise exception 'La categoría no está eliminada.' using errcode='P0002'; end if; end; $$;
create function public.listar_categorias_eliminadas(p_token_sesion text) returns setof public.categoria
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); return query select * from public.categoria where not activo order by nombre; end; $$;
create function public.listar_platos_eliminados(p_token_sesion text) returns setof public.carta
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); return query select * from public.carta where eliminado order by nombre; end; $$;
create function public.eliminar_plato(p_token_sesion text,p_plato_id integer) returns void
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); update public.carta set eliminado=true where id=p_plato_id and not eliminado; if not found then raise exception 'El plato no existe o ya está eliminado.' using errcode='P0002'; end if; end; $$;
create function public.restaurar_plato(p_token_sesion text,p_plato_id integer) returns void
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); update public.carta p set eliminado=false where p.id=p_plato_id and p.eliminado and exists(select 1 from public.categoria c where c.id=p.categoria_id and c.activo); if not found then raise exception 'Restaura primero la categoría o verifica el plato.' using errcode='P0002'; end if; end; $$;
create or replace function public.crear_plato(p_token_sesion text,p_categoria_id integer,p_nombre text,p_precio numeric) returns public.carta
language plpgsql security definer set search_path = '' as $$
declare resultado public.carta%rowtype;
begin perform private.requerir_owner(p_token_sesion); perform 1 from public.categoria where id=p_categoria_id and activo for share; if not found then raise exception 'La categoría no está disponible.' using errcode='P0002'; end if; insert into public.carta(categoria_id,nombre,precio) values(p_categoria_id,btrim(p_nombre),p_precio) returning * into resultado; return resultado; end; $$;
create or replace function public.actualizar_plato(p_token_sesion text,p_plato_id integer,p_categoria_id integer default null,p_nombre text default null,p_precio numeric default null,p_activo boolean default null) returns public.carta
language plpgsql security definer set search_path = '' as $$
declare resultado public.carta%rowtype; categoria_destino integer;
begin perform private.requerir_owner(p_token_sesion); select categoria_id into categoria_destino from public.carta where id=p_plato_id and not eliminado for update; if not found then raise exception 'El plato no existe.' using errcode='P0002'; end if; categoria_destino := coalesce(p_categoria_id,categoria_destino); perform 1 from public.categoria where id=categoria_destino and activo for share; if not found then raise exception 'La categoría no está disponible.' using errcode='P0002'; end if; update public.carta set categoria_id=categoria_destino,nombre=coalesce(btrim(p_nombre),nombre),precio=coalesce(p_precio,precio),activo=coalesce(p_activo,activo) where id=p_plato_id returning * into resultado; return resultado; end; $$;
create or replace function public.agregar_detalle_pedido(p_token_sesion text,p_pedido_id integer,p_carta_id integer,p_num_persona integer,p_cantidad integer) returns public.detalle_pedido
language plpgsql security definer set search_path = '' as $$
declare plato public.carta%rowtype; resultado public.detalle_pedido%rowtype;
begin perform private.obtener_actor_sesion(p_token_sesion); if not exists(select 1 from public.pedido where id=p_pedido_id and estado='activo') then raise exception 'El pedido no está activo.' using errcode='55000'; end if; select p.* into plato from public.carta p join public.categoria c on c.id=p.categoria_id where p.id=p_carta_id and p.activo and not p.eliminado and c.activo for share of p,c; if not found then raise exception 'El plato no está disponible.' using errcode='P0002'; end if; insert into public.detalle_pedido(pedido_id,carta_id,num_persona,cantidad,nombre_plato,precio_unitario) values(p_pedido_id,p_carta_id,p_num_persona,p_cantidad,plato.nombre,plato.precio) returning * into resultado; return resultado; end; $$;
revoke all on function public.restaurar_categoria(text,integer),public.listar_categorias_eliminadas(text),public.listar_platos_eliminados(text),public.eliminar_plato(text,integer),public.restaurar_plato(text,integer) from public,anon,authenticated;
grant execute on function public.restaurar_categoria(text,integer),public.listar_categorias_eliminadas(text),public.listar_platos_eliminados(text),public.eliminar_plato(text,integer),public.restaurar_plato(text,integer) to anon;
