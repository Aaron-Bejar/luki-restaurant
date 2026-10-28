# Especificación: Gestión de carta y categorías

## Contexto y objetivo

El dueño necesita administrar las categorías y productos que componen la carta. Las meseras consultan únicamente los productos disponibles para registrar pedidos en las mesas. Esta funcionalidad es independiente de la gestión de mesas, pedidos y detalle definida en `001-gestion-mesas-pedidos`.

## Historias de usuario

Como dueño, quiero crear y modificar categorías para organizar la carta.

Como dueño, quiero crear productos con nombre, precio y categoría.

Como dueño, quiero cambiar la disponibilidad de un producto sin perder su uso histórico en pedidos.

Como dueño, quiero consultar una pantalla exclusiva de categorías para modificar o eliminar las categorías que he creado.

Como mesera, quiero consultar la carta activa para agregar productos a un pedido.

## Requisitos funcionales

- RF-001: Solo un `owner` activo con una sesión operativa válida puede crear, modificar o desactivar categorías.
- RF-002: Solo un `owner` activo con una sesión operativa válida puede crear, modificar o desactivar productos.
- RF-003: Una categoría debe tener un nombre no vacío y un estado `activo` o `inactivo`.
- RF-004: Un producto debe tener un nombre no vacío, un precio no negativo, una categoría existente y un estado de disponibilidad.
- RF-005: Una `waitress` puede consultar categorías y productos activos mediante una lectura autorizada (no pueden modificar nada de la carta).
- RF-006: Desactivar una categoría debe impedir que sus productos se ofrezcan para nuevos pedidos, sin modificar detalles históricos.
- RF-007: Desactivar un producto debe impedir que se agregue a nuevos pedidos, sin modificar detalles históricos.
- RF-008: La eliminación física de una categoría o producto solo puede intentarse cuando la integridad referencial lo permita; de lo contrario debe rechazarse.
- RF-009: La selección de un producto para un pedido debe copiar su nombre y precio al detalle del pedido según las reglas de `001-gestion-mesas-pedidos`.
- RF-010: Las operaciones administrativas deben ejecutarse mediante RPC y nunca mediante escrituras directas desde el cliente móvil.
- RF-011: La pantalla de Carta debe ofrecer al `owner` un botón `+ Categoría` y un botón `+ Producto` para crear rápidamente cada tipo de registro.
- RF-012: La pantalla de Carta debe mostrar etiquetas de categorías debajo de los botones administrativos para filtrar la lista de productos.
- RF-013: La etiqueta `Todas` debe permitir mostrar todos los productos activos; al seleccionar una categoría, la lista debe mostrar solo sus productos activos.
- RF-014: El `owner` debe disponer de una subpantalla exclusiva de Categorías para consultar, editar, activar, desactivar y eliminar las categorías creadas.
- RF-015: Una categoría solo puede eliminarse cuando no tiene productos vinculados, estén estos activos o inactivos. Si existen productos vinculados, la eliminación debe rechazarse.

## Requisitos no funcionales

- RNF-001: PostgreSQL en Supabase es la fuente de verdad de categorías y productos para los siete dispositivos.
- RNF-002: Las lecturas y cambios deben validar la sesión en el servidor y derivar el actor desde el token.
- RNF-003: El cliente no debe confiar en un UUID o rol enviado por la interfaz para autorizar cambios.
- RNF-004: Los cambios de disponibilidad no deben alterar pedidos históricos ni detalles existentes.

## Criterios de aceptación

- Dado un `owner` activo, cuando crea una categoría válida, entonces queda disponible para organizar productos.
- Dado un `owner` activo, cuando crea un producto válido, entonces queda asociado a la categoría y puede consultarse según su estado.
- Dado una mesera autenticada, cuando consulta la carta, entonces recibe solo categorías y productos activos autorizados.
- Dado una mesera autenticada, cuando intenta crear, modificar o desactivar una categoría o producto, entonces la operación es rechazada.
- Dado un producto usado en un pedido histórico, cuando se desactiva, entonces el detalle histórico permanece sin cambios.
- Dado una categoría con productos referenciados, cuando se intenta eliminar, entonces la operación se rechaza por integridad referencial.
- Dado un producto activo seleccionado en un pedido, cuando se agrega, entonces el detalle conserva el nombre y precio vigentes en ese momento.
- Dado un token vencido, revocado o inventado, cuando se intenta administrar la carta, entonces la operación es rechazada sin efectos parciales.
- Dado un `owner` en Carta, cuando pulsa `+ Categoría`, entonces puede crear una categoría desde un formulario rápido con nombre y estado activo por defecto.
- Dado un `owner` en Carta, cuando pulsa `+ Producto`, entonces puede crear un producto con nombre, precio, categoría y disponibilidad activa por defecto.
- Dado un `owner`, cuando entra a Categorías, entonces puede ver todas las categorías creadas y acceder a sus acciones de edición, estado y eliminación.
- Dado una categoría sin productos vinculados, cuando el `owner` confirma su eliminación, entonces la categoría se elimina correctamente.
- Dado una categoría con productos vinculados, cuando el `owner` intenta eliminarla, entonces la operación se rechaza y la categoría se conserva.
- Dado un usuario que consulta Carta, cuando selecciona una etiqueta de categoría, entonces la lista se filtra sin mostrar productos de otras categorías.

## Casos límite

- No se acepta una categoría con nombre vacío o duplicado según la normalización definida.
- No se acepta un producto con precio negativo o categoría inexistente.
- Desactivar una categoría o producto es una baja lógica cuando existen referencias históricas.
- Un cambio posterior de precio no recalcula pedidos ya registrados.
- Una categoría con productos vinculados no puede eliminarse aunque todos sus productos estén inactivos.
- Si no existen categorías, el formulario de producto no puede guardar hasta que se cree una categoría válida.

## Fuera de alcance

- Inventario, recetas, costos de insumos y control de existencias.
- Gestión de cuentas de meseras.
- Operación de mesas, pedidos y pagos.
- Facturación electrónica, descuentos e impuestos adicionales.
