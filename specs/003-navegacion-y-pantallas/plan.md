# Plan: Navegación y pantallas de la aplicación

## Organización de rutas

Las rutas de Expo Router vivirán en `app/`. El flujo autenticado tendrá un layout protegido por sesión y un grupo de tabs para Mesas, Carta, Personal y Perfil. Las rutas secundarias de mesa y pedido vivirán fuera de las pestañas para conservar el tab activo durante la navegación.

```text
app/
├── (auth)/index.tsx
└── (app)/
    ├── _layout.tsx
    ├── (tabs)/
    │   ├── _layout.tsx
    │   ├── mesas/index.tsx
    │   ├── carta.tsx
    │   ├── personal.tsx
    │   └── perfil.tsx
    ├── categorias.tsx
    ├── mesas/[mesaId]/index.tsx
    └── pedidos/[pedidoId].tsx
```

## Wireframes de baja fidelidad

Estos wireframes describen la distribución y jerarquía visual de las pantallas. No representan estilos finales, colores, iconos ni componentes técnicos.

### Mesas

```text
+--------------------------------------------------+
| Salón                              [ + Mesa ]    |
| Mesas                                            |
| 7 mesas registradas                              |
| [ Buscar por número___________________________ ] |
| [ Todas ] [ Disponibles ] [ Ocupadas ]           |
|                                                  |
| +----------------------+  +-------------------+ |
| | Mesa 1               |  | Mesa 2            | |
| | Libre                |  | Ocupada           | |
| +----------------------+  +-------------------+ |
| | Mesa 3               |  | Mesa 4            | |
| | Libre                |  | Libre             | |
| +----------------------+  +-------------------+ |
|                                                  |
| Mesas: owner puede agregar y eliminar            |
+--------------------------------------------------+
```

`owner` puede ver `+ Mesa` y eliminar mesas (cada mesa tendra su boton eliminar). `waitress` solo puede consultar y operar mesas existentes.

### Pedidos de una mesa

```text
+--------------------------------------------------+
| < Volver                                         |
| Comandas                                         |
| Mesa #5                              [ + Pedido ] |
|                                                  |
| +----------------------------------------------+ |
| | Pedido #104                         Pendiente | |
| | 4 personas                         S/ 86.50  | |
| +----------------------------------------------+ |
|                                                  |
| +----------------------------------------------+ |
| | Pedido #103                           Pagado  | |
| | 2 personas                         S/ 42.00  | |
| +----------------------------------------------+ |
|                                                  |
| [ + Añadir pedido ]                              |
+--------------------------------------------------+
```

Se muestran los pedidos pagados del día y el pedido pendiente. Si existe un pedido pendiente, `+ Añadir pedido` permanece deshabilitado.

### Detalle de pedido

```text
+--------------------------------------------------+
| < Volver                         Pedido #104     |
| Detalle por persona                 Total S/ 86.50|
|                                                  |
| Persona 1                         Subtotal S/ 32 |
| +----------------------------------------------+ |
| | 1 x Plato principal                 S/ 22.00 | |
| | 1 x Bebida                          S/ 10.00 | |
| |                         [ Editar ] [ Cancelar ]|
| +----------------------------------------------+ |
|                                                  |
| Persona 2                         Subtotal S/ 54 |
| +----------------------------------------------+ |
| | 2 x Plato principal                 S/ 44.00 | |
| | 1 x Postre                           S/ 10.00 | |
| +----------------------------------------------+ |
|                                                  |
| [ Persona 1 ] [ + Añadir producto ]              |
+--------------------------------------------------+
```

Las líneas canceladas permanecen visibles como historial, pero no participan en los subtotales ni en el total.

### Carta

```text
+--------------------------------------------------+
| Menú                         [ + Producto ]       |
|                              [ Gestionar categorías ]|
| Carta                                            |
|                                                  |
| [ Todas ] [ Entradas ] [ Fondos ] [ Bebidas ]    |
|                                                  |
| Productos de la categoría seleccionada           |
| +----------------------------------------------+ |
| | Lomo saltado                    S/ 22.00     | |
| | Disponible                    [ Editar ]     | |
| +----------------------------------------------+ |
| | Inca Kola                       S/ 6.00      | |
| | Disponible                    [ Agotado ]    | |
| +----------------------------------------------+ |
+--------------------------------------------------+
```

