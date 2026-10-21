-- Verificación manual/reproducible de la migración inicial.
-- Ejecutar contra una base de pruebas o una transacción descartable.

begin;

do $$
declare
  usuario_id uuid;
  categoria_id integer;
  carta_id integer;
  mesa_id integer;
  pedido_id integer;
  detalle_id integer;
begin
  begin
    insert into public.usuario (nombre, pin_hash, rol)
    values ('PIN inválido', 'no-es-un-hash-bcrypt', 'owner');
    raise exception 'Se aceptó un PIN sin hash bcrypt.';
  exception
    when check_violation then
      null;
  end;

  insert into public.usuario (nombre, pin_hash, rol)
  values (
    'Prueba de propietario',
    '$2b$12$LQv3c1yqBWf4fxLqVY4uJOPoE1ZrzqBK76Z4mfACOcElKjxwfVGRK',
    'owner'
  )
  returning id into usuario_id;

  insert into public.categoria (nombre) values ('Prueba') returning id into categoria_id;

  begin
    insert into public.carta (categoria_id, nombre, precio)
    values (categoria_id, 'Precio inválido', -1);
    raise exception 'Se aceptó un precio negativo.';
  exception
    when check_violation then
      null;
  end;

  insert into public.carta (categoria_id, nombre, precio)
  values (categoria_id, 'Plato de prueba', 12.50)
  returning id into carta_id;

  insert into public.mesas (numero) values (99999) returning id into mesa_id;

  insert into public.pedido (mesa_id, abierto_por_usuario_id)
  values (mesa_id, usuario_id)
  returning id into pedido_id;

  begin
    insert into public.detalle_pedido (
      pedido_id, carta_id, num_persona, cantidad, nombre_plato, precio_unitario
    ) values (pedido_id, carta_id, 0, 1, 'Plato de prueba', 12.50);
    raise exception 'Se aceptó una persona no positiva.';
  exception
    when check_violation then
      null;
  end;

  insert into public.detalle_pedido (
    pedido_id, carta_id, num_persona, cantidad, nombre_plato, precio_unitario
  ) values (pedido_id, carta_id, 1, 1, 'Plato de prueba', 12.50)
  returning id into detalle_id;

  begin
    delete from public.detalle_pedido where id = detalle_id;
    raise exception 'Se permitió borrar físicamente un detalle.';
  exception
    when others then
      if sqlerrm not like 'Las líneas de detalle_pedido no se eliminan%' then
        raise;
      end if;
  end;

  begin
    delete from public.mesas where id = mesa_id;
    raise exception 'Se permitió eliminar una mesa con pedido asociado.';
  exception
    when foreign_key_violation then
      null;
  end;

  update public.pedido
  set estado = 'pagado', metodo_pago = 'efectivo', cerrado_en = now()
  where id = pedido_id;

  begin
    update public.detalle_pedido set cantidad = 2 where id = detalle_id;
    raise exception 'Se permitió modificar un detalle de pedido pagado.';
  exception
    when others then
      if sqlerrm <> 'No se pueden modificar líneas de un pedido pagado.' then
        raise;
      end if;
  end;
end;
$$;

rollback;
