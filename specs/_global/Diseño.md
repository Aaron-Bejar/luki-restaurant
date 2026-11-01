---
name: diseno-app-restaurante
description: Reglas de diseño visual (estilo ElevenReader con la identidad verde de la app) que deben seguir TODAS las pantallas de la app móvil del restaurante. Úsala al crear o modificar cualquier pantalla o componente de UI.
---

# Diseño de la app de restaurante — estilo ElevenReader en verde

Estas reglas son obligatorias para **todas las pantallas** (Mesas, Carta, Personal, Perfil y las que se agreguen). Si una regla choca con una decisión puntual, gana la regla; si falta una regla, se decide por los principios de la sección 1.

Las medidas están en **dp** (unidades de la app móvil).

---

## 1. Principios

1. **Una sola cosa protagonista por pantalla.** El elemento principal (nombre del producto, estado de la mesa, etc.) destaca; todo lo demás va en tono apagado.
2. **Menos cajas, más aire.** Las listas son filas separadas por un divisor fino, no una tarjeta con borde por cada elemento.
3. **El verde es una señal, no un fondo.** Solo se usa para: acción principal, elemento activo y estado positivo ("Disponible", "Activo", "Libre").
4. **Una acción = un control.** Lo que se enciende/apaga es un interruptor, no un texto link.
5. **Las acciones poco frecuentes se esconden** en un menú (engranaje o "más"), no como botones permanentes.
6. **Modo oscuro principal; el claro es equivalente.** Mismos tokens, distinto valor.
7. **Consistencia antes que creatividad.** Si ya existe un componente para algo, se reutiliza.

---

## 2. Colores

| Token                          | Oscuro              | Claro               | Uso                                                   |
| ------------------------------ | ------------------- | ------------------- | ----------------------------------------------------- |
| `bg`                           | `#0D120F`           | `#F7F6F1`           | Fondo de pantalla                                     |
| `surface`                      | `#151C17`           | `#FFFFFF`           | Buscador, chips inactivos, modales                    |
| `surface2`                     | `#1D2620`           | `#ECEBE4`           | Botones de ícono, pestaña activa, interruptor apagado |
| `line`                         | `#26302A`           | `#E3E1D8`           | Divisores y bordes                                    |
| `ink`                          | `#F2F5F3`           | `#14201A`           | Títulos y nombres                                     |
| `muted`                        | `#8FA096`           | `#6B7A70`           | Precios, subtítulos, etiquetas                        |
| `brand`                        | `#2FC477`           | `#1FA55E`           | Acción principal, elemento activo, estado positivo    |
| `onbrand`                      | `#06210F`           | `#FFFFFF`           | Texto o ícono sobre el verde                          |
| Miniatura (degradado diagonal) | `#1E7A4A → #0F4A2B` | `#BFE8D0 → #7FD1A3` | Imagen de reemplazo cuando no hay foto                |

Reglas:

- El fondo oscuro es un **negro con tinte verde**, nunca negro puro.
- Contraste mínimo de texto: 4.5:1.
- Error `#E5484D` y alerta `#F5A524`; siempre acompañados de ícono o texto, nunca solo color.
- Máximo **un** color de acento por pantalla (el verde).
- No inventar colores nuevos: todo sale de esta tabla.

---

## 3. Tipografía

| Rol                                 | Fuente           | Tamaño / peso                  |
| ----------------------------------- | ---------------- | ------------------------------ |
| Título de pantalla                  | **Lora** (serif) | 36 · SemiBold · espaciado −0.5 |
| Nombre de producto / ítem principal | **Lora**         | 18 · SemiBold                  |
| Texto de interfaz                   | **Poppins**      | 14–15 · Regular / Medium       |
| Etiquetas y estados                 | Poppins          | 11.5–13 · Regular              |
| Botón principal                     | Poppins          | 15 · Bold                      |

Reglas:

- El serif es solo para **títulos y nombres**; todo lo demás va en sans. Esa mezcla da el aire editorial de ElevenReader.
- Sentence case ("Gestionar categorías"); sin MAYÚSCULAS sostenidas.
- Interlineado: 1.2 en títulos, 1.4 en texto de interfaz.
- Tamaño mínimo: 11 dp.

---

## 4. Espaciado y forma

- **Escala de espacio (dp):** 4 · 8 · 12 · 16 · 22 · 32. No usar valores fuera de la escala.
- **Margen lateral de pantalla:** 22.
- **Radios:**
  - Chips, buscador y botones de acción: píldora (totalmente redondeados)
  - Miniaturas y tarjetas: 16–20
  - Hojas modales: 24 arriba
- **Bordes:** 1 dp en `line`.
- **Sombras:** solo en el botón flotante. Las listas y tarjetas no llevan sombra.

---

## 5. Estructura de pantalla

Toda pantalla sigue este orden vertical:

1. **Encabezado:** título grande a la izquierda + subtítulo con conteo o contexto; a la derecha, un botón de ícono circular (42 dp, `surface2`) que abre las acciones secundarias.
2. **Buscador** (si la pantalla tiene listas largas): altura 46, píldora, `surface` + borde, ícono de lupa.
3. **Filtros** (si aplican): fila horizontal de chips con scroll.
4. **Contenido:** lista en filas o cuadrícula.
5. **Botón flotante** con la acción principal (una sola por pantalla).
6. **Barra de navegación inferior** fija.

