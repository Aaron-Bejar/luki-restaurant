# Plan: Gestión de carta y categorías

## Resumen técnico

La carta se administrará mediante servicios de dominio y RPC PostgreSQL protegidas por sesión operativa. La interfaz de Carta vivirá en la navegación definida por `003-navegacion-y-pantallas`, pero las reglas de datos, permisos e integridad pertenecen a esta funcionalidad.

## Cambios previstos

- Mantener las entidades `categoria` y `carta` con nombres, estados, precios y relaciones.
- Exponer lecturas autorizadas de categorías y productos activos para `owner` y `waitress`.
- Exponer RPC de creación, actualización y baja lógica para categorías y productos solo para `owner`.
- Exponer una lectura autorizada de todas las categorías para la subpantalla de administración del `owner`, incluyendo categorías activas e inactivas.
- Exponer una RPC de eliminación de categoría que rechace la operación cuando exista cualquier producto vinculado.
- Validar nombre, precio, categoría y disponibilidad dentro de la base de datos.
- Impedir que la administración de carta modifique `detalle_pedido` histórico.
- Separar el servicio de carta de los servicios de mesas, pedidos y usuarios.
- Permitir que `001-gestion-mesas-pedidos` consuma productos vigentes sin duplicar las reglas de Carta.

## Datos e interfaces

| Entidad | Propósito | Integridad principal |
| --- | --- | --- |
| `categoria` | Agrupación de productos | Nombre válido; referencias de productos restringen eliminación |
| `carta` | Producto, precio y disponibilidad | Precio no negativo; categoría referenciada; baja lógica cuando corresponda |

Las RPC recibirán el token de sesión, derivarán el actor desde el servidor y validarán que sea un `owner` activo para cambios. Las lecturas para meseras devolverán únicamente datos activos.

## Organización de pantallas

### Pantalla Carta

La pantalla principal contiene:

1. Botón `+ Categoría`, visible solo para `owner`.
2. Botón `+ Producto`, visible solo para `owner`.
3. Etiquetas o chips de categorías creadas, con `Todas` como primera opción.
4. Lista de productos filtrada por la etiqueta seleccionada.

Las meseras ven las etiquetas y la lista de productos activos, pero no las acciones de administración. El producto conserva sus acciones de edición de disponibilidad y precio únicamente para `owner`.

### Subpantalla Categorías

La subpantalla es exclusiva de `owner` y se abre desde Carta. Debe mostrar todas las categorías creadas, incluidas las inactivas, con acciones para editar nombre, cambiar estado y eliminar.

La eliminación debe validarse en servidor dentro de la RPC. No basta con comprobar la lista cargada en la interfaz: cualquier producto vinculado, activo o inactivo, debe impedir la eliminación.

## Decisiones técnicas

| Decisión | Motivo |
| --- | --- |
| Funcionalidad independiente | Carta tiene ciclo de vida y permisos distintos de mesas y pedidos |
| Baja lógica como operación principal | Conserva referencias y permite mantener históricos |
| Snapshot en `detalle_pedido` | Evita que cambios futuros de Carta alteren ventas pasadas |
| RPC para escritura | Evita escrituras directas y centraliza autorización e integridad |
| Servicio dedicado | Evita mezclar administración de catálogo con operación de pedidos |

## Pruebas

- Verificar creación, actualización y baja lógica de categorías y productos.
- Verificar los botones de creación rápida y los formularios de categoría y producto.
- Verificar el filtrado por `Todas` y por cada etiqueta de categoría.
- Verificar que la subpantalla de Categorías muestre categorías activas e inactivas solo para `owner`.
- Verificar rechazo de nombres vacíos, duplicados, precios negativos y categorías inexistentes.
- Verificar que solo `owner` pueda modificar la carta.
- Verificar lectura de productos activos para `waitress`.
- Verificar que una cuenta inactiva o sesión inválida no pueda administrar la carta.
- Verificar bloqueo de eliminación cuando existan referencias.
- Verificar que una categoría con cualquier producto vinculado no pueda eliminarse y que una categoría sin productos sí pueda eliminarse.
- Verificar que cambios de precio o disponibilidad no modifiquen detalles históricos.
