# Plan: Gestión de mesas, pedidos y detalle por persona

## Resumen técnico

La aplicación móvil usará Expo Router y módulos bajo `src/`. PostgreSQL contendrá las entidades y restricciones de mesas, pedidos y detalles, además de las RPC para apertura y cierre atómicos. La carta será consultada mediante los servicios definidos en `004-gestion-carta`, pero no se administra dentro de esta funcionalidad.

## Cambios previstos

- Mantener las tablas `mesas`, `pedido` y `detalle_pedido` con sus claves, restricciones y relaciones.
- Mantener los índices para pedido activo por mesa y detalles por pedido y persona.
- Mantener RPC transaccionales para abrir una mesa libre y cerrar un pedido activo.
- Implementar lectura de pedidos históricos y activos por mesa.
- Implementar alta, edición y cancelación lógica de líneas agrupadas por persona.
- Implementar subtotales por persona, total de mesa y pago con método obligatorio.
- Separar el acceso a datos en servicios de mesas y pedidos.
- Consumir el catálogo activo de `004-gestion-carta` sin duplicar sus reglas de administración.

## Datos e interfaces

| Entidad | Propósito | Integridad principal |
| --- | --- | --- |
| `mesas` | Estructura física y estado | Solo `owner` la administra; pedidos asociados bloquean su eliminación |
| `pedido` | Cabecera histórica de consumo | Estado `activo` o `pagado`; método de pago válido |
| `detalle_pedido` | Líneas por persona | Cantidad no negativa; sin borrado operativo; conserva nombre y precio |

Las operaciones `abrir_mesa` y `cerrar_pedido` reciben una sesión operativa, derivan el actor en el servidor, validan el estado actual y fallan sin efectos parciales.

## Decisiones técnicas

| Decisión | Motivo |
| --- | --- |
| Agrupar mesas, pedidos y detalles | Una mesa contiene pedidos y cada pedido contiene sus líneas por persona |
| RPC para apertura y cierre | Evita pedidos activos duplicados y estados parciales bajo concurrencia |
| Cancelación lógica o cantidad 0 | Conserva auditoría sin borrar detalles |
| Historial inmutable de pedidos pagados | Una nueva ocupación crea un pedido nuevo |
| Snapshot de nombre y precio en el detalle | Los cambios futuros de Carta no alteran ventas históricas |
| Administración de mesas solo para `owner` | Las meseras operan mesas existentes sin modificar su estructura |

## Pruebas

- Verificar restricciones y relaciones de `mesas`, `pedido` y `detalle_pedido`.
- Verificar una sola apertura exitosa bajo concurrencia.
- Verificar cierre atómico con método de pago.
- Verificar subtotales y totales excluyendo líneas canceladas o con cantidad 0.
- Verificar que cancelar una línea no ejecute `DELETE`.
- Verificar que una mesa con pedidos no pueda eliminarse.
- Verificar que una mesera no pueda administrar mesas.
- Verificar que cambios de Carta no modifiquen detalles históricos.
