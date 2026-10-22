-- El PIN identifica unívocamente el turno; nunca se almacena fuera de bcrypt.
-- La comprobación compara hashes bcrypt existentes, por lo que no introduce un
-- verificador determinista que facilite enumerar los 10 000 PINes posibles.

create function private.verificar_pin_disponible(
  p_pin text,
  p_usuario_id uuid default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_pin is null or p_pin !~ '^[0-9]{4}$' then
    raise exception 'El PIN debe tener exactamente cuatro dígitos.' using errcode = '22023';
  end if;

  -- Evita que dos altas/restablecimientos concurrentes asignen el mismo PIN.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_pin, 0));

  if exists (
    select 1
    from public.usuario as usuario
    where usuario.activo
      and usuario.id is distinct from p_usuario_id
      and extensions.crypt(p_pin, usuario.pin_hash) = usuario.pin_hash
  ) then
    raise exception 'El PIN ya está asignado a una cuenta activa.' using errcode = '23505';
  end if;
end;
$$;

drop function public.iniciar_turno(text, text);

create function public.iniciar_turno(p_pin text)
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
  coincidencias integer;
  token_nuevo text;
  vencimiento timestamptz := now() + interval '12 hours';
begin
  if p_pin is null or p_pin !~ '^[0-9]{4}$' then
    raise exception 'PIN inválido.' using errcode = '28000';
  end if;

  select count(*)
  into coincidencias
  from public.usuario as usuario
  where usuario.activo
    and extensions.crypt(p_pin, usuario.pin_hash) = usuario.pin_hash;

  -- Una coincidencia ambigua se trata como rechazo para no atribuir un turno
  -- a la cuenta equivocada. Las altas y restablecimientos deben invocar la
  -- función privada de disponibilidad de PIN de esta migración.
  if coincidencias <> 1 then
    raise exception 'PIN inválido.' using errcode = '28000';
  end if;

  select usuario.*
  into actor
  from public.usuario as usuario
  where usuario.activo
    and extensions.crypt(p_pin, usuario.pin_hash) = usuario.pin_hash;

  token_nuevo := encode(extensions.gen_random_bytes(32), 'hex');

  insert into public.sesion_operativa (usuario_id, token_hash, expira_en)
  values (actor.id, private.hash_token_sesion(token_nuevo), vencimiento);

  return query
  select token_nuevo, actor.id, actor.nombre, actor.rol, vencimiento;
end;
$$;

revoke all on function private.verificar_pin_disponible(text, uuid) from public, anon, authenticated;
revoke all on function public.iniciar_turno(text) from public, anon, authenticated;
grant execute on function public.iniciar_turno(text) to anon;
