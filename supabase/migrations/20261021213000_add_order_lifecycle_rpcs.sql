-- Transiciones operativas atómicas de una mesa y su pedido.
-- El bloqueo de la fila de mesa serializa aperturas concurrentes de los siete
-- dispositivos. Los permisos de ejecución se concederán junto con el flujo de
-- autenticación, para no habilitar escrituras directas antes de ese momento.

create function public.validar_actor_operativo(p_usuario_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.usuario
    where id = p_usuario_id
      and activo
      and rol in ('owner', 'waitress')
  ) then
    raise exception 'El usuario operativo no existe, está inactivo o no puede operar pedidos.'
      using errcode = '42501';
  end if;
end;
$$;

create function public.abrir_mesa(p_mesa_id integer, p_usuario_id uuid)
returns public.pedido
language plpgsql
security definer
set search_path = ''
as $$
declare
  mesa_actual public.mesas%rowtype;
  pedido_nuevo public.pedido%rowtype;
begin
  perform public.validar_actor_operativo(p_usuario_id);

  select *
  into mesa_actual
  from public.mesas
  where id = p_mesa_id
  for update;

  if not found then
    raise exception 'La mesa % no existe.', p_mesa_id
      using errcode = 'P0002';
  end if;

  if mesa_actual.estado <> 'libre' then
    raise exception 'La mesa % ya está ocupada.', p_mesa_id
      using errcode = '55000';
  end if;

  -- La comprobación es redundante respecto al índice parcial, pero ofrece un
  -- error de dominio claro si los datos se hubieran dejado inconsistentes.
  if exists (
    select 1
    from public.pedido
    where mesa_id = p_mesa_id
      and estado = 'activo'
  ) then
    raise exception 'La mesa % ya tiene un pedido activo.', p_mesa_id
      using errcode = '55000';
  end if;

  update public.mesas
  set estado = 'ocupada'
  where id = p_mesa_id;

  insert into public.pedido (mesa_id, abierto_por_usuario_id)
  values (p_mesa_id, p_usuario_id)
  returning * into pedido_nuevo;

  return pedido_nuevo;
end;
$$;

create function public.cerrar_pedido(
  p_pedido_id integer,
  p_usuario_id uuid,
  p_metodo_pago public.metodo_pago
)
returns public.pedido
language plpgsql
security definer
set search_path = ''
as $$
declare
  pedido_actual public.pedido%rowtype;
  pedido_cerrado public.pedido%rowtype;
begin
  perform public.validar_actor_operativo(p_usuario_id);

  select *
  into pedido_actual
  from public.pedido
  where id = p_pedido_id
  for update;

  if not found then
    raise exception 'El pedido % no existe.', p_pedido_id
      using errcode = 'P0002';
  end if;

  if pedido_actual.estado <> 'activo' then
    raise exception 'El pedido % no está activo.', p_pedido_id
      using errcode = '55000';
  end if;

  -- Bloquea la mesa asociada antes de modificarla. La apertura bloquea esa
  -- misma fila, por lo que ambas transiciones quedan serializadas.
  perform 1
  from public.mesas
  where id = pedido_actual.mesa_id
  for update;

  update public.pedido
  set estado = 'pagado',
      metodo_pago = p_metodo_pago,
      cerrado_en = now()
  where id = pedido_actual.id
  returning * into pedido_cerrado;

  update public.mesas
  set estado = 'libre'
  where id = pedido_actual.mesa_id;

  return pedido_cerrado;
end;
$$;

revoke all on function public.validar_actor_operativo(uuid) from public, anon, authenticated;
revoke all on function public.abrir_mesa(integer, uuid) from public, anon, authenticated;
revoke all on function public.cerrar_pedido(integer, uuid, public.metodo_pago) from public, anon, authenticated;
