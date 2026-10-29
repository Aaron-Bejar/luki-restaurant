-- Ejecutar después de las migraciones, contra una base de prueba o transacción descartable.
begin;

do $$
declare
  token_owner text;
  token_mesera text;
  owner_id uuid;
  categoria_id integer;
  plato_id integer;
  mesa_id integer;
  pedido_id integer;
  detalle_id integer;
begin
  insert into public.usuario(nombre, pin_hash, rol)
  values ('Owner carta', extensions.crypt('9101', extensions.gen_salt('bf', 10)), 'owner')
  returning id into owner_id;
  insert into public.usuario(nombre, pin_hash, rol)
  values ('Mesera carta', extensions.crypt('9102', extensions.gen_salt('bf', 10)), 'waitress');

  select token_sesion into token_owner from public.iniciar_turno('9101');
  select token_sesion into token_mesera from public.iniciar_turno('9102');

  select id into categoria_id from public.crear_categoria(token_owner, '  Carta de prueba  ');
  if (select nombre from public.categoria where id = categoria_id) <> 'Carta de prueba' then
    raise exception 'La categoría no se normalizó.';
  end if;

  select id into plato_id from public.crear_plato(token_owner, categoria_id, 'Plato no disponible', 12.50);
  perform public.establecer_disponibilidad_plato(token_owner, plato_id, false);
  if not exists (select 1 from public.listar_carta(token_mesera) where id = plato_id and not activo) then
    raise exception 'La mesera no recibió el plato no disponible.';
  end if;

  begin
    perform public.crear_categoria(token_mesera, 'No autorizado');
    raise exception 'Una mesera administró categorías.';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.listar_carta(repeat('0', 64));
    raise exception 'Se aceptó un token inventado.';
  exception when invalid_authorization_specification then null;
  end;

  insert into public.mesas(numero) values (9101) returning id into mesa_id;
  insert into public.pedido(mesa_id, abierto_por_usuario_id) values (mesa_id, owner_id) returning id into pedido_id;
  insert into public.detalle_pedido(pedido_id, carta_id, num_persona, cantidad, nombre_plato, precio_unitario)
  values (pedido_id, plato_id, 1, 1, 'Plato no disponible', 12.50) returning id into detalle_id;

  begin
    perform public.agregar_detalle_pedido(token_mesera, pedido_id, plato_id, 1, 1);
    raise exception 'Se agregó un plato no disponible.';
  exception when no_data_found then null;
  end;

  perform public.eliminar_categoria(token_owner, categoria_id);
  if exists (select 1 from public.carta where id = plato_id) then
    raise exception 'La categoría no eliminó sus platos.';
  end if;
  if (select carta_id from public.detalle_pedido where id = detalle_id) is not null then
    raise exception 'El detalle histórico conservó una referencia eliminada.';
  end if;
  if (select nombre_plato from public.detalle_pedido where id = detalle_id) <> 'Plato no disponible' then
    raise exception 'El detalle histórico perdió su snapshot.';
  end if;
end;
$$;

rollback;
