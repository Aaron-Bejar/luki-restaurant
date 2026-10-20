# Arquitectura general

## Contexto

Aplicación móvil para siete dispositivos que gestionan mesas y comandas de un restaurante. Todos los dispositivos se conectan a una base PostgreSQL centralizada en Supabase. La cocina no usa dispositivos ni consume la aplicación directamente.

## Componentes

- Aplicación Expo: presenta las pantallas de acceso, mesas, comanda por persona, pago y administración exclusiva de carta, categorías y mesas para el dueño.
- Expo Router: organiza las rutas y separa los flujos operativos de los administrativos.
- Servicios de dominio: encapsulan las consultas y RPC de usuarios, carta, mesas y pedidos.
- Supabase JavaScript Client: conexión única del cliente móvil con Supabase.
- Supabase PostgreSQL: almacena datos históricos, aplica integridad relacional y ejecuta operaciones atómicas.

## Flujos principales

1. Un usuario identifica su turno mediante nombre y PIN de cuatro dígitos.
2. La mesera abre una mesa libre mediante una operación atómica que la ocupa y crea el pedido activo.
3. La mesera registra líneas de comanda agrupadas por `num_persona`; las correcciones cambian estado o cantidad, sin eliminarlas.
4. La aplicación calcula subtotales por persona y el total de líneas no canceladas.
5. La mesera confirma el método de pago y una operación atómica marca el pedido como pagado y libera la mesa.
6. El pedido pagado y sus líneas se mantienen como histórico; una nueva ocupación crea otro pedido.

## Integraciones externas

| Integración | Propósito | Propietario | Consideraciones |
| --- | --- | --- | --- |
| Supabase | PostgreSQL, API y RPC | Proyecto del restaurante | La clave de servicio no se distribuye a dispositivos móviles. |
| Expo | Ejecución y distribución de la app móvil | Proyecto del restaurante | Debe soportar los teléfonos definidos para la operación. |

## Decisiones transversales

- La base PostgreSQL de Supabase es la fuente de verdad única para todos los dispositivos.
- La apertura y el cierre de mesa se ejecutan mediante RPC transaccional para evitar estados parciales o pedidos activos duplicados.
- Solo el dueño administra registros de `mesas`; las meseras solo cambian su estado operativo al abrir o cerrar pedidos sobre mesas existentes.
- Una mesa con pedidos asociados no puede eliminarse, incluso desde la administración del dueño, debido a la referencia restrictiva de `pedido`.
- No se permite el borrado físico operativo de `detalle_pedido`; se usa cancelación lógica o cantidad 0 como evidencia auditable.
- El historial de pedidos pagados nunca se reutiliza: cada nueva ocupación crea un `id_pedido` nuevo.
