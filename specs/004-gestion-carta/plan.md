# Plan: Gestión de carta y categorías

## Resumen técnico

Servicios de dominio consumen RPC protegidas por sesión operativa. Las tablas
siguen sin escritura directa para el cliente. La carta completa es visible para
los dos roles; solo los platos activos son seleccionables en pedidos.

## Cambios previstos

- Normalizar y mantener siempre activas las categorías.
- Exponer lecturas autorizadas de categorías y todos los platos para ambos roles.
- Exponer RPC de creación, edición y eliminación de categoría, y de creación, edición y disponibilidad de plato, solo para owner.
- Eliminar en cascada los platos de una categoría confirmada y dejar `detalle_pedido.carta_id` en nulo, conservando los snapshots históricos.
- Mantener formularios y acciones administrativas en Carta únicamente para owner, y proteger la subpantalla Categorías por rol.
- Centralizar llamadas RPC en `src/services/carta.ts`; las pantallas reciben el token desde el contexto de sesión.

## Interfaces

| Operación | Actor | Resultado |
| --- | --- | --- |
| Listar Carta y categorías | owner, waitress | Categorías y platos, activos o no disponibles |
| Crear/editar/eliminar categoría | owner | Categoría creada, renombrada o eliminada con sus platos |
| Crear/editar/cambiar disponibilidad de plato | owner | Plato actualizado |

Cada RPC recibe el token de sesión y deriva el actor en PostgreSQL. `agregar_detalle_pedido` mantiene el rechazo de productos no disponibles.

## Pruebas

- RPC: autorización, token inválido, nombres normalizados, precio/categoría inválidos y cambio de disponibilidad.
- Histórico: borrado de categoría y platos con conservación de snapshots y anulación de `carta_id`.
- Aplicación: filtrado que conserva platos no disponibles y ocultamiento de controles administrativos para waitress.
