-- Prueba temporal: ejecutar el archivo completo; no aplicar por separado.
-- Los cambios de esquema y datos se revierten al finalizar.
-- La secuencia de detalle_pedido puede avanzar aunque se revierta.
begin;

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

do $$
declare
  sufijo text := replace(gen_random_uuid()::text, '-', '');
  owner_id uuid; mesera_id uuid; token_owner text := encode(extensions.gen_random_bytes(32), 'hex');
  token_mesera text := encode(extensions.gen_random_bytes(32), 'hex');
  categoria_id integer := -2000000001; plato_id integer := -2000000002;
  otro_id integer := -2000000003; mesa_id integer := -2000000004;
  pedido_id integer := -2000000005; detalle_id integer; nombre_categoria text;
begin
  nombre_categoria := 'Prueba carta ' || sufijo;
  insert into public.usuario(nombre,pin_hash,rol) values ('Owner ' || sufijo, extensions.crypt('1234',extensions.gen_salt('bf',10)), 'owner') returning id into owner_id;
  insert into public.usuario(nombre,pin_hash,rol) values ('Mesera ' || sufijo, extensions.crypt('1234',extensions.gen_salt('bf',10)), 'waitress') returning id into mesera_id;
  insert into public.sesion_operativa(usuario_id,token_hash,expira_en) values
    (owner_id,private.hash_token_sesion(token_owner),now()+interval '1 hour'),
    (mesera_id,private.hash_token_sesion(token_mesera),now()+interval '1 hour');
  insert into public.categoria(id,nombre) values(categoria_id,nombre_categoria);
  insert into public.carta(id,categoria_id,nombre,precio) values
    (plato_id,categoria_id,'Plato ' || sufijo,12.50),
    (otro_id,categoria_id,'Otro ' || sufijo,10);
  insert into public.mesas(id,numero) values(mesa_id, (select coalesce(max(numero),0)+1 from public.mesas));
  insert into public.pedido(id,mesa_id,abierto_por_usuario_id) values(pedido_id,mesa_id,owner_id);
  perform public.establecer_disponibilidad_plato(token_owner,otro_id,false);
  begin
    perform public.agregar_detalle_pedido(token_mesera,pedido_id,otro_id,1,1);
    raise exception 'Se agregó un plato no disponible';
  exception when no_data_found then null; end;
  perform public.establecer_disponibilidad_plato(token_owner,otro_id,true);
  perform public.eliminar_plato(token_owner,otro_id);
  begin
    perform public.agregar_detalle_pedido(token_mesera,pedido_id,otro_id,1,1);
    raise exception 'Se agregó un plato eliminado';
  exception when no_data_found then null; end;
  perform public.restaurar_plato(token_owner,otro_id);
  perform public.establecer_disponibilidad_plato(token_owner,otro_id,false);
  perform public.eliminar_plato(token_owner,otro_id);
  select id into detalle_id from public.agregar_detalle_pedido(token_owner,pedido_id,plato_id,1,1);
  perform public.eliminar_categoria(token_owner,categoria_id);
  begin
    perform public.agregar_detalle_pedido(token_mesera,pedido_id,plato_id,1,1);
    raise exception 'Se agregó un plato de categoría eliminada';
  exception when no_data_found then null; end;
  update public.pedido set estado='pagado',metodo_pago='efectivo',cerrado_en=now() where id=pedido_id;
  perform public.restaurar_categoria(token_owner,categoria_id);
  perform public.eliminar_categoria(token_owner,categoria_id);
  if exists(select 1 from public.listar_carta(token_mesera) where id in (plato_id,otro_id)) then raise exception 'Categoría eliminada visible'; end if;
  if not exists(select 1 from public.detalle_pedido where id=detalle_id and carta_id=plato_id and nombre_plato='Plato ' || sufijo and precio_unitario=12.50) then raise exception 'Histórico alterado'; end if;
  begin perform public.restaurar_plato(token_owner,otro_id); raise exception 'Se restauró plato con categoría eliminada'; exception when no_data_found then null; end;
  begin perform public.crear_categoria(token_owner,nombre_categoria); raise exception 'Nombre duplicado aceptado'; exception when unique_violation then null; end;
  begin perform public.restaurar_categoria(token_mesera,categoria_id); raise exception 'Mesera autorizada'; exception when insufficient_privilege then null; end;
  begin perform public.listar_carta(repeat('0',64)); raise exception 'Token inventado aceptado'; exception when invalid_authorization_specification then null; end;
  perform public.restaurar_categoria(token_owner,categoria_id);
  if not exists(select 1 from public.listar_carta(token_mesera) where id=plato_id) or exists(select 1 from public.listar_carta(token_mesera) where id=otro_id) then raise exception 'Restauración de categoría incorrecta'; end if;
  perform public.restaurar_plato(token_owner,otro_id);
  if not exists(select 1 from public.listar_carta(token_mesera) where id=otro_id and not activo) then raise exception 'Disponibilidad no conservada'; end if;
  perform set_config('luki_test.token_owner', token_owner, true);
  perform set_config('luki_test.token_mesera', token_mesera, true);
end;
$$;
-- Comprobar la vía de acceso real de la aplicación, no solo como administrador SQL.
set local role anon;
do $$
declare
  token_owner text := current_setting('luki_test.token_owner');
  token_mesera text := current_setting('luki_test.token_mesera');
begin
  perform public.eliminar_plato(token_owner, -2000000003);
  perform public.restaurar_plato(token_owner, -2000000003);
  perform public.listar_platos_eliminados(token_owner);
  perform public.listar_categorias_eliminadas(token_owner);
  perform public.eliminar_categoria(token_owner, -2000000001);
  perform public.restaurar_categoria(token_owner, -2000000001);
  begin
    perform public.eliminar_plato(token_mesera, -2000000003);
    raise exception 'La mesera pudo eliminar un plato';
  exception when insufficient_privilege then null; end;
  begin
    perform public.listar_platos_eliminados(repeat('0', 64));
    raise exception 'Se aceptó un token inventado';
  exception when invalid_authorization_specification then null; end;
  if has_table_privilege('anon', 'public.carta', 'INSERT,UPDATE,DELETE')
    or has_table_privilege('anon', 'public.categoria', 'INSERT,UPDATE,DELETE') then
    raise exception 'anon tiene escritura directa en tablas de Carta';
  end if;
end;
$$;
reset role;

rollback;

