# Historial de carta eliminada

## Decisión

Un `detalle_pedido` conserva `nombre_plato` y `precio_unitario` como evidencia
histórica suficiente. Si un owner elimina una categoría, los productos asociados
se eliminan en cascada y `detalle_pedido.carta_id` pasa a `NULL` mediante la
clave foránea `ON DELETE SET NULL`.

## Consecuencias

- Los pedidos existentes muestran el producto y precio que se registraron al
  momento de la comanda, incluso después de borrar su categoría.
- La referencia opcional a `carta` sirve solo mientras el producto exista; no
  es necesaria para calcular ni consultar el histórico.
- El borrado de categorías continúa reservado a un owner autenticado mediante
  sesión operativa.
