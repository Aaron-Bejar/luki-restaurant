-- Verificación de autenticación, revocación y nombres normalizados.
-- Ejecutar contra una base de pruebas o una transacción descartable.

begin;

do $$
declare
  token_sesion_test text;
  sesion_id_test uuid;
begin
  insert into public.usuario (nombre, pin_hash, rol)
  values (
    'Mesera Sesión',
    extensions.crypt('1234', extensions.gen_salt('bf', 10)),
    'waitress'
  );

  select token_sesion
  into token_sesion_test
  from public.iniciar_turno('1234');

  if token_sesion_test !~ '^[0-9a-f]{64}$' then
    raise exception 'El inicio de turno no devolvió un token de sesión válido.';
  end if;

  select id
  into sesion_id_test
  from public.sesion_operativa
  where token_hash = encode(extensions.digest(token_sesion_test, 'sha256'), 'hex');

  if sesion_id_test is null then
    raise exception 'La sesión no se almacenó con el hash del token.';
  end if;

  begin
    perform public.iniciar_turno('0000');
    raise exception 'Se aceptó un PIN incorrecto.';
  exception
    when sqlstate '28000' then null;
  end;

  insert into public.usuario (nombre, pin_hash, rol, activo)
  values ('Mesera inactiva', extensions.crypt('0001', extensions.gen_salt('bf', 10)), 'waitress', false);

  begin
    perform public.iniciar_turno('0001');
    raise exception 'Se aceptó el PIN de una cuenta inactiva.';
  exception
    when sqlstate '28000' then null;
  end;

  begin
    perform private.verificar_pin_disponible('1234');
    raise exception 'Se aceptó un PIN ya asignado a una cuenta activa.';
  exception
    when unique_violation then null;
  end;

  insert into public.usuario (nombre, pin_hash, rol)
  values ('PIN duplicado de prueba', extensions.crypt('1234', extensions.gen_salt('bf', 10)), 'waitress');

  begin
    perform public.iniciar_turno('1234');
    raise exception 'Se aceptó un PIN ambiguo.';
  exception
    when sqlstate '28000' then null;
  end;

  begin
    insert into public.usuario (nombre, pin_hash, rol)
    values ('MESERA SESIÓN', extensions.crypt('4321', extensions.gen_salt('bf', 10)), 'waitress');
    raise exception 'Se aceptó un nombre duplicado sin distinguir mayúsculas.';
  exception
    when unique_violation then null;
  end;

  perform public.cerrar_turno(token_sesion_test);

  begin
    perform public.cerrar_turno(token_sesion_test);
    raise exception 'Se reutilizó una sesión revocada.';
  exception
    when sqlstate '28000' then null;
  end;

  begin
    perform public.abrir_mesa(1, repeat('0', 64));
    raise exception 'Se aceptó un token inventado.';
  exception
    when sqlstate '28000' then null;
  end;
end;
$$;

rollback;