---

## 6. Componentes

### Chip

- Padding 9 × 17, separación entre chips 8, scroll horizontal sin barra visible.
- Inactivo: `surface`, borde `line`, texto `muted`.
- Activo: fondo `brand`, texto `onbrand`.

### Fila de lista

- Estructura: miniatura o avatar (62) · bloque de texto · control a la derecha.
- Separación 14 entre miniatura y texto; padding vertical 13; divisor inferior de 1 dp.
- Nombre en serif 18 (`ink`), dato secundario en sans 14 (`muted`), estado con punto de 6 dp + texto de 11.5.
- **Toda la fila es tocable** y abre el detalle/edición; no hay links sueltos tipo "Editar".
- Estado negativo ("No disponible", "Inactivo"): nombre y dato al 55 % de opacidad, nunca se oculta el elemento.
- Sin foto: degradado + ícono de línea de la categoría.

### Interruptor (switch)

- Encendido: `brand` con perilla blanca. Apagado: `surface2` con borde y perilla `muted`.
- Cambia al instante, sin pedir confirmación; se puede deshacer tocándolo otra vez.

### Botón flotante

- Píldora de 52 dp de alto, fondo `brand`, texto `onbrand` en negrita con ícono "+" a la izquierda.
- Esquina inferior derecha, 20 del borde y 16 por encima de la barra de navegación.
- Es la **única** acción primaria de la pantalla; la lista debe tener margen inferior para que no tape el último elemento.

### Botón de ícono

- Círculo de 42 dp, fondo `surface2`, ícono de 20 dp.

### Barra de navegación inferior

- Alto 88 dp, fondo `bg` casi opaco, borde superior 1 dp en `line`.
- Ícono de 22 + etiqueta de 11.
- Pestaña activa: píldora de 52 × 30 en `surface2`, ícono en `brand`, etiqueta en `ink` (Medium).
- Inactivas: ícono y etiqueta en `muted`.

### Tarjetas (cuando haga falta agrupar, p. ej. mesas)

- Fondo `surface`, borde `line`, radio 20, sin sombra, padding 16.
- El estado se marca con punto de color + texto.

### Modales y menús

- Hojas que suben desde abajo, radio superior 24, fondo `surface`, con una barra de arrastre de 4 × 36 en `line`.
- Acciones del menú como filas simples con ícono de línea; las destructivas ("Eliminar") en rojo y siempre con confirmación.

---

## 7. Íconos

- Estilo **línea**, trazo 1.8, extremos redondeados.
- 22 dp en navegación, 20 dp en botones, 28 dp dentro de miniaturas.
- Una sola familia de íconos en toda la app; no mezclar con íconos rellenos.

---

## 8. Movimiento

- Solo animaciones que responden a una acción: interruptor (150 ms), chip (200 ms), modal desde abajo (250 ms).
- Sin animaciones de entrada decorativas en listas o pantallas.
- Respetar la opción "reducir movimiento" del sistema.

---

## 9. Redacción

- Verbos consistentes en toda la app: **Agregar**, **Editar**, **Eliminar**, **Restaurar**. La misma acción se llama igual en todo el flujo.
- Estados cortos: "Disponible" / "No disponible".
- Pantallas vacías con instrucción: _"Aún no hay productos en Bebidas. Toca + Producto para agregar el primero."_
- Los errores dicen qué pasó y cómo resolverlo; no piden disculpas.
- Español neutro, trato de "tú", sin jerga técnica.

---

## 10. Accesibilidad

- Zonas táctiles de al menos 44 × 44 dp.
- Etiquetas de accesibilidad descriptivas en botones, chips y filas (ej.: "Agua, 4 soles, disponible").
- Nunca comunicar un estado solo con color: siempre texto o ícono además.
- La interfaz debe seguir funcionando con el tamaño de fuente del sistema al 130 %.

---

## 11. Aplicación por pantalla

| Pantalla     | Cómo aplica                                                                                                                                                               |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Mesas**    | Cuadrícula de dos columnas con tarjetas; estado (libre / ocupada) con punto + texto; botón flotante "+ Pedido".                                                           |
| **Carta**    | Chips de categoría, filas de producto con interruptor de disponibilidad, botón flotante "+ Producto". Gestionar categorías y ver eliminados van en el menú del engranaje. |
| **Personal** | Mismas filas que Carta con avatar; rol como dato secundario; interruptor de "Activo"; botón flotante "+ Personal".                                                        |
| **Perfil**   | Título serif, secciones separadas por divisores, opciones como filas con flecha; selector de tema claro/oscuro; "Cerrar sesión" como texto simple, sin botón relleno.     |

---

## 12. Lista de verificación antes de dar una pantalla por terminada

- [ ] Usa solo colores, tamaños y radios de esta guía.
- [ ] Títulos y nombres en serif; todo lo demás en sans.
- [ ] Hay una sola acción primaria y es el botón flotante verde.
- [ ] Las listas son filas con divisor, no cajas con borde por elemento.
- [ ] Los estados activados/desactivados usan interruptor.
- [ ] El verde aparece solo como señal (acción, activo, positivo).
- [ ] Se ve bien en modo oscuro **y** en claro.
- [ ] Zonas táctiles ≥ 44 dp y estados con texto, no solo color.
- [ ] Los textos siguen las reglas de redacción.
