-- Corrige la ambigüedad entre la columna usuario.nombre y la salida de la RPC.
create or replace function public.iniciar_turno(p_nombre text, p_pin text)
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
  from public.usuario as usuario
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

revoke all on function public.iniciar_turno(text, text) from public, anon, authenticated;
grant execute on function public.iniciar_turno(text, text) to anon;
