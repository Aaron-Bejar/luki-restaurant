# Luki

Aplicación móvil para gestionar pedidos de restaurante por persona. Está diseñada para siete dispositivos móviles que comparten una base de datos PostgreSQL centralizada en Supabase, sin necesidad de computadoras o tablets en cocina.

## Funcionalidades

- Acceso operativo mediante nombre y PIN de cuatro dígitos.
- Gestión de mesas existentes y comandas por comensal.
- Registro, edición y cancelación lógica de ítems de pedido.
- Subtotales por persona y total consolidado de mesa.
- Cierre de pedidos con efectivo, tarjeta o billetera digital.
- Histórico de pedidos pagados y líneas canceladas.
- Administración de mesas, categorías y carta exclusiva para el dueño.

## Roles

| Rol | Permisos |
| --- | --- |
| `owner` | Administra mesas, categorías y carta; consulta y opera pedidos. |
| `waitress` | Consulta la carta y opera pedidos sobre mesas existentes. No puede crear, modificar ni eliminar registros de mesas, categorías o carta. |

Las meseras pueden ocupar y liberar mesas como parte del flujo de pedido. Esto solo actualiza el estado operativo de una mesa existente; no permite modificar ni eliminar su registro.

## Persistencia histórica

La base de datos usa PostgreSQL administrado por Supabase como fuente única de verdad.

- Cada apertura de una mesa crea un pedido nuevo.
- El cierre guarda el método de pago, marca el pedido como pagado y libera la mesa en una operación atómica.
- Las líneas de pedido no se eliminan por correcciones: se cancelan o se actualizan con cantidad 0.
- Una mesa con pedidos activos o históricos no puede eliminarse, para conservar la integridad del historial.

## Stack tecnológico

- React Native con Expo y Expo Router.
- TypeScript.
- NativeWind v4 y Tailwind CSS.
- `@supabase/supabase-js`.
- Supabase PostgreSQL.

La definición detallada del stack y sus convenciones está en `specs/_global/stack.md`.

## Estructura prevista

```text
app/                    Rutas y layouts de Expo Router
src/components/         Componentes reutilizables
src/hooks/              Hooks de aplicación
src/lib/supabase.ts     Cliente de Supabase
src/services/           Acceso a usuarios, carta, mesas y pedidos
src/types/              Tipos TypeScript
src/utils/              Utilidades compartidas
supabase/migrations/    Migraciones PostgreSQL
specs/                  Especificaciones, planes y tareas SDD
```

## Desarrollo Guiado por Especificaciones

Cada funcionalidad se documenta en `specs/NNN-nombre-corto/` mediante:

- `spec.md`: comportamiento, requisitos y criterios de aceptación.
- `plan.md`: diseño técnico, datos, decisiones y pruebas.
- `tasks.md`: tareas concretas y verificables de implementación.

Las decisiones comunes del proyecto se mantienen en `specs/_global/`. Antes de realizar cambios, revisa `AGENTS.md` y `.specify/memory/constitution.md`.

## Estado del Proyecto

El repositorio contiene actualmente la especificación y el plan de la funcionalidad de pedidos por persona. La inicialización de Expo, las migraciones de Supabase y la implementación de la aplicación están pendientes y se ejecutarán conforme a `specs/001-feature/tasks.md`.
