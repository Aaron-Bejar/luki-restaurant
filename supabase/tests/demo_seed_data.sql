-- Verificación de la semilla T004.
-- Ejecutar después de aplicar las migraciones, contra una base de prueba.

begin;

do $$
declare
  cantidad_mesas integer;
  cantidad_categorias integer;
  cantidad_platos integer;
  cantidad_platos_sin_categoria integer;
  cantidad_precios_invalidos integer;
begin
  select count(*) into cantidad_mesas
  from public.mesas
  where numero between 1 and 7 and estado = 'libre';

  if cantidad_mesas <> 7 then
    raise exception 'La semilla debe crear 7 mesas libres; se encontraron %.', cantidad_mesas;
  end if;

  select count(*) into cantidad_categorias
  from public.categoria
  where nombre in ('Entradas', 'Ceviches', 'Fondos', 'Bebidas', 'Postres')
    and activo;

  if cantidad_categorias <> 5 then
    raise exception 'La semilla debe crear 5 categorías activas; se encontraron %.', cantidad_categorias;
  end if;

  select count(*) into cantidad_platos
  from public.carta
  where activo;

  if cantidad_platos <> 25 then
    raise exception 'La semilla debe crear 25 platos activos; se encontraron %.', cantidad_platos;
  end if;

  select count(*) into cantidad_platos_sin_categoria
  from public.carta as carta
  left join public.categoria as categoria on categoria.id = carta.categoria_id
  where categoria.id is null;

  if cantidad_platos_sin_categoria <> 0 then
    raise exception 'Hay platos sin categoría asociada.';
  end if;

  select count(*) into cantidad_precios_invalidos
  from public.carta
  where precio < 0;

  if cantidad_precios_invalidos <> 0 then
    raise exception 'Hay platos con precio negativo.';
  end if;
end;
$$;

rollback;
