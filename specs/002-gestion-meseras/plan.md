# Plan: Gestión de meseras

## Resumen técnico

Se expondrán RPC PostgreSQL para crear, cambiar el estado y restablecer el PIN de una `waitress`. Cada RPC deriva y verifica al owner actor desde una sesión operativa válida dentro de la base de datos antes de cambiar datos. La interfaz solo invocará esos servicios y nunca tendrá permiso directo de escritura sobre `public.usuario`.

## Cambios previstos

- Consumir la infraestructura de sesiones de `specs/_global/autorizacion-y-sesiones.md` y añadir RPC para crear una mesera, cambiar su estado y restablecer su PIN; usar `extensions.crypt` y `extensions.gen_salt('bf', 10)` exclusivamente en el servidor.
- Derivar el actor owner desde el token de sesión dentro de cada RPC y otorgar únicamente la ejecución necesaria a las funciones expuestas; no aceptar un UUID de actor desde el cliente.
- Implementar un servicio de usuarios en `src/services` y pantallas de administración visibles únicamente para owners.
- Actualizar el flujo de acceso por PIN para que rechace usuarios con `activo = false`.
- Mantener la tabla `usuario` como fuente de verdad operativa: no crear ni depender de cuentas `auth.users` para este flujo; antes de crear o restablecer un PIN, usar la comprobación privada de disponibilidad contra las cuentas activas.

## Datos e interfaces

| Operación | Entrada | Resultado |
| --- | --- | --- |
| Crear mesera | Token de sesión, nombre y PIN | Nueva `waitress` activa sin exponer el PIN ni hash |
| Cambiar estado | Token de sesión, id de mesera y estado objetivo | Cuenta conservada con `activo` actualizado |
| Restablecer PIN | Token de sesión, id de mesera y nuevo PIN | Hash reemplazado; rol y estado preservados |

Las interfaces de aplicación no recibirán ni registrarán hashes. La confirmación de acciones privilegiadas envía el token de sesión al servidor; un UUID o rol almacenado solo en el cliente no es una prueba suficiente de autorización.

## Pruebas

- Crear una mesera válida y comprobar rol, estado activo y formato bcrypt del hash.
- Rechazar creación con actor no owner o inactivo, nombre duplicado, PIN inválido o PIN ya asignado a una cuenta activa.
- Desactivar y reactivar una mesera con pedidos existentes sin eliminar ni alterar su historial.
- Confirmar que una mesera inactiva no puede iniciar turno y que el restablecimiento invalida el PIN anterior.
- Rechazar toda gestión de cuentas owner y todo acceso directo de `waitress` a las operaciones administrativas.
- Rechazar tokens de sesión vencidos, revocados, inventados o pertenecientes a una `waitress`.
