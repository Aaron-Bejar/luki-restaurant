-- Gestión de Carta: las categorías son siempre activas; los platos pueden no estar disponibles.
-- Los detalles históricos conservan su snapshot aunque se elimine el producto de origen.

do $$
begin
  if exists (
    select 1
    from public.categoria
    group by lower(btrim(nombre))
    having count(*) > 1
  ) then
    raise exception 'No se pueden normalizar categorías con nombres duplicados.';
  end if;
end;
$$;

update public.categoria
set nombre = btrim(nombre), activo = true
where nombre <> btrim(nombre) or not activo;

drop index if exists public.categoria_nombre_unico_idx;
create unique index categoria_nombre_normalizado_unico_idx
  on public.categoria (lower(btrim(nombre)));

alter table public.categoria
  add constraint categoria_siempre_activa_check check (activo);

alter table public.carta drop constraint carta_categoria_id_fkey;
alter table public.carta
  add constraint carta_categoria_id_fkey
  foreign key (categoria_id) references public.categoria(id) on delete cascade;

alter table public.detalle_pedido drop constraint detalle_pedido_carta_id_fkey;
alter table public.detalle_pedido alter column carta_id drop not null;
alter table public.detalle_pedido
  add constraint detalle_pedido_carta_id_fkey
  foreign key (carta_id) references public.carta(id) on delete set null;

create or replace function public.listar_categorias(p_token_sesion text)
returns setof public.categoria
language plpgsql security definer set search_path = '' as $$
begin
  perform private.obtener_actor_sesion(p_token_sesion);
  return query select * from public.categoria order by nombre;
end;
$$;

create or replace function public.listar_carta(p_token_sesion text)
returns setof public.carta
language plpgsql security definer set search_path = '' as $$
begin
  perform private.obtener_actor_sesion(p_token_sesion);
  return query select * from public.carta order by categoria_id, nombre;
end;
$$;

create or replace function public.crear_categoria(p_token_sesion text, p_nombre text)
returns public.categoria
language plpgsql security definer set search_path = '' as $$
declare resultado public.categoria%rowtype;
begin
  perform private.requerir_owner(p_token_sesion);
  insert into public.categoria(nombre, activo) values (btrim(p_nombre), true)
  returning * into resultado;
  return resultado;
end;
$$;

create or replace function public.actualizar_categoria(
  p_token_sesion text,
  p_categoria_id integer,
  p_nombre text
) returns public.categoria
language plpgsql security definer set search_path = '' as $$
declare resultado public.categoria%rowtype;
begin
  perform private.requerir_owner(p_token_sesion);
  update public.categoria set nombre = btrim(p_nombre)
  where id = p_categoria_id
  returning * into resultado;
  if not found then raise exception 'La categoría no existe.' using errcode = 'P0002'; end if;
  return resultado;
end;
$$;

create or replace function public.eliminar_categoria(p_token_sesion text, p_categoria_id integer)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform private.requerir_owner(p_token_sesion);
  delete from public.categoria where id = p_categoria_id;
  if not found then raise exception 'La categoría no existe.' using errcode = 'P0002'; end if;
end;
$$;

create or replace function public.crear_plato(
  p_token_sesion text,
  p_categoria_id integer,
  p_nombre text,
  p_precio numeric
) returns public.carta
language plpgsql security definer set search_path = '' as $$
declare resultado public.carta%rowtype;
begin
  perform private.requerir_owner(p_token_sesion);
  insert into public.carta(categoria_id, nombre, precio, activo)
  values(p_categoria_id, btrim(p_nombre), p_precio, true)
  returning * into resultado;
  return resultado;
end;
$$;

create or replace function public.actualizar_plato(
  p_token_sesion text,
  p_plato_id integer,
  p_categoria_id integer default null,
  p_nombre text default null,
  p_precio numeric default null,
  p_activo boolean default null
) returns public.carta
language plpgsql security definer set search_path = '' as $$
declare resultado public.carta%rowtype;
begin
  perform private.requerir_owner(p_token_sesion);
  update public.carta
  set categoria_id = coalesce(p_categoria_id, categoria_id),
      nombre = coalesce(btrim(p_nombre), nombre),
      precio = coalesce(p_precio, precio),
      activo = coalesce(p_activo, activo)
  where id = p_plato_id
  returning * into resultado;
  if not found then raise exception 'El plato no existe.' using errcode = 'P0002'; end if;
  return resultado;
end;
$$;

create or replace function public.establecer_disponibilidad_plato(
  p_token_sesion text,
  p_plato_id integer,
  p_activo boolean
) returns public.carta
language plpgsql security definer set search_path = '' as $$
begin
  return public.actualizar_plato(p_token_sesion, p_plato_id, null, null, null, p_activo);
end;
$$;

revoke all on function public.listar_categorias(text), public.listar_carta(text),
  public.crear_categoria(text, text), public.actualizar_categoria(text, integer, text),
  public.eliminar_categoria(text, integer), public.crear_plato(text, integer, text, numeric),
  public.actualizar_plato(text, integer, integer, text, numeric, boolean),
  public.establecer_disponibilidad_plato(text, integer, boolean)
from public, anon, authenticated;

grant execute on function public.listar_categorias(text), public.listar_carta(text),
  public.crear_categoria(text, text), public.actualizar_categoria(text, integer, text),
  public.eliminar_categoria(text, integer), public.crear_plato(text, integer, text, numeric),
  public.actualizar_plato(text, integer, integer, text, numeric, boolean),
  public.establecer_disponibilidad_plato(text, integer, boolean)
to anon;
