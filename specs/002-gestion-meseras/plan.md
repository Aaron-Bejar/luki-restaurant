# Plan: Gestión de meseras

## Resumen técnico

Se expondrán RPC PostgreSQL para crear, cambiar el estado y restablecer el PIN de una `waitress`. Cada RPC verificará al owner actor dentro de la base de datos antes de cambiar datos. La interfaz solo invocará esos servicios y nunca tendrá permiso directo de escritura sobre `public.usuario`.

## Cambios previstos

- Añadir RPC para crear una mesera, cambiar su estado y restablecer su PIN; usar `extensions.crypt` y `extensions.gen_salt('bf', 10)` exclusivamente en el servidor.
- Definir la verificación de actor owner dentro de cada RPC y revocar la ejecución pública de sus funciones; otorgar solo los permisos mínimos requeridos por el flujo autenticado.
- Implementar un servicio de usuarios en `src/services` y pantallas de administración visibles únicamente para owners.
- Actualizar el flujo de acceso por PIN para que rechace usuarios con `activo = false`.
- Mantener la tabla `usuario` como fuente de verdad operativa: no crear ni depender de cuentas `auth.users` para este flujo.

## Datos e interfaces

| Operación | Entrada | Resultado |
| --- | --- | --- |
| Crear mesera | Identidad validada del owner, nombre y PIN | Nueva `waitress` activa sin exponer el PIN ni hash |
| Cambiar estado | Identidad validada del owner, id de mesera y estado objetivo | Cuenta conservada con `activo` actualizado |
| Restablecer PIN | Identidad validada del owner, id de mesera y nuevo PIN | Hash reemplazado; rol y estado preservados |

Las interfaces de aplicación no recibirán ni registrarán hashes. La confirmación de acciones privilegiadas solicitará la verificación de owner al servidor; una identidad almacenada solo en el cliente no es una prueba suficiente de autorización.

## Pruebas

- Crear una mesera válida y comprobar rol, estado activo y formato bcrypt del hash.
- Rechazar creación con actor no owner o inactivo, nombre duplicado y PIN inválido.
- Desactivar y reactivar una mesera con pedidos existentes sin eliminar ni alterar su historial.
- Confirmar que una mesera inactiva no puede iniciar turno y que el restablecimiento invalida el PIN anterior.
- Rechazar toda gestión de cuentas owner y todo acceso directo de `waitress` a las operaciones administrativas.
