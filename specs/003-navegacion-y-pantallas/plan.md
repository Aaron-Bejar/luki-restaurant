# Plan: Navegación y pantallas de la aplicación

## Organización de rutas

Las rutas de Expo Router vivirán en `app/`. El flujo autenticado tendrá un layout protegido por sesión y un grupo de tabs para Mesas, Carta, Personal y Perfil. Las rutas secundarias de mesa y pedido vivirán fuera de las pestañas para conservar el tab activo durante la navegación.

```text
app/
├── (auth)/index.tsx
└── (app)/
    ├── _layout.tsx
    ├── (tabs)/
    │   ├── _layout.tsx
    │   ├── mesas/index.tsx
    │   ├── carta.tsx
    │   ├── personal.tsx
    │   └── perfil.tsx
    ├── mesas/[mesaId]/index.tsx
    └── pedidos/[pedidoId].tsx
```

## Código reutilizable

Los componentes compartidos vivirán en `src/components/`, separados por dominio: `mesas`, `pedidos`, `carta` y `personal`. Los componentes no realizarán consultas directas; usarán servicios de `src/services/` y la sesión de `src/auth/`.

## Autorización

El layout autenticado aceptará `owner` y `waitress`. Personal y las acciones de administración se ocultarán o protegerán para `waitress`. La visibilidad de un botón no sustituye las RPC ni las políticas del servidor.

## Datos y transacciones

- Mesas y pedidos usarán los servicios existentes.
- Abrir mesa y cerrar pedido conservarán sus RPC atómicas.
- Detalles cancelados se conservarán con `estado_item = 'cancelado'` o cantidad cero.
- Carta y Personal requieren las RPC administrativas documentadas en `002-gestion-meseras` y las operaciones de categorías previstas en `001-feature`.

## Decisiones

- Tabs inferiores para las áreas principales porque son destinos frecuentes.
- Rutas secundarias para pedido y detalle para evitar mezclar estados de navegación con el tab.
- Filtros y búsqueda de mesas en la interfaz para respuesta inmediata sobre el conjunto ya autorizado.
- Estados de carga, vacío y error en cada pantalla de datos.

## Pruebas

- Verificar redirección por sesión y protección por rol.
- Verificar visibilidad de pestañas y acciones para `owner` y `waitress`.
- Verificar navegación mesa → pedido → detalle.
- Verificar que totales excluyan líneas canceladas.
- Verificar cierre de sesión y revocación del token.
