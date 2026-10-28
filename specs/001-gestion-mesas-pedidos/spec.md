# Especificación: Gestión de mesas, pedidos y detalle por persona

## Contexto y objetivo

El restaurante opera desde siete dispositivos móviles conectados a una única base de datos Supabase. Esta funcionalidad agrupa la estructura de mesas, los pedidos asociados a cada mesa y el detalle de consumo agrupado por persona.

La carta es una funcionalidad independiente definida en `004-gestion-carta`; este flujo solo consume productos vigentes para registrar comandas.

## Historias de usuario

Como mesera, quiero abrir una mesa libre para registrar la comanda de sus comensales.

Como mesera, quiero registrar, editar y cancelar ítems por persona sin perder el historial operativo.

Como mesera, quiero dividir visualmente la cuenta por persona y cerrar la mesa con un método de pago.

Como dueño, quiero crear, modificar y eliminar mesas sin afectar los pedidos históricos asociados.

Como dueño y mesera, quiero conservar los pedidos cancelados y pagados para consultar el historial.

## Requisitos funcionales

- RF-001: Al abrir una mesa libre, el sistema debe marcarla como `ocupada` y crear exactamente un pedido activo asociado al usuario de la sesión operativa en una única operación atómica.
- RF-002: Solo el rol `owner` puede crear, modificar o eliminar registros de `mesas`.
- RF-003: El rol `waitress` puede operar pedidos sobre mesas existentes, pero no puede crear, modificar ni eliminar registros de `mesas`.
- RF-004: La comanda debe agrupar sus líneas por `num_persona`, con numeración positiva iniciada en 1.
- RF-005: El sistema debe permitir agregar y modificar líneas mientras el pedido esté activo.
- RF-006: El sistema no debe borrar físicamente líneas de `detalle_pedido`. Una corrección debe marcar el ítem como `cancelado` o establecer su cantidad en 0.
- RF-007: Los subtotales por persona y el total de la mesa deben excluir líneas con estado `cancelado` o cantidad 0.
- RF-008: Al cobrar un pedido activo, el sistema debe registrar un método de pago válido, marcar el pedido como `pagado` y liberar la mesa en una única operación atómica.
- RF-009: Una mesa liberada debe crear un pedido nuevo al ocuparse nuevamente; los pedidos anteriores deben conservarse como histórico.
- RF-010: La eliminación de una mesa con pedidos asociados debe ser rechazada para preservar el histórico.
- RF-011: Cada línea debe conservar el nombre y precio del producto utilizados al momento de agregarla, aunque la carta cambie posteriormente.

## Requisitos no funcionales

- RNF-001: PostgreSQL administrado por Supabase es la única fuente central para los siete dispositivos concurrentes.
- RNF-002: Las tablas `mesas`, `pedido` y `detalle_pedido` deben aplicar claves, restricciones, valores por defecto e integridad referencial.
- RNF-003: La apertura de mesa y el cierre de pedido deben fallar sin efectos parciales.
- RNF-004: Ninguna operación autorizada debe aceptar un identificador de usuario enviado por el cliente como prueba de identidad.
- RNF-005: El cliente no debe registrar PINes, hashes ni credenciales con privilegios de servicio.

## Criterios de aceptación

- Dado una mesa libre, cuando una mesera la abre, entonces queda ocupada y existe un único pedido activo vinculado a ella.
- Dado que dos dispositivos intentan abrir la misma mesa libre simultáneamente, entonces solo una operación tiene éxito.
- Dado un pedido activo, cuando se agregan productos para personas distintas, entonces las líneas se visualizan y totalizan bajo cada persona.
- Dado un ítem ingresado por error, cuando se cancela, entonces persiste, queda cancelado o con cantidad 0 y no participa en el total.
- Dado un pedido activo, cuando se confirma un método de pago válido, entonces queda pagado y la mesa queda libre.
- Dado una mesa previamente pagada, cuando se abre nuevamente, entonces se crea un pedido distinto sin modificar el histórico.
- Dado una mesera autenticada, cuando intenta administrar una mesa, entonces la operación es rechazada.
- Dado una mesa con pedidos activos o históricos, cuando se intenta eliminar, entonces la operación es rechazada por integridad referencial.

## Casos límite

- Intentar abrir una mesa ocupada no crea otro pedido activo.
- Un pedido pagado no admite nuevas líneas ni modificaciones.
- Un cobro sin método válido no cambia el pedido ni la mesa.
- Una línea cancelada conserva su evidencia aunque el pedido quede sin ítems cobrables.
- Cambiar el precio o desactivar un producto en `004-gestion-carta` no modifica líneas históricas.

## Fuera de alcance

- Administración de categorías y productos; pertenece a `004-gestion-carta`.
- Gestión de cuentas de meseras; pertenece a `002-gestion-meseras`.
- Cocina, inventario, recetas, facturación, propinas y descuentos.
- Eliminación física de pedidos o detalles desde el flujo operativo.