Los botones administrativos y las acciones de edición solo aparecen para `owner`. `waitress` ve las categorías y todos los productos, incluidos los no disponibles, sin acciones de modificación.

### Categorías

```text
+--------------------------------------------------+
| < Volver              Categorías  [ + Categoría ]|
|                                                  |
| +----------------------------------------------+ |
| | Entradas                         Activa       | |
| |                         [ Editar ] [ Eliminar ]|
| +----------------------------------------------+ |
| | Fondos                           Activa       | |
| |                         [ Editar ] [ Eliminar ]|
| +----------------------------------------------+ |
| | Temporada                        Inactiva     | |
| |                         [ Editar ] [ Eliminar ]|
| +----------------------------------------------+ |
|                                                  |
| Eliminar solo si no tiene productos vinculados  |
+--------------------------------------------------+
```

La pantalla es exclusiva de `owner`: permite crear, renombrar y eliminar categorías tras confirmación. La eliminación borra sus productos asociados; los detalles históricos mantienen sus snapshots según `004-gestion-carta`.

### Meseras / Personal

```text
+--------------------------------------------------+
| Equipo                              [ + Mesera ] |
| Personal                                         |
| [ Activas ] [ Inactivas ]                        |
|                                                  |
| +----------------------------------------------+ |
| | Ana Pérez                         Activa     | |
| |                         [ Editar estado ]    | |
| |                         [ Restablecer PIN ]  | |
| +----------------------------------------------+ |
| | María López                       Inactiva   | |
| |                         [ Activar ]          | |
| +----------------------------------------------+ |
+--------------------------------------------------+
```

La pantalla es exclusiva de `owner`. Los PINes nunca se muestran; solo se permite establecer o restablecerlos mediante el flujo seguro definido en `002-gestion-meseras`.

### Perfil

```text
+--------------------------------------------------+
| Cuenta                                           |
| Mi perfil                                        |
|                                                  |
|                 [ Inicial ]                       |
|                                                  |
| Nombre del usuario                               |
| Rol: Owner / Mesera                              |
|                                                  |
|                                                  |
|                                                  |
| [              Cerrar sesión                  ]  |
+--------------------------------------------------+
```

El cierre de sesión revoca la sesión operativa, elimina el token seguro y devuelve al usuario a la pantalla de PIN.

## Código reutilizable

Los componentes compartidos vivirán en `src/components/`, separados por dominio: `mesas`, `pedidos`, `carta` y `personal`. Los componentes no realizarán consultas directas; usarán servicios de `src/services/` y la sesión de `src/auth/`.

## Autorización

El layout autenticado aceptará `owner` y `waitress`. Personal y las acciones de administración se ocultarán o protegerán para `waitress`. La visibilidad de un botón no sustituye las RPC ni las políticas del servidor.

## Datos y transacciones

- Mesas y pedidos usarán los servicios existentes.
- Abrir mesa y cerrar pedido conservarán sus RPC atómicas.
- Detalles cancelados se conservarán con `estado_item = 'cancelado'` o cantidad cero.
- Carta y su subpantalla Categorías requieren las RPC y reglas administrativas documentadas en `004-gestion-carta`.
- Personal requiere las RPC administrativas documentadas en `002-gestion-meseras`.
- Los pedidos consumen productos vigentes de Carta, pero sus reglas de mesas, pedidos y detalles pertenecen a `001-gestion-mesas-pedidos`.

## Decisiones

- Tabs inferiores para las áreas principales porque son destinos frecuentes.
- Rutas secundarias para pedido y detalle para evitar mezclar estados de navegación con el tab.
- Filtros y búsqueda de mesas en la interfaz para respuesta inmediata sobre el conjunto ya autorizado.
- Estados de carga, vacío y error en cada pantalla de datos.

## Pruebas

- Verificar redirección por sesión y protección por rol.
- Verificar visibilidad de pestañas y acciones para `owner` y `waitress`.
- Verificar navegación mesa → pedido → detalle.
- Verificar que totales excluyan líneas canceladas.
- Verificar cierre de sesión y revocación del token.
