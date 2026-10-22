-- Verificación reproducible de las RPC de apertura y cierre.
-- Ejecutar después de las migraciones en una base de pruebas. No persiste datos.

begin;

do $$
declare
  token_sesion_test text;
  mesa_id_test integer;
  pedido_id_test integer;
  pedido_cerrado public.pedido%rowtype;
begin
  insert into public.usuario (nombre, pin_hash, rol)
  values ('Actor de prueba RPC', extensions.crypt('1234', extensions.gen_salt('bf', 10)), 'waitress');

  select token_sesion
  into token_sesion_test
  from public.iniciar_turno('1234');

  insert into public.mesas (numero)
  values (99998)
  returning id into mesa_id_test;

  select id
  into pedido_id_test
  from public.abrir_mesa(mesa_id_test, token_sesion_test);

  if (select estado from public.mesas where id = mesa_id_test) <> 'ocupada' then
    raise exception 'La apertura no ocupó la mesa.';
  end if;

  if (select count(*) from public.pedido as pedido where pedido.mesa_id = mesa_id_test and pedido.estado = 'activo') <> 1 then
    raise exception 'La apertura no creó exactamente un pedido activo.';
  end if;

  begin
    perform public.abrir_mesa(mesa_id_test, token_sesion_test);
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
  from public.cerrar_pedido(pedido_id_test, token_sesion_test, 'tarjeta');

  if pedido_cerrado.estado <> 'pagado'
    or pedido_cerrado.metodo_pago <> 'tarjeta'
    or pedido_cerrado.cerrado_en is null
    or (select estado from public.mesas where id = mesa_id_test) <> 'libre' then
    raise exception 'El cierre no actualizó atómicamente el pedido y la mesa.';
  end if;

  begin
    perform public.cerrar_pedido(pedido_id_test, token_sesion_test, 'efectivo');
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
