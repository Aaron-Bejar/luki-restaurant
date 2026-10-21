-- Modelo inicial para la operación de comandas por persona.
-- Los PINes nunca se almacenan en texto plano: pin_hash admite únicamente hashes bcrypt.

create type public.rol_usuario as enum ('owner', 'waitress');
create type public.estado_mesa as enum ('libre', 'ocupada');
create type public.estado_pedido as enum ('activo', 'pagado');
create type public.metodo_pago as enum ('efectivo', 'tarjeta', 'billetera_digital');
create type public.estado_item as enum ('pendiente', 'en_cocina', 'entregado', 'cancelado');

create table public.usuario (
  id uuid primary key default gen_random_uuid(),
  nombre text not null check (char_length(btrim(nombre)) between 1 and 120),
  pin_hash text not null
    check (pin_hash ~ '^\\$2[aby]\\$[0-9]{2}\\$[./A-Za-z0-9]{53}$'),
  rol public.rol_usuario not null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index usuario_nombre_unico_idx on public.usuario (lower(nombre));

create table public.categoria (
  id uuid primary key default gen_random_uuid(),
  nombre text not null check (char_length(btrim(nombre)) between 1 and 100),
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index categoria_nombre_unico_idx on public.categoria (lower(nombre));

create table public.carta (
  id uuid primary key default gen_random_uuid(),
  categoria_id uuid not null references public.categoria(id) on delete restrict,
  nombre text not null check (char_length(btrim(nombre)) between 1 and 160),
  precio numeric(12, 2) not null check (precio >= 0),
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index carta_categoria_nombre_unico_idx
  on public.carta (categoria_id, lower(nombre));
create index carta_categoria_idx on public.carta (categoria_id);

create table public.mesas (
  id uuid primary key default gen_random_uuid(),
  numero integer not null unique check (numero > 0),
  estado public.estado_mesa not null default 'libre',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.pedido (
  id uuid primary key default gen_random_uuid(),
  mesa_id uuid not null references public.mesas(id) on delete restrict,
  abierto_por_usuario_id uuid not null references public.usuario(id) on delete restrict,
  estado public.estado_pedido not null default 'activo',
  metodo_pago public.metodo_pago,
  abierto_en timestamptz not null default now(),
  cerrado_en timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pedido_estado_y_pago_coherentes check (
    (estado = 'activo' and metodo_pago is null and cerrado_en is null)
    or (estado = 'pagado' and metodo_pago is not null and cerrado_en is not null)
  )
);

-- Una mesa solo puede tener un pedido aún abierto; el histórico pagado queda fuera del índice.
create unique index pedido_unico_activo_por_mesa_idx
  on public.pedido (mesa_id)
  where estado = 'activo';
create index pedido_abierto_por_usuario_idx on public.pedido (abierto_por_usuario_id);

create table public.detalle_pedido (
  id uuid primary key default gen_random_uuid(),
  pedido_id uuid not null references public.pedido(id) on delete restrict,
  carta_id uuid not null references public.carta(id) on delete restrict,
  num_persona integer not null check (num_persona >= 1),
  cantidad integer not null default 1 check (cantidad >= 0),
  nombre_plato text not null check (char_length(btrim(nombre_plato)) between 1 and 160),
  precio_unitario numeric(12, 2) not null check (precio_unitario >= 0),
  estado_item public.estado_item not null default 'pendiente',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index detalle_pedido_pedido_persona_idx
  on public.detalle_pedido (pedido_id, num_persona);
create index detalle_pedido_carta_idx on public.detalle_pedido (carta_id);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create function public.impedir_borrado_detalle_pedido()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Las líneas de detalle_pedido no se eliminan; cancela el ítem o establece su cantidad en 0.';
end;
$$;

create function public.validar_detalle_pedido_modificable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if exists (
    select 1
    from public.pedido
    where id = new.pedido_id
      and estado = 'pagado'
  ) then
    raise exception 'No se pueden modificar líneas de un pedido pagado.';
  end if;

  if tg_op = 'UPDATE' and exists (
    select 1
    from public.pedido
    where id = old.pedido_id
      and estado = 'pagado'
  ) then
    raise exception 'No se pueden modificar líneas de un pedido pagado.';
  end if;

  return new;
end;
$$;

create trigger usuario_set_updated_at
before update on public.usuario
for each row execute function public.set_updated_at();

create trigger categoria_set_updated_at
before update on public.categoria
for each row execute function public.set_updated_at();

create trigger carta_set_updated_at
before update on public.carta
for each row execute function public.set_updated_at();

create trigger mesas_set_updated_at
before update on public.mesas
for each row execute function public.set_updated_at();

create trigger pedido_set_updated_at
before update on public.pedido
for each row execute function public.set_updated_at();

create trigger detalle_pedido_set_updated_at
before update on public.detalle_pedido
for each row execute function public.set_updated_at();

create trigger detalle_pedido_no_delete
before delete on public.detalle_pedido
for each row execute function public.impedir_borrado_detalle_pedido();

create trigger detalle_pedido_solo_si_pedido_activo
before insert or update on public.detalle_pedido
for each row execute function public.validar_detalle_pedido_modificable();

alter table public.usuario enable row level security;
alter table public.categoria enable row level security;
alter table public.carta enable row level security;
alter table public.mesas enable row level security;
alter table public.pedido enable row level security;
alter table public.detalle_pedido enable row level security;

-- El acceso desde móviles se habilitará explícitamente con políticas y RPC en tareas posteriores.
revoke all on table public.usuario, public.categoria, public.carta, public.mesas,
  public.pedido, public.detalle_pedido from public, anon, authenticated;
revoke all on function public.set_updated_at() from public, anon, authenticated;
revoke all on function public.impedir_borrado_detalle_pedido() from public, anon, authenticated;
revoke all on function public.validar_detalle_pedido_modificable() from public, anon, authenticated;
