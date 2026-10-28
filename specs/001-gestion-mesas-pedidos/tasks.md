# Tareas: Gestión de mesas, pedidos y detalle por persona

- [x] T001 Crear la estructura Expo con Expo Router, TypeScript y los directorios `app/` y `src/` definidos en el plan.
- [x] T002 Configurar `@supabase/supabase-js` en `src/lib/supabase.ts` con variables de entorno para URL y clave anónima.
- [x] T003 Crear la migración inicial PostgreSQL con las tablas de mesas, pedidos y detalles, sus claves, restricciones, valores por defecto e índices.
- [x] T004 Mantener datos iniciales de demostración para mesas y catálogo; el catálogo se documenta y administra en `004-gestion-carta`.
- [x] T005 Añadir la migración de sesiones operativas y RPC de inicio/cierre de turno sin modificar migraciones aplicadas.
- [x] T006 Adaptar y probar las RPC transaccionales de apertura y cierre para derivar el actor de una sesión válida.
- [x] T007 Adaptar los servicios de mesas y pedidos a RPC o lecturas autorizadas.
- [x] T008 Implementar la pantalla de acceso por PIN, almacenamiento seguro de sesión, cierre de turno y permisos por rol.
- [x] T009 Implementar la pantalla de mesas con sus estados libre y ocupada.
- [ ] T010 Implementar la pantalla de pedidos por mesa con pedidos activos y pagados del día.
- [ ] T011 Implementar el detalle de pedido agrupado por persona, incluyendo alta, edición y cancelación lógica.
- [ ] T012 Implementar subtotales por persona y total de mesa excluyendo ítems cancelados.
- [ ] T013 Implementar el flujo de pago con selección obligatoria de método.
- [ ] T014 Añadir pruebas de restricciones, permisos, concurrencia, cierre atómico, totales e integridad histórica.
- [ ] T015 Verificar que una mesera no pueda crear, modificar ni eliminar mesas y que no exista impersonación mediante UUID.
