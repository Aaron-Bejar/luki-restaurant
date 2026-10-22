-- API de dominio: las tablas siguen sin privilegios directos para dispositivos.
create function private.requerir_owner(p_token_sesion text)
returns public.usuario
language plpgsql security definer set search_path = '' as $$
declare actor public.usuario%rowtype;
begin
  actor := private.obtener_actor_sesion(p_token_sesion);
  if actor.rol <> 'owner' then
    raise exception 'Solo un owner activo puede realizar esta operación.' using errcode = '42501';
  end if;
  return actor;
end;
$$;

create function public.listar_mesas(p_token_sesion text) returns setof public.mesas
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.mesas order by numero; end; $$;
create function public.obtener_mesa(p_token_sesion text, p_mesa_id integer) returns public.mesas
language plpgsql security definer set search_path = '' as $$
declare resultado public.mesas%rowtype;
begin perform private.obtener_actor_sesion(p_token_sesion); select * into resultado from public.mesas where id=p_mesa_id; if not found then raise exception 'La mesa no existe.' using errcode='P0002'; end if; return resultado; end; $$;
create function public.crear_mesa(p_token_sesion text, p_numero integer) returns public.mesas
language plpgsql security definer set search_path = '' as $$
declare resultado public.mesas%rowtype;
begin perform private.requerir_owner(p_token_sesion); insert into public.mesas(numero) values(p_numero) returning * into resultado; return resultado; end; $$;
create function public.actualizar_numero_mesa(p_token_sesion text,p_mesa_id integer,p_numero integer) returns public.mesas
language plpgsql security definer set search_path = '' as $$
declare resultado public.mesas%rowtype;
begin perform private.requerir_owner(p_token_sesion); update public.mesas set numero=p_numero where id=p_mesa_id returning * into resultado; if not found then raise exception 'La mesa no existe.' using errcode='P0002'; end if; return resultado; end; $$;
create function public.eliminar_mesa(p_token_sesion text,p_mesa_id integer) returns void
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); delete from public.mesas where id=p_mesa_id; if not found then raise exception 'La mesa no existe.' using errcode='P0002'; end if; end; $$;

create function public.listar_categorias_activas(p_token_sesion text) returns setof public.categoria
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.categoria where activo order by nombre; end; $$;
create function public.listar_carta_activa(p_token_sesion text) returns setof public.carta
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.carta where activo order by nombre; end; $$;
create function public.crear_plato(p_token_sesion text,p_categoria_id integer,p_nombre text,p_precio numeric) returns public.carta
language plpgsql security definer set search_path = '' as $$
declare resultado public.carta%rowtype;
begin perform private.requerir_owner(p_token_sesion); insert into public.carta(categoria_id,nombre,precio) values(p_categoria_id,btrim(p_nombre),p_precio) returning * into resultado; return resultado; end; $$;
create function public.actualizar_plato(p_token_sesion text,p_plato_id integer,p_categoria_id integer default null,p_nombre text default null,p_precio numeric default null,p_activo boolean default null) returns public.carta
language plpgsql security definer set search_path = '' as $$
declare resultado public.carta%rowtype;
begin perform private.requerir_owner(p_token_sesion); update public.carta set categoria_id=coalesce(p_categoria_id,categoria_id),nombre=coalesce(btrim(p_nombre),nombre),precio=coalesce(p_precio,precio),activo=coalesce(p_activo,activo) where id=p_plato_id returning * into resultado; if not found then raise exception 'El plato no existe.' using errcode='P0002'; end if; return resultado; end; $$;
create function public.desactivar_plato(p_token_sesion text,p_plato_id integer) returns void
language plpgsql security definer set search_path = '' as $$
begin perform private.requerir_owner(p_token_sesion); update public.carta set activo=false where id=p_plato_id; if not found then raise exception 'El plato no existe.' using errcode='P0002'; end if; end; $$;

create function public.obtener_pedido_activo_por_mesa(p_token_sesion text,p_mesa_id integer) returns setof public.pedido
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.pedido where mesa_id=p_mesa_id and estado='activo'; end; $$;
create function public.listar_detalle_pedido(p_token_sesion text,p_pedido_id integer) returns setof public.detalle_pedido
language plpgsql security definer set search_path = '' as $$
begin perform private.obtener_actor_sesion(p_token_sesion); return query select * from public.detalle_pedido where pedido_id=p_pedido_id order by num_persona,id; end; $$;
create function public.agregar_detalle_pedido(p_token_sesion text,p_pedido_id integer,p_carta_id integer,p_num_persona integer,p_cantidad integer) returns public.detalle_pedido
language plpgsql security definer set search_path = '' as $$
declare plato public.carta%rowtype; resultado public.detalle_pedido%rowtype;
begin perform private.obtener_actor_sesion(p_token_sesion); if not exists(select 1 from public.pedido where id=p_pedido_id and estado='activo') then raise exception 'El pedido no está activo.' using errcode='55000'; end if; select * into plato from public.carta where id=p_carta_id and activo; if not found then raise exception 'El plato no está disponible.' using errcode='P0002'; end if; insert into public.detalle_pedido(pedido_id,carta_id,num_persona,cantidad,nombre_plato,precio_unitario) values(p_pedido_id,p_carta_id,p_num_persona,p_cantidad,plato.nombre,plato.precio) returning * into resultado; return resultado; end; $$;
create function public.actualizar_detalle_pedido(p_token_sesion text,p_detalle_id integer,p_cantidad integer,p_estado_item public.estado_item) returns public.detalle_pedido
language plpgsql security definer set search_path = '' as $$
declare resultado public.detalle_pedido%rowtype;
begin perform private.obtener_actor_sesion(p_token_sesion); update public.detalle_pedido set cantidad=p_cantidad,estado_item=p_estado_item where id=p_detalle_id returning * into resultado; if not found then raise exception 'El detalle no existe.' using errcode='P0002'; end if; return resultado; end; $$;

revoke all on function private.requerir_owner(text) from public,anon,authenticated;
revoke all on function public.listar_mesas(text),public.obtener_mesa(text,integer),public.crear_mesa(text,integer),public.actualizar_numero_mesa(text,integer,integer),public.eliminar_mesa(text,integer),public.listar_categorias_activas(text),public.listar_carta_activa(text),public.crear_plato(text,integer,text,numeric),public.actualizar_plato(text,integer,integer,text,numeric,boolean),public.desactivar_plato(text,integer),public.obtener_pedido_activo_por_mesa(text,integer),public.listar_detalle_pedido(text,integer),public.agregar_detalle_pedido(text,integer,integer,integer,integer),public.actualizar_detalle_pedido(text,integer,integer,public.estado_item) from public,anon,authenticated;
grant execute on function public.iniciar_turno(text,text),public.cerrar_turno(text),public.abrir_mesa(integer,text),public.cerrar_pedido(integer,text,public.metodo_pago),public.listar_mesas(text),public.obtener_mesa(text,integer),public.crear_mesa(text,integer),public.actualizar_numero_mesa(text,integer,integer),public.eliminar_mesa(text,integer),public.listar_categorias_activas(text),public.listar_carta_activa(text),public.crear_plato(text,integer,text,numeric),public.actualizar_plato(text,integer,integer,text,numeric,boolean),public.desactivar_plato(text,integer),public.obtener_pedido_activo_por_mesa(text,integer),public.listar_detalle_pedido(text,integer),public.agregar_detalle_pedido(text,integer,integer,integer,integer),public.actualizar_detalle_pedido(text,integer,integer,public.estado_item) to anon;
