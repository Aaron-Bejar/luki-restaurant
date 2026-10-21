-- Datos de demostración compartidos para desarrollar y probar la operación.
-- No incluye usuarios: sus nombres y hashes bcrypt se aprovisionan solo de forma local.

insert into public.mesas (numero)
values (1), (2), (3), (4), (5), (6), (7);

insert into public.categoria (nombre)
values
  ('Entradas'),
  ('Ceviches'),
  ('Fondos'),
  ('Bebidas'),
  ('Postres');

insert into public.carta (categoria_id, nombre, precio)
select categoria.id, plato.nombre, plato.precio
from (
  values
    ('Entradas', 'Papa a la huancaína', 14.00::numeric),
    ('Entradas', 'Causa limeña', 16.00::numeric),
    ('Entradas', 'Tequeños', 18.00::numeric),
    ('Entradas', 'Anticuchos', 20.00::numeric),
    ('Entradas', 'Chicharrón de calamar', 22.00::numeric),
    ('Ceviches', 'Ceviche clásico', 28.00::numeric),
    ('Ceviches', 'Ceviche mixto', 32.00::numeric),
    ('Ceviches', 'Ceviche de pescado', 30.00::numeric),
    ('Ceviches', 'Leche de tigre', 16.00::numeric),
    ('Ceviches', 'Tiradito', 30.00::numeric),
    ('Fondos', 'Lomo saltado', 30.00::numeric),
    ('Fondos', 'Ají de gallina', 25.00::numeric),
    ('Fondos', 'Arroz con pollo', 24.00::numeric),
    ('Fondos', 'Tallarín verde con bistec', 29.00::numeric),
    ('Fondos', 'Seco de res', 28.00::numeric),
    ('Bebidas', 'Inca Kola personal', 7.00::numeric),
    ('Bebidas', 'Chicha morada', 8.00::numeric),
    ('Bebidas', 'Limonada', 9.00::numeric),
    ('Bebidas', 'Agua', 4.00::numeric),
    ('Bebidas', 'Cerveza', 12.00::numeric),
    ('Postres', 'Suspiro a la limeña', 12.00::numeric),
    ('Postres', 'Picarones', 10.00::numeric),
    ('Postres', 'Mazamorra morada', 8.00::numeric),
    ('Postres', 'Arroz con leche', 8.00::numeric),
    ('Postres', 'Helado', 9.00::numeric)
) as plato(categoria_nombre, nombre, precio)
join public.categoria as categoria on categoria.nombre = plato.categoria_nombre;
