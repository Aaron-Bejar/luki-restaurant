# Especificación: Gestión de meseras

## Contexto y objetivo

El dueño debe poder administrar el ciclo de vida de las cuentas de meseras sin borrar su historial operativo. La aplicación usa PINes de cuatro dígitos contra `public.usuario`; el término «contraseña» de esta funcionalidad se refiere a ese PIN.

## Historias de usuario

Como dueño, quiero crear una cuenta de mesera con un PIN inicial para incorporar personal nuevo.

Como dueño, quiero activar o desactivar una cuenta de mesera para controlar su acceso sin perder sus pedidos históricos.

Como dueño, quiero restablecer el PIN de una mesera para recuperar el acceso de forma segura.

## Requisitos funcionales

- RF-001: Solo un usuario `owner` activo, derivado de una sesión operativa válida por el servidor, puede crear, activar, desactivar o restablecer el PIN de una cuenta con rol `waitress`.
- RF-002: La creación exige un nombre no vacío y único por `lower(btrim(nombre))`, y un PIN numérico de cuatro dígitos; el servidor almacena únicamente su hash bcrypt.
- RF-003: La desactivación debe establecer `usuario.activo = false` sin eliminar la fila ni modificar sus pedidos históricos.
- RF-004: Un usuario `waitress` inactivo no puede iniciar turno, aunque presente un PIN correcto.
- RF-005: La activación debe establecer `usuario.activo = true` sin alterar el rol, historial ni PIN actual.
- RF-006: El restablecimiento debe reemplazar solo `pin_hash` por un nuevo hash bcrypt de un PIN numérico de cuatro dígitos y conservar el estado `activo` actual.
- RF-007: Una mesera no puede crear, activar, desactivar ni restablecer PINes de usuarios.
- RF-008: Un `owner` no puede administrar mediante este flujo una cuenta `owner`; la gestión de dueños queda fuera de alcance.
- RF-009: Las operaciones de gestión se ejecutan mediante RPC PostgreSQL; la aplicación móvil no inserta ni actualiza directamente `public.usuario`.

## Requisitos no funcionales

- RNF-001: Ningún PIN, hash bcrypt operativo ni clave con privilegios de servicio se registra, muestra o versiona.
- RNF-002: Cada RPC valida en la misma transacción que el actor derivado de la sesión es un `owner` activo y que el destino es una `waitress` existente cuando corresponda.
- RNF-003: El rechazo por falta de permisos, usuario inexistente, nombre duplicado o PIN inválido no debe producir efectos parciales.

## Criterios de aceptación

- Dado un owner activo validado, cuando crea una mesera con nombre único y PIN válido, entonces existe una nueva `waitress` activa con hash bcrypt y sin PIN expuesto.
- Dado un owner activo validado, cuando desactiva una mesera, entonces su registro y pedidos históricos se conservan y su inicio de turno posterior es rechazado.
- Dado un owner activo validado, cuando activa una mesera, entonces recupera la posibilidad de iniciar turno con su PIN vigente.
- Dado un owner activo validado, cuando restablece el PIN de una mesera, entonces el PIN anterior deja de validar y el nuevo valida; el estado de la cuenta no cambia.
- Dado una mesera o un owner inactivo, cuando intenta cualquiera de las operaciones administrativas, entonces la operación es rechazada sin modificar datos.
- Dado un owner activo, cuando intenta administrar a otro owner mediante este flujo, entonces la operación es rechazada.
- Dado un token de sesión vencido, revocado o inventado, cuando se intenta administrar una mesera, entonces la operación es rechazada sin modificar datos.

## Casos límite

- Desactivar una cuenta ya inactiva y activar una cuenta ya activa debe ser idempotente y no alterar otros campos.
- Un nombre que solo difiere por mayúsculas o espacios iniciales/finales no puede duplicar una cuenta existente; el valor se almacena sin esos espacios.
- Un PIN con caracteres no numéricos o distinto de cuatro dígitos debe rechazarse antes de calcular un hash.
- Si una mesera tiene pedidos históricos o activos, su desactivación sigue permitida porque la cuenta no se elimina.

## Fuera de alcance

- Crear, desactivar, reactivar o restablecer PINes de cuentas `owner`.
- Eliminar físicamente usuarios.
- Recuperación automática de PIN mediante correo, SMS u otro canal externo.
