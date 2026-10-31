# Estado para retomar — 30/10/2026

## Decisión de arquitectura

Avo es un panel interno exclusivo de Developer para flags, configuración del backend y configuración de cada frontend/empresa. Las empresas usarán un BO propio como Agent. Ser admin de una empresa no concede acceso interno. El control de acceso está implementado; las pantallas y modelos concretos de flags/configuración todavía no.

## Entregas y dependencias

| Entrega | PR | Rama | Base |
| --- | --- | --- | --- |
| Soporte de CI y dependencias corregidas | [#40](https://github.com/SantiagoDopazo/Whatsapp-Quinquenal/pull/40) | fix/test-runtime | main |
| 04 — API por empresa y Avo interno | [#41](https://github.com/SantiagoDopazo/Whatsapp-Quinquenal/pull/41) | feat/company-authorization | fix/test-runtime |
| 05 — Cuentas, líneas y permisos | [#42](https://github.com/SantiagoDopazo/Whatsapp-Quinquenal/pull/42) | feat/whatsapp-lines | feat/company-authorization |
| 06 — Mensajes y estados | [#43](https://github.com/SantiagoDopazo/Whatsapp-Quinquenal/pull/43) | feat/messages | feat/whatsapp-lines |
| 07 — Contrato y configuración | [#44, borrador](https://github.com/SantiagoDopazo/Whatsapp-Quinquenal/pull/44) | feat/whatsapp-contract | feat/messages |

No se fusionó ningún PR automáticamente. Revisar en orden y cambiar la base de cada PR a main cuando se integre su predecesor. La base de empresas, PR 03 (#39), ya está en main.

## Validación realizada

- PR 04: 44 ejemplos; PR 05: 65; PR 06: 90; cadena hasta PR 07: 95. Suite final con seed 6241, PostgreSQL temporal y dependencias exactas.
- Los commits de implementación corregidos de los PRs 04–06 pasaron CI completo en GitHub. Después se agregaron aclaraciones documentales; consultar los checks del último commit en cada PR.
- Contrato OpenAPI validado con `postman spec lint api/openapi.yaml --no-report-events --issueType syntax`; ejemplos JSON parseados. Sin publicación de recursos en Postman.
- Las pruebas de vistas necesitan ejecución fuera del sandbox en este equipo: el sandbox impide enumerar algunas rutas absolutas. No se corrigió ese bloqueo modificando el comportamiento de Rails.
- Revisión visual manual del BO pendiente. Sin recepción/envío real ni simulación de Meta.

## Pendientes concretos

1. Revisar los PRs y sus migraciones. Developer se incorpora en PR 04; cuentas/líneas en PR 05; mensajes en PR 06.
2. Para habilitar acceso interno, aprovisionar un Developer con SEED_DEVELOPER_EMAIL y SEED_DEVELOPER_PASSWORD explícitos y ejecutar db:seed. No existe una cuenta interna por defecto ni se convirtió ningún agente existente.
3. Completar PR 07: confirmar versión de Graph y configuración vigente en Meta. La documentación directa devolvió 429 o no se pudo recuperar; Orbit aportó un contrato parcial con ejemplos antiguos. Ver docs/whatsapp-integration.md.
4. Empezar PR 08 después de resolver esa verificación: firma/challenge, recepción durable, resolución de WABA/número registrado y encolado. No está empezado y las rutas del OpenAPI aún no están montadas.
5. Flags/configuración requieren definir claves, tipos y alcance global o por empresa antes de crear sus modelos y pantallas. No se inventaron configuraciones de producto.

## Workspace

El desarrollo está en el worktree `.worktrees/deliveries`, rama feat/whatsapp-contract. El checkout original conserva sus cambios previos en Gemfile/Gemfile.lock y documentos locales, sin incluirlos en los nuevos commits ni hacer stash. Los commits usan la identidad Git del usuario, sin coautoría del asistente.
