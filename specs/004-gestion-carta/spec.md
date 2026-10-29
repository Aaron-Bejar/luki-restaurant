# Especificación: Gestión de carta y categorías

## Contexto y objetivo

El owner administra las categorías y los platos de la carta. Owner y waitress
consultan todos los platos; el estado de disponibilidad solo determina si un
plato puede agregarse a un pedido. Esta funcionalidad es independiente de la
operación de mesas y pedidos de `001-gestion-mesas-pedidos`.

## Requisitos funcionales

- RF-001: Solo un `owner` activo con sesión válida puede crear, cambiar nombre o eliminar categorías.
- RF-002: Las categorías siempre permanecen activas; la interfaz y las RPC no exponen cambio de estado.
- RF-003: Solo un `owner` activo con sesión válida puede crear, editar o cambiar disponibilidad de platos.
- RF-004: Una categoría tiene nombre no vacío y único tras normalizar espacios y mayúsculas.
- RF-005: Un plato tiene nombre no vacío, precio no negativo, categoría existente y disponibilidad.
- RF-006: Owner y waitress consultan categorías y todos los platos mediante lectura autorizada.
- RF-007: Un plato no disponible se muestra, pero no puede agregarse a pedidos nuevos.
- RF-008: Al confirmar la eliminación de una categoría, se eliminan sus platos asociados. Los detalles históricos preservan nombre y precio y su `carta_id` pasa a nulo.
- RF-009: Seleccionar un plato disponible copia nombre y precio al detalle según `001-gestion-mesas-pedidos`.
- RF-010: Toda escritura administrativa se ejecuta por RPC; los componentes no escriben directamente en Supabase.
- RF-011: Carta muestra a owner `+ Producto`, el acceso a `Gestionar categorías`, etiquetas de categorías y acciones de edición/disponibilidad.
- RF-012: Carta muestra a waitress etiquetas y platos, sin controles administrativos.
- RF-013: Categorías es una subpantalla exclusiva de owner para crear, renombrar y eliminar tras confirmación.

## Requisitos no funcionales

- RNF-001: PostgreSQL en Supabase es la fuente de verdad para los siete dispositivos.
- RNF-002: Lecturas y cambios validan la sesión en servidor y derivan el actor desde el token.
- RNF-003: El cliente no usa UUID ni rol propios como prueba de autorización.
- RNF-004: PINes, hashes y tokens no se persisten ni se registran fuera de los mecanismos de sesión definidos.

## Criterios de aceptación

- Dado un owner activo, cuando crea o renombra una categoría válida, entonces queda disponible para organizar platos.
- Dado un owner activo, cuando crea o edita un plato válido, entonces queda asociado a su categoría y conserva su disponibilidad elegida.
- Dado una waitress autenticada, cuando consulta Carta, entonces recibe platos disponibles y no disponibles, sin acciones administrativas.
- Dado un plato no disponible, cuando se intenta agregar a un pedido, entonces el servidor rechaza la operación sin crear detalle.
- Dado una waitress o un token vencido, revocado o inventado, cuando intenta administrar Carta, entonces la operación se rechaza sin efectos parciales.
- Dado un owner, cuando confirma eliminar una categoría, entonces sus platos se eliminan y los detalles históricos conservan nombre y precio con `carta_id` nulo.
- Dado un usuario de Carta, cuando selecciona `Todas` o una categoría, entonces ve únicamente los platos del filtro elegido, incluidos los no disponibles.
- Dado un owner, cuando abre Categorías, entonces puede crear, renombrar y confirmar la eliminación de categorías.

## Casos límite

- No se acepta categoría o plato vacío, categoría duplicada, precio negativo o categoría inexistente.
- Sin categorías, el formulario de plato no puede guardar.
- Cambiar precio o disponibilidad no recalcula detalles ya registrados.
- No hay eliminación física de líneas de `detalle_pedido`.

## Fuera de alcance

- Inventario, recetas, costos, facturación, gestión de personal y operación de mesas o pagos.
