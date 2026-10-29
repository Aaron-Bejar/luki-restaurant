# Patrones de interfaz y navegación

## Propósito

Estas decisiones se aplican a toda pantalla nueva o modificada para mantener
una experiencia consistente entre funcionalidades.

## Formularios y acciones

- Cada acción administrativa tiene una única pantalla o subpantalla principal.
  No se duplican puntos de creación si uno de ellos ya centraliza la gestión.
- Los errores de validación o de una solicitud de formulario se muestran junto
  al campo o grupo de campos que los produjo. Los errores de carga de pantalla
  se muestran fuera del formulario.
- Las confirmaciones destructivas usan un `Modal` propio centrado, con
  `animationType="fade"`, fondo `bg-black/30`, tarjeta
  `bg-[--color-surface] p-6 rounded-t-3xl` y acciones explícitas Cancelar y
  Eliminar. La confirmación no sustituye la validación de servidor.

## Listas, filtros y navegación

- Los controles de filtro horizontal tienen altura fija y se alojan en un
  contenedor de altura estable. Las listas asociadas ocupan el espacio restante
  de la pantalla para no recortar bordes ni modificar el espaciado según el
  filtro seleccionado.
- Un control con destino explícito, por ejemplo “Volver a Carta”, navega a esa
  ruta concreta. No debe usar navegación hacia atrás basada en historial cuando
  el historial pueda llevar a otra pantalla.
