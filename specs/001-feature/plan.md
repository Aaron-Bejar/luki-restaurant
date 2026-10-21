# Plan: Pedidos por persona

## Resumen técnico

La aplicación móvil se organizará con Expo Router y módulos bajo `src/`. El cliente `@supabase/supabase-js` será el único acceso desde la aplicación a Supabase. PostgreSQL contendrá el esquema relacional, restricciones de integridad y operaciones RPC para las transiciones atómicas de apertura y cierre de mesa.

## Cambios previstos

- Crear una migración SQL con las tablas `usuario`, `categoria`, `carta`, `mesas`, `pedido` y `detalle_pedido`, sus claves foráneas, valores por defecto y restricciones `CHECK`.
- Crear índices para consultas de carta por categoría, pedido activo por mesa y detalles por pedido y persona.
- Implementar una operación transaccional para abrir una mesa libre y crear su pedido activo.
- Implementar una operación transaccional para cerrar un pedido activo, registrar el método de pago y liberar la mesa.
- Configurar las pantallas de acceso por PIN, mesas, detalle de pedido, pago y administración de carta y mesas.
- Separar el acceso a datos en servicios de usuarios, carta, mesas y pedidos.
- Aplicar controles de acceso para limitar la administración de carta, categorías y mesas al rol `owner`.

## Datos e interfaces

La aplicación usa las siguientes entidades persistidas:

| Entidad | Propósito | Integridad principal |
| --- | --- | --- |
| `usuario` | Identidad operativa y rol | PIN numérico de cuatro dígitos; rol `owner` o `waitress` |
| `categoria` | Agrupación de platos | No puede eliminarse si la carta la referencia |
| `carta` | Plato y precio vigente | Precio no negativo; categoría referenciada |
| `mesas` | Estructura física y estado de cada mesa | Solo `owner` la administra; pedidos asociados bloquean su eliminación |
| `pedido` | Cabecera histórica de consumo | Estado `activo` o `pagado`; método de pago validado |
| `detalle_pedido` | Líneas de comanda por persona | Cantidad no negativa; sin borrado operativo |

Las operaciones `abrir_mesa` y `cerrar_pedido` se expondrán como funciones PostgreSQL invocadas mediante RPC. Deben validar el estado actual antes de realizar cambios y fallar sin efectos parciales ante una condición inválida.

## Decisiones técnicas

| Decisión | Motivo |
| --- | --- |
| Expo Router para navegación | Mantiene rutas, layouts y pantallas móviles organizadas por flujo. |
| Servicios en `src/services` | Evita consultas Supabase dispersas en componentes de interfaz. |
| Operaciones de apertura y cierre mediante RPC | Garantiza consistencia cuando varios dispositivos actúan simultáneamente. |
| Cancelación lógica o cantidad 0 | Conserva la auditoría de comandas y evita borrado físico operativo. |
| `ON DELETE RESTRICT` en datos maestros | Evita destruir referencias históricas de carta, usuarios y mesas. |
| IDs operativos `integer identity`; `usuario.id` UUID | PostgreSQL asigna los IDs de entidades centralizadas y el UUID del usuario queda disponible para enlazar con Auth cuando se defina el mecanismo de inicio de sesión. |
| Administración de mesas solo para `owner` | Las meseras no pueden alterar la estructura de mesas ni afectar pedidos al intentar eliminar una mesa. |
| Clave anónima pública solo en el cliente | Impide exponer credenciales de servicio en los dispositivos. |
| Semilla de demostración sin usuarios | Las mesas y la carta de referencia son reproducibles; los usuarios y hashes bcrypt se cargan localmente fuera de Git. |

## Pruebas

- Verificar que cada `CHECK`, clave foránea y valor por defecto de la migración rechace o acepte los datos esperados.
- Verificar que solo una apertura concurrente de una misma mesa produzca un pedido activo.
- Verificar que el cierre actualice pedido, método de pago y mesa de forma atómica.
- Verificar que cancelar un ítem o asignarle cantidad 0 no ejecute borrado físico y lo excluya de los totales.
- Verificar subtotales por persona y total de mesa con ítems entregados, en cocina y cancelados.
- Verificar que `owner` administre carta, categorías y mesas, y que `waitress` no pueda crear, modificar ni eliminar registros de mesas.
- Verificar que no se pueda eliminar una mesa con pedidos activos o históricos.
