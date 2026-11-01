-- Ejecutar íntegro en SQL Editor después de la migración. ROLLBACK descarta los datos.
-- Las secuencias de identificadores pueden avanzar aun con ROLLBACK.
begin;
do $$
declare
  sufijo text := replace(gen_random_uuid()::text, '-', '');
  owner_id uuid; mesera_id uuid; token_owner text := encode(extensions.gen_random_bytes(32), 'hex');
  token_mesera text := encode(extensions.gen_random_bytes(32), 'hex');
  categoria_id integer := -2000000001; plato_id integer := -2000000002;
  otro_id integer := -2000000003; mesa_id integer := -2000000004;
  pedido_id integer := -2000000005; detalle_id integer; nombre_categoria text;
begin
  nombre_categoria := 'Prueba carta ' || sufijo;
  insert into public.usuario(nombre,pin_hash,rol) values ('Owner ' || sufijo, extensions.crypt('1234',extensions.gen_salt('bf',10)), 'owner') returning id into owner_id;
  insert into public.usuario(nombre,pin_hash,rol) values ('Mesera ' || sufijo, extensions.crypt('1234',extensions.gen_salt('bf',10)), 'waitress') returning id into mesera_id;
  insert into public.sesion_operativa(usuario_id,token_hash,expira_en) values
    (owner_id,private.hash_token_sesion(token_owner),now()+interval '1 hour'),
    (mesera_id,private.hash_token_sesion(token_mesera),now()+interval '1 hour');
  insert into public.categoria(id,nombre) values(categoria_id,nombre_categoria);
  insert into public.carta(id,categoria_id,nombre,precio) values
    (plato_id,categoria_id,'Plato ' || sufijo,12.50),
    (otro_id,categoria_id,'Otro ' || sufijo,10);
  insert into public.mesas(id,numero) values(mesa_id, (select coalesce(max(numero),0)+1 from public.mesas));
  insert into public.pedido(id,mesa_id,abierto_por_usuario_id) values(pedido_id,mesa_id,owner_id);
  perform public.establecer_disponibilidad_plato(token_owner,otro_id,false);
  begin
    perform public.agregar_detalle_pedido(token_mesera,pedido_id,otro_id,1,1);
    raise exception 'Se agregó un plato no disponible';
  exception when no_data_found then null; end;
  perform public.establecer_disponibilidad_plato(token_owner,otro_id,true);
  perform public.eliminar_plato(token_owner,otro_id);
  begin
    perform public.agregar_detalle_pedido(token_mesera,pedido_id,otro_id,1,1);
    raise exception 'Se agregó un plato eliminado';
  exception when no_data_found then null; end;
  perform public.restaurar_plato(token_owner,otro_id);
  perform public.establecer_disponibilidad_plato(token_owner,otro_id,false);
  perform public.eliminar_plato(token_owner,otro_id);
  select id into detalle_id from public.agregar_detalle_pedido(token_owner,pedido_id,plato_id,1,1);
  perform public.eliminar_categoria(token_owner,categoria_id);
  begin
    perform public.agregar_detalle_pedido(token_mesera,pedido_id,plato_id,1,1);
    raise exception 'Se agregó un plato de categoría eliminada';
  exception when no_data_found then null; end;
  update public.pedido set estado='pagado',metodo_pago='efectivo',cerrado_en=now() where id=pedido_id;
  perform public.restaurar_categoria(token_owner,categoria_id);
  perform public.eliminar_categoria(token_owner,categoria_id);
  if exists(select 1 from public.listar_carta(token_mesera) where id in (plato_id,otro_id)) then raise exception 'Categoría eliminada visible'; end if;
  if not exists(select 1 from public.detalle_pedido where id=detalle_id and carta_id=plato_id and nombre_plato='Plato ' || sufijo and precio_unitario=12.50) then raise exception 'Histórico alterado'; end if;
  begin perform public.restaurar_plato(token_owner,otro_id); raise exception 'Se restauró plato con categoría eliminada'; exception when no_data_found then null; end;
  begin perform public.crear_categoria(token_owner,nombre_categoria); raise exception 'Nombre duplicado aceptado'; exception when unique_violation then null; end;
  begin perform public.restaurar_categoria(token_mesera,categoria_id); raise exception 'Mesera autorizada'; exception when insufficient_privilege then null; end;
  begin perform public.listar_carta(repeat('0',64)); raise exception 'Token inventado aceptado'; exception when invalid_authorization_specification then null; end;
  perform public.restaurar_categoria(token_owner,categoria_id);
  if not exists(select 1 from public.listar_carta(token_mesera) where id=plato_id) or exists(select 1 from public.listar_carta(token_mesera) where id=otro_id) then raise exception 'Restauración de categoría incorrecta'; end if;
  perform public.restaurar_plato(token_owner,otro_id);
  if not exists(select 1 from public.listar_carta(token_mesera) where id=otro_id and not activo) then raise exception 'Disponibilidad no conservada'; end if;
  perform set_config('luki_test.token_owner', token_owner, true);
  perform set_config('luki_test.token_mesera', token_mesera, true);
end;
$$;
-- Comprobar la vía de acceso real de la aplicación, no solo como administrador SQL.
set local role anon;
do $$
declare
  token_owner text := current_setting('luki_test.token_owner');
  token_mesera text := current_setting('luki_test.token_mesera');
begin
  perform public.eliminar_plato(token_owner, -2000000003);
  perform public.restaurar_plato(token_owner, -2000000003);
  perform public.listar_platos_eliminados(token_owner);
  perform public.listar_categorias_eliminadas(token_owner);
  perform public.eliminar_categoria(token_owner, -2000000001);
  perform public.restaurar_categoria(token_owner, -2000000001);
  begin
    perform public.eliminar_plato(token_mesera, -2000000003);
    raise exception 'La mesera pudo eliminar un plato';
  exception when insufficient_privilege then null; end;
  begin
    perform public.listar_platos_eliminados(repeat('0', 64));
    raise exception 'Se aceptó un token inventado';
  exception when invalid_authorization_specification then null; end;
  if has_table_privilege('anon', 'public.carta', 'INSERT,UPDATE,DELETE')
    or has_table_privilege('anon', 'public.categoria', 'INSERT,UPDATE,DELETE') then
    raise exception 'anon tiene escritura directa en tablas de Carta';
  end if;
end;
$$;
reset role;
rollback;
