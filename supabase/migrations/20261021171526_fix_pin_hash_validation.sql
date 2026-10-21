-- Corrige el patrón aplicado inicialmente para que acepte hashes bcrypt válidos.
alter table public.usuario
  drop constraint usuario_pin_hash_check;

alter table public.usuario
  add constraint usuario_pin_hash_check
  check (pin_hash ~ $$^\$2[aby]\$[0-9]{2}\$[./A-Za-z0-9]{53}$$);
