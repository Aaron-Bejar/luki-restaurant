-- Sesiones operativas propias para autenticar PINes sin depender de auth.users.
-- Las RPC públicas reciben un token temporal; el actor nunca viene como UUID
-- controlado por el cliente.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

update public.usuario
set nombre = btrim(nombre)
where nombre <> btrim(nombre);

alter table public.usuario
  add constraint usuario_nombre_normalizado_check
  check (nombre = btrim(nombre));

drop index public.usuario_nombre_unico_idx;
create unique index usuario_nombre_unico_normalizado_idx
  on public.usuario (lower(btrim(nombre)));

create table public.sesion_operativa (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references public.usuario(id) on delete restrict,
  token_hash char(64) not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
  creada_en timestamptz not null default now(),
  expira_en timestamptz not null,
  revocada_en timestamptz,
  constraint sesion_operativa_vencimiento_check check (expira_en > creada_en),
  constraint sesion_operativa_revocacion_check check (
    revocada_en is null or revocada_en >= creada_en
  )
);

create index sesion_operativa_usuario_vigente_idx
  on public.sesion_operativa (usuario_id, expira_en)
  where revocada_en is null;

alter table public.sesion_operativa enable row level security;
revoke all on table public.sesion_operativa from public, anon, authenticated;

create function private.hash_token_sesion(p_token_sesion text)
returns text
language sql
immutable
security invoker
set search_path = ''
as $$
  select encode(extensions.digest(p_token_sesion, 'sha256'), 'hex');
$$;

create function private.obtener_actor_sesion(p_token_sesion text)
returns public.usuario
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor public.usuario%rowtype;
begin
  if p_token_sesion is null or p_token_sesion !~ '^[0-9a-f]{64}$' then
    raise exception 'La sesión operativa no es válida.' using errcode = '28000';
  end if;

  select usuario.*
  into actor
  from public.sesion_operativa as sesion
  join public.usuario as usuario on usuario.id = sesion.usuario_id
  where sesion.token_hash = private.hash_token_sesion(p_token_sesion)
    and sesion.revocada_en is null
    and sesion.expira_en > now()
    and usuario.activo;

  if not found then
    raise exception 'La sesión operativa no es válida.' using errcode = '28000';
  end if;

  return actor;
end;
$$;

create function public.iniciar_turno(p_nombre text, p_pin text)
returns table (
  token_sesion text,
  usuario_id uuid,
  nombre text,
  rol public.rol_usuario,
  expira_en timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor public.usuario%rowtype;
  token_nuevo text;
  vencimiento timestamptz := now() + interval '12 hours';
begin
  if p_nombre is null
    or btrim(p_nombre) = ''
    or p_pin is null
    or p_pin !~ '^[0-9]{4}$' then
    raise exception 'Nombre o PIN inválido.' using errcode = '28000';
  end if;

  select usuario.*
  into actor
  from public.usuario
  where lower(btrim(usuario.nombre)) = lower(btrim(p_nombre))
    and usuario.activo
    and extensions.crypt(p_pin, usuario.pin_hash) = usuario.pin_hash;

  if not found then
    raise exception 'Nombre o PIN inválido.' using errcode = '28000';
  end if;

  token_nuevo := encode(extensions.gen_random_bytes(32), 'hex');

  insert into public.sesion_operativa (usuario_id, token_hash, expira_en)
  values (
    actor.id,
    private.hash_token_sesion(token_nuevo),
    vencimiento
  );

  return query
  select token_nuevo, actor.id, actor.nombre, actor.rol, vencimiento;
end;
$$;

create function public.cerrar_turno(p_token_sesion text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.obtener_actor_sesion(p_token_sesion);

  update public.sesion_operativa
  set revocada_en = now()
  where token_hash = private.hash_token_sesion(p_token_sesion)
    and revocada_en is null;
end;
$$;

drop function public.abrir_mesa(integer, uuid);
drop function public.cerrar_pedido(integer, uuid, public.metodo_pago);
drop function public.validar_actor_operativo(uuid);

create function public.abrir_mesa(p_mesa_id integer, p_token_sesion text)
returns public.pedido
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor public.usuario%rowtype;
  mesa_actual public.mesas%rowtype;
  pedido_nuevo public.pedido%rowtype;
begin
  actor := private.obtener_actor_sesion(p_token_sesion);

  select *
  into mesa_actual
  from public.mesas
  where id = p_mesa_id
  for update;

  if not found then
    raise exception 'La mesa % no existe.', p_mesa_id using errcode = 'P0002';
  end if;

  if mesa_actual.estado <> 'libre' then
    raise exception 'La mesa % ya está ocupada.', p_mesa_id using errcode = '55000';
  end if;

  if exists (
    select 1
    from public.pedido
    where mesa_id = p_mesa_id and estado = 'activo'
  ) then
    raise exception 'La mesa % ya tiene un pedido activo.', p_mesa_id using errcode = '55000';
  end if;

  update public.mesas set estado = 'ocupada' where id = p_mesa_id;

  insert into public.pedido (mesa_id, abierto_por_usuario_id)
  values (p_mesa_id, actor.id)
  returning * into pedido_nuevo;

  return pedido_nuevo;
end;
$$;

create function public.cerrar_pedido(
  p_pedido_id integer,
  p_token_sesion text,
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
  perform private.obtener_actor_sesion(p_token_sesion);

  select *
  into pedido_actual
  from public.pedido
  where id = p_pedido_id
  for update;

  if not found then
    raise exception 'El pedido % no existe.', p_pedido_id using errcode = 'P0002';
  end if;

  if pedido_actual.estado <> 'activo' then
    raise exception 'El pedido % no está activo.', p_pedido_id using errcode = '55000';
  end if;

  perform 1
  from public.mesas
  where id = pedido_actual.mesa_id
  for update;

  update public.pedido
  set estado = 'pagado', metodo_pago = p_metodo_pago, cerrado_en = now()
  where id = pedido_actual.id
  returning * into pedido_cerrado;

  update public.mesas set estado = 'libre' where id = pedido_actual.mesa_id;

  return pedido_cerrado;
end;
$$;

revoke all on function private.hash_token_sesion(text) from public, anon, authenticated;
revoke all on function private.obtener_actor_sesion(text) from public, anon, authenticated;
revoke all on function public.iniciar_turno(text, text) from public, anon, authenticated;
revoke all on function public.cerrar_turno(text) from public, anon, authenticated;
revoke all on function public.abrir_mesa(integer, text) from public, anon, authenticated;
revoke all on function public.cerrar_pedido(integer, text, public.metodo_pago) from public, anon, authenticated;

grant execute on function public.iniciar_turno(text, text) to anon;
grant execute on function public.cerrar_turno(text) to anon;
grant execute on function public.abrir_mesa(integer, text) to anon;
grant execute on function public.cerrar_pedido(integer, text, public.metodo_pago) to anon;
