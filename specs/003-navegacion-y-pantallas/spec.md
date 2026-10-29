# Especificación: Navegación y pantallas de la aplicación

## Contexto y objetivo

La aplicación necesita una estructura de navegación clara para que `owner` y `waitress` operen mesas y pedidos, consulten la carta y accedan a su perfil. Esta especificación define navegación y presentación; las reglas de Carta viven en `004-gestion-carta` y las de personal en `002-gestion-meseras`.

## Estructura de navegación

Después de iniciar turno, la aplicación muestra un menú inferior con:

- Mesas: pantalla principal del salón.
- Carta: consulta para ambos roles y gestión exclusiva del dueño.
- Personal: gestión exclusiva del dueño.
- Perfil: datos de la sesión y cierre de turno.

## Pantallas

### Mesas

Debe mostrar el total de mesas, filtros de disponibles y ocupadas, búsqueda por número y una cuadrícula de dos columnas. Cada tarjeta muestra número y estado. Solo `owner` puede añadir automáticamente la siguiente mesa o eliminar una mesa.

Al seleccionar una mesa se mostrara la lista de pedidos tantos de pagados como el pendiente si esta en este momento y el boton para agregar un nuevo pedido

### Pedidos de una mesa

Debe mostrar una lista de pedidos históricos y pendientes sin ocultar los pagados solo del dia. Cada pedido muestra ticket, cantidad de personas, total y estado. Los pedidos pagados se muestran atenuados.

No se permite crear otro pedido si existe uno pendiente. El cierre debe usar el flujo transaccional de pago definido en `001-gestion-mesas-pedidos`.

### Detalle del pedido

Debe agrupar las líneas por persona, mostrar subtotal por persona y total general, permitir agregar productos por categoría y permitir modificaciones mediante actualización o cancelación lógica. Nunca se ejecuta `DELETE` sobre `detalle_pedido`.

### Carta

Debe mostrar `+ Producto` y el acceso a `Gestionar categorías` para el `owner`, las etiquetas de categorías para filtrar y debajo la lista de productos de la categoría seleccionada. Owner y meseras ven productos disponibles y no disponibles; estos últimos se distinguen y no pueden agregarse a un pedido. Las meseras no ven acciones administrativas. La gestión completa y la subpantalla de Categorías se especifican en `004-gestion-carta`.

### Subpantalla Categorías

Debe ser accesible únicamente para el `owner` desde Carta. Debe permitir crear, modificar nombre y confirmar la eliminación de categorías; esta elimina sus platos asociados y conserva snapshots de detalles históricos.

### Personal

Solo el dueño puede acceder. Debe listar meseras activas e inactivas y permitir alta, activación, desactivación y restablecimiento de PIN mediante las RPC administrativas de `002-gestion-meseras`.

### Perfil

Debe mostrar nombre y rol del usuario en sesión. Cerrar sesión revoca la sesión, elimina el token seguro y vuelve a la pantalla de PIN.

## Criterios de aceptación

- Dado un usuario autenticado, cuando entra a la aplicación, entonces ve las pestañas permitidas para su rol.
- Dado una mesera, cuando consulta Carta, entonces puede leer productos pero no ve acciones administrativas.
- Dado una mesera, cuando intenta abrir Personal, entonces el acceso es rechazado.
- Dado un dueño, cuando agrega una mesa, entonces se propone el siguiente número disponible y la creación se ejecuta mediante el servicio autorizado.
- Dado una mesa ocupada, cuando se selecciona, entonces se muestra su pedido activo y no se crea un pedido duplicado.
- Dado un pedido, cuando se cancela una línea, entonces permanece persistida, queda excluida del total y no se ejecuta `DELETE`.
- Dado un usuario autenticado, cuando cierra sesión, entonces vuelve a la pantalla de PIN y no puede operar con el token revocado.

## Fuera de alcance

- Cocina o dispositivo dedicado para cocina.
- Inventario, recetas y facturación.
- Escrituras directas desde componentes sobre Supabase.
