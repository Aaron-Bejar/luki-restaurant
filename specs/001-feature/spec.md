# Especificación: Pedidos por persona

## Contexto y objetivo

El restaurante opera desde siete dispositivos móviles conectados a una única base de datos Supabase. El dueño administra la estructura de mesas y la carta; las meseras operan comandas agrupadas por comensal, pagos e histórico de ventas sin requerir equipos en cocina.

## Historias de usuario

Como mesera, quiero iniciar sesión con mi PIN y abrir una mesa para registrar la comanda de sus comensales.

Como mesera, quiero registrar, editar y cancelar ítems por persona para corregir pedidos sin perder el historial operativo.

Como mesera, quiero dividir visualmente la cuenta por persona y cerrar la mesa con un método de pago para cobrar correctamente.

Como dueño, quiero administrar categorías y platos para mantener la carta disponible para las meseras.

Como dueño, quiero crear, modificar y eliminar mesas sin afectar los pedidos históricos asociados.

Como dueño, quiero conservar los pedidos cancelados y pagados para auditar ventas e insumos.

## Requisitos funcionales

- RF-001: El sistema debe autenticar el cambio de turno con un PIN numérico de cuatro dígitos asociado a un usuario con rol `owner` o `waitress`.
- RF-002: Solo el rol `owner` puede crear, modificar o desactivar categorías y platos de la carta.
- RF-003: Solo el rol `owner` puede crear, modificar o eliminar registros de `mesas`.
- RF-004: El rol `waitress` puede consultar la carta y operar comandas sobre mesas existentes, pero no puede crear, modificar ni eliminar registros de `mesas`.
- RF-005: Al abrir una mesa libre, el sistema debe marcarla como `ocupada` y crear exactamente un pedido activo asociado a la mesera en una única operación atómica.
- RF-006: La comanda debe agrupar sus líneas por `num_persona`, con numeración positiva iniciada en 1.
- RF-007: El sistema debe permitir agregar y modificar líneas de pedido mientras el pedido esté activo.
- RF-008: El sistema no debe borrar físicamente líneas de `detalle_pedido` por acciones operativas. Una corrección debe marcar el ítem como `cancelado` o establecer su cantidad en 0.
- RF-009: Los subtotales por persona y el total de la mesa deben excluir líneas con estado `cancelado`.
- RF-010: Al cobrar un pedido activo, el sistema debe registrar un método de pago válido, marcar el pedido como `pagado` y liberar la mesa en una única operación atómica.
- RF-011: Una mesa liberada debe crear un pedido nuevo al ocuparse nuevamente; los pedidos anteriores deben conservarse como histórico.
- RF-012: La eliminación de una mesa con pedidos asociados debe ser rechazada para preservar el histórico.

## Requisitos no funcionales

- RNF-001: La persistencia debe usar PostgreSQL administrado por Supabase como única fuente central de datos para los siete dispositivos concurrentes.
- RNF-002: Las tablas deben aplicar claves primarias, claves foráneas, restricciones `CHECK`, valores por defecto e integridad referencial definidos en el modelo de datos.
- RNF-003: La interfaz móvil debe reflejar los cambios persistidos sin requerir un proceso manual de sincronización.
- RNF-004: El cliente móvil no debe contener credenciales con privilegios de servicio ni registrar PINes en texto plano.

## Criterios de aceptación

- Dado un PIN válido, cuando un usuario inicia turno, entonces la aplicación identifica su nombre y rol para aplicar los permisos de interfaz correspondientes.
- Dado una mesa libre, cuando una mesera la abre, entonces queda ocupada y existe un único pedido activo vinculado a esa mesa.
- Dado que dos dispositivos intentan abrir la misma mesa libre, cuando las operaciones se procesan concurrentemente, entonces solo una apertura tiene éxito.
- Dado un pedido activo, cuando se agregan platos para personas distintas, entonces las líneas se visualizan y totalizan bajo la cabecera de cada persona.
- Dado un ítem ingresado por error, cuando una mesera lo cancela, entonces el registro persiste, queda en estado `cancelado` o cantidad 0 y no participa en el total cobrable.
- Dado un pedido con ítems no cancelados, cuando se selecciona un método de pago permitido y se confirma el cobro, entonces el pedido queda pagado, conserva el método de pago y la mesa queda libre.
- Dado una mesa previamente pagada, cuando se abre de nuevo, entonces se crea un `id_pedido` distinto sin modificar el pedido histórico.
- Dado una mesera autenticada, cuando intenta alterar una categoría o plato, entonces la operación es rechazada.
- Dado una mesera autenticada, cuando intenta crear, modificar o eliminar un registro de `mesas`, entonces la operación es rechazada.
- Dado un dueño autenticado, cuando administra una mesa sin pedidos asociados, entonces puede crearla, modificarla o eliminarla.
- Dado una mesa con pedidos históricos o activos, cuando incluso un dueño intenta eliminarla, entonces la operación es rechazada por integridad referencial.

## Casos límite

- Intentar abrir una mesa ya ocupada debe informar que tiene un pedido activo y no crear otro pedido.
- Un pedido pagado no admite nuevas líneas ni modificaciones operativas.
- Un cobro sin método de pago válido no debe cambiar el estado del pedido ni de la mesa.
- Una línea cancelada o con cantidad 0 debe conservarse para auditoría, aun si deja el pedido sin ítems cobrables.
- Una mesera puede ocupar o liberar una mesa mediante el flujo de pedido, pero no puede cambiar su identificador ni eliminar su registro.
- Una categoría o plato con referencias históricas no debe eliminarse si la restricción referencial lo impide.

## Fuera de alcance

- Pantalla o dispositivo dedicado para cocina.
- Gestión de inventario, recetas o costos de insumos.
- Facturación electrónica, propinas, descuentos e impuestos adicionales.
- Eliminación física de pedidos o detalles desde el flujo operativo.
