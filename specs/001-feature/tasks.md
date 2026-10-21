# Tareas: Pedidos por persona

- [x] T001 Crear la estructura Expo con Expo Router, TypeScript y los directorios `app/` y `src/` definidos en el plan.
- [x] T002 Configurar `@supabase/supabase-js` en `src/lib/supabase.ts` con variables de entorno para URL y clave anónima.
- [x] T003 Crear la migración inicial PostgreSQL con las tablas, claves, restricciones `CHECK`, valores por defecto e índices especificados.
- [x] T004 Crear datos iniciales de demostración: siete mesas, cinco categorías y veinticinco platos; aprovisionar usuarios operativos localmente con hashes bcrypt fuera de Git.
- [x] T005 Implementar la RPC transaccional de apertura de mesa que impida más de un pedido activo por mesa.
- [x] T006 Implementar la RPC transaccional de cierre de pedido que persista el método de pago y libere la mesa.
- [x] T007 Implementar servicios de usuarios, carta, mesas y pedidos sin consultas Supabase directamente desde componentes de interfaz.
- [ ] T008 Implementar la pantalla de acceso por PIN y la aplicación de permisos de interfaz por rol.
- [ ] T009 Implementar la pantalla de mesas con sus estados libre y ocupada.
- [ ] T010 Implementar la pantalla de pedido agrupada por persona, incluyendo alta, edición y cancelación lógica de líneas.
- [ ] T011 Implementar subtotales por persona y total de mesa excluyendo ítems cancelados.
- [ ] T012 Implementar el flujo de pago con selección obligatoria de método de pago.
- [ ] T013 Implementar la administración de categorías, carta y mesas restringida al rol `owner`.
- [ ] T014 Añadir pruebas de migración para restricciones de rol, PIN, cantidades, estados, claves foráneas y bloqueo de eliminación de mesas con pedidos.
- [ ] T015 Añadir pruebas de concurrencia para la apertura de una misma mesa desde dos dispositivos.
- [ ] T016 Añadir pruebas de cierre atómico, cálculo de totales y persistencia de ítems cancelados sin `DELETE`.
- [ ] T017 Verificar que una mesera no pueda crear, modificar ni eliminar mesas y que todos los criterios de aceptación de `spec.md` se cumplan en un entorno Supabase de prueba.
