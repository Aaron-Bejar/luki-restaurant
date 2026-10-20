# Instrucciones para agentes

## Flujo obligatorio

1. Lee `.specify/memory/constitution.md` antes de proponer cambios.
2. Consulta la especificación de la funcionalidad en `specs/`.
3. Respeta el orden `spec.md`, `plan.md` y `tasks.md`.
4. Mantén las pruebas y la documentación alineadas con el comportamiento implementado.
5. Antes de implementar una tarea, confirma que sus criterios de aceptación están definidos en la especificación.
6. Documenta en `specs/_global/` toda decisión que afecte a más de una funcionalidad.

## Convenciones

- Nombra las funcionalidades como `NNN-nombre-corto`.
- Mantén los requisitos verificables.
- Usa TypeScript para el código de la aplicación.
- Mantén las rutas de Expo Router en `app/` y el código reutilizable en `src/`.
- Centraliza el cliente de Supabase en `src/lib/supabase.ts`; no lo instancies desde componentes.
- Usa NativeWind v4 y Tailwind CSS para estilos de interfaz. Reserva estilos locales para casos no expresables con utilidades.
- No expongas variables de entorno sensibles, claves de servicio de Supabase ni PINes en código, documentación o registros.

## Reglas de dominio

- PostgreSQL en Supabase es la única fuente de verdad para los siete dispositivos móviles.
- Solo el rol `owner` puede crear, modificar o eliminar registros de `mesas`, `categoria` y `carta`.
- El rol `waitress` opera comandas sobre mesas existentes. Puede ocupar o liberar una mesa mediante el flujo de pedido, pero no puede crear, modificar ni eliminar registros de `mesas`.
- La apertura de mesa y el cierre de pedido deben ser operaciones atómicas ejecutadas mediante RPC PostgreSQL.
- No ejecutes `DELETE` para corregir líneas de `detalle_pedido`. Usa `estado_item = 'cancelado'` o `cantidad = 0`.
- No elimines una mesa que tenga pedidos activos o históricos; la integridad referencial debe preservar esos registros.
- Un pedido pagado es histórico y no se reutiliza ni se modifica. Una nueva ocupación de la mesa crea un pedido nuevo.

## Verificación

- Añade o actualiza pruebas para restricciones de base de datos, permisos y flujos transaccionales cuando cambie el comportamiento.
- Verifica específicamente concurrencia al abrir mesas, cálculo de totales sin ítems cancelados y cierre atómico con método de pago.
- No marques una tarea de `tasks.md` como terminada hasta que su implementación, pruebas y documentación estén alineadas.
