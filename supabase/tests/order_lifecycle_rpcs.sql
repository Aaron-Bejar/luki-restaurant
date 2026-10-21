-- Verificación reproducible de las RPC de apertura y cierre.
-- Ejecutar después de las migraciones en una base de pruebas. No persiste datos.

begin;

do $$
declare
  actor_id_test uuid;
  mesa_id_test integer;
  pedido_id_test integer;
  pedido_cerrado public.pedido%rowtype;
begin
  insert into public.usuario (nombre, pin_hash, rol)
  values (
    'Actor de prueba RPC',
    '$2b$12$LQv3c1yqBWf4fxLqVY4uJOPoE1ZrzqBK76Z4mfACOcElKjxwfVGRK',
    'waitress'
  )
  returning id into actor_id_test;

  insert into public.mesas (numero)
  values (99998)
  returning id into mesa_id_test;

  select id
  into pedido_id_test
  from public.abrir_mesa(mesa_id_test, actor_id_test);

  if (select estado from public.mesas where id = mesa_id_test) <> 'ocupada' then
    raise exception 'La apertura no ocupó la mesa.';
  end if;

  if (select count(*) from public.pedido as pedido where pedido.mesa_id = mesa_id_test and pedido.estado = 'activo') <> 1 then
    raise exception 'La apertura no creó exactamente un pedido activo.';
  end if;

  begin
    perform public.abrir_mesa(mesa_id_test, actor_id_test);
    raise exception 'Se abrió dos veces la misma mesa.';
  exception
    when sqlstate '55000' then
      null;
  end;

  -- El error previo no debe haber creado un segundo pedido ni liberar la mesa.
  if (select count(*) from public.pedido as pedido where pedido.mesa_id = mesa_id_test and pedido.estado = 'activo') <> 1
    or (select estado from public.mesas where id = mesa_id_test) <> 'ocupada' then
    raise exception 'La apertura rechazada dejó un estado parcial.';
  end if;

  select *
  into pedido_cerrado
  from public.cerrar_pedido(pedido_id_test, actor_id_test, 'tarjeta');

  if pedido_cerrado.estado <> 'pagado'
    or pedido_cerrado.metodo_pago <> 'tarjeta'
    or pedido_cerrado.cerrado_en is null
    or (select estado from public.mesas where id = mesa_id_test) <> 'libre' then
    raise exception 'El cierre no actualizó atómicamente el pedido y la mesa.';
  end if;

  begin
    perform public.cerrar_pedido(pedido_id_test, actor_id_test, 'efectivo');
    raise exception 'Se volvió a cerrar un pedido pagado.';
  exception
    when sqlstate '55000' then
      null;
  end;

  if (select estado from public.pedido where id = pedido_id_test) <> 'pagado'
    or (select metodo_pago from public.pedido where id = pedido_id_test) <> 'tarjeta' then
    raise exception 'El cierre rechazado alteró el pedido histórico.';
  end if;
end;
$$;

rollback;
