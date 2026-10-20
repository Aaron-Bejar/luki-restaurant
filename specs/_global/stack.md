# Stack tecnológico

| Área | Tecnología | Versión | Uso |
| --- | --- | --- | --- |
| Lenguaje | TypeScript | Por definir al inicializar Expo | Código de la aplicación móvil y servicios. |
| Framework | React Native con Expo y Expo Router | Por definir al inicializar Expo | Aplicación móvil y navegación por rutas. |
| Estilos | NativeWind | v4 | Estilos utilitarios para componentes React Native integrados con Expo. |
| CSS utilitario | Tailwind CSS | Compatible con NativeWind v4 | Tokens de diseño y clases utilitarias consumidas por NativeWind. |
| Cliente de datos | `@supabase/supabase-js` | Por definir al inicializar Expo | Consultas, llamadas RPC y suscripciones a Supabase. |
| Base de datos | PostgreSQL administrado por Supabase | Administrada por Supabase | Persistencia, integridad relacional y transacciones. |
| Pruebas | Por definir durante la implementación | Por definir | Pruebas de servicios, migraciones y flujos críticos. |

## Convenciones relevantes

- Las rutas de Expo Router viven en `app/`; componentes, servicios, tipos y utilidades viven en `src/`.
- Los componentes de interfaz usan clases utilitarias de Tailwind CSS mediante NativeWind v4; los estilos locales se reservan para casos que no puedan expresarse con utilidades.
- El cliente de Supabase se crea únicamente en `src/lib/supabase.ts` y lee la URL y clave anónima desde variables de entorno.
- Las migraciones SQL se almacenan en `supabase/migrations/` y no se modifican una vez aplicadas en un entorno compartido.
- Las claves de servicio de Supabase no se incluyen en la aplicación, documentación ni repositorio.
- Las correcciones de comandas nunca usan `DELETE`; actualizan `estado_item` a `cancelado` o `cantidad` a 0.
