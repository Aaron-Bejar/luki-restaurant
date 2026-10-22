# Autorización y sesiones operativas

## Decisión

`public.usuario` es la fuente de verdad de las identidades operativas. No se
crean ni se dependen de cuentas `auth.users` para los flujos definidos hasta
ahora.

El servidor autentica un turno mediante una RPC `iniciar_turno(pin)`. Cada PIN
de cuatro dígitos debe ser único entre las cuentas activas; la RPC rechaza una
coincidencia cero o múltiple sin revelar cuál condición ocurrió.
Tras comprobar el PIN bcrypt y que la cuenta esté activa, crea una sesión
operativa de duración limitada. La base de datos almacena solo el hash del
token de sesión, su usuario, vencimiento, revocación y auditoría mínima; el
token en texto plano se devuelve una sola vez a la aplicación.

Las RPC de negocio reciben el token de sesión, nunca un identificador de actor
enviado por el cliente. Una función interna obtiene el usuario desde la sesión
y valida su estado y rol dentro de la misma transacción antes de cada cambio.
Las tablas operativas no conceden escrituras directas al cliente móvil.

## Consecuencias

- La aplicación guarda el token únicamente en almacenamiento seguro del
  dispositivo y no lo registra ni lo muestra.
- El nombre, rol y vencimiento se mantienen únicamente en memoria para la
  interfaz del turno actual. Si la aplicación se reinicia, no se restaura una
  interfaz autenticada sin una RPC de validación que devuelva esos metadatos.
- `cerrar_turno` revoca la sesión; las sesiones vencidas o revocadas no
  autorizan lecturas ni cambios.
- Las RPC expuestas a `anon` solo aceptan el token de sesión cuando la acción
  requiere un actor. El inicio de turno acepta únicamente un PIN; todas usan
  validación del servidor y fallan sin efectos parciales.
- Las consultas que necesite la aplicación se exponen mediante RPC de lectura
  autorizadas o políticas RLS basadas en una sesión verificable. No se usa un
  UUID guardado en el cliente como prueba de identidad.
- Los nombres de `usuario` se normalizan con `btrim` y su unicidad se aplica
  con `lower(btrim(nombre))`.
- Las altas y restablecimientos de PIN verifican su disponibilidad frente a las
  cuentas activas en la misma transacción; no se guarda un verificador
  determinista adicional al hash bcrypt.

## Alcance de roles

- `owner` y `waitress` activos pueden operar pedidos mediante una sesión
  válida.
- Solo `owner` activo puede administrar mesas, categorías, carta y cuentas
  `waitress`.
- Una cuenta `waitress` inactiva no puede iniciar turno; desactivar una cuenta
  no revoca de forma retroactiva los pedidos históricos.

## Verificación mínima

- Un token inventado, vencido, revocado o vinculado a una cuenta inactiva es
  rechazado por cada RPC protegida.
- Cambiar un UUID de usuario en la petición no puede cambiar el actor efectivo.
- El token, PIN y hash bcrypt no aparecen en respuestas, registros ni datos de
  aplicación persistidos fuera de los mecanismos indicados.
