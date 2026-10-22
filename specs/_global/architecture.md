# Arquitectura general

## Contexto

Aplicación móvil para siete dispositivos que gestionan mesas y comandas de un restaurante. Todos los dispositivos se conectan a una base PostgreSQL centralizada en Supabase. La cocina no usa dispositivos ni consume la aplicación directamente.

## Componentes

- Aplicación Expo: presenta las pantallas de acceso, mesas, comanda por persona, pago y administración exclusiva de carta, categorías, mesas y meseras para el dueño.
- Expo Router: organiza las rutas y separa los flujos operativos de los administrativos.
- Servicios de dominio: encapsulan RPC de lectura y escritura autorizadas de usuarios, carta, mesas y pedidos.
- Supabase JavaScript Client: conexión única del cliente móvil con Supabase.
- Supabase PostgreSQL: almacena datos históricos, aplica integridad relacional y ejecuta operaciones atómicas.

## Flujos principales

1. Un usuario inicia turno mediante un PIN único de cuatro dígitos; el servidor devuelve una sesión operativa de duración limitada.
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
- Los PINes operativos son únicos entre cuentas activas y se guardan únicamente como hashes bcrypt en PostgreSQL; su validación se hará del lado del servidor y nunca se persistirán ni registrarán en texto plano en la aplicación.
- La sesión operativa se prueba con un token aleatorio cuyo hash guarda PostgreSQL; las RPC derivan el actor de esa sesión y no aceptan un UUID del cliente como prueba de identidad. Véase `autorizacion-y-sesiones.md`.
- Solo un owner activo validado por el servidor puede crear, activar, desactivar o restablecer el PIN de una cuenta `waitress`; estas operaciones usan RPC y no permiten escrituras directas desde el cliente sobre `usuario`.
- La desactivación de una mesera es una baja lógica (`usuario.activo = false`): preserva los pedidos asociados y bloquea futuros inicios de turno.
- Las tablas operativas comienzan con RLS habilitado y sin privilegios para `anon` ni `authenticated`; las tareas posteriores expondrán solo las políticas y RPC necesarias para cada rol.
