# Instrucciones del proyecto

<!-- postman-cli:installation:start -->
Postman CLI is installed on this device, and can be used for API Engineering work.
<!-- postman-cli:installation:end -->

## Commits y pull requests

- Antes de empezar cada desarrollo, revisar cambios locales, cambiar a `main` y ejecutar `git pull --ff-only origin main`. Crear la rama de trabajo desde esa `main` actualizada. No descartar cambios ni hacer stash automáticamente si impiden el cambio de rama: conservarlos y explicar el bloqueo.
- Dividir el trabajo en PRs pequeños con un objetivo concreto y revisable. Separar los commits por responsabilidad: modelo/migración, interfaz, pruebas y documentación cuando corresponda.
- Usar la identidad de autor y committer configurada por el usuario en Git. No agregar trailers Co-authored-by ni atribución al asistente. No modificar la identidad de Git sin indicación del usuario.
- Al terminar una entrega de código solicitada, crear o actualizar su PR hacia `main`. No hacer merge automáticamente. No crear PRs de funcionalidades todavía no implementadas.
- Titular los PRs con un prefijo convencional y una descripción concreta en español: `feat: ...`, `fix: ...`, `refactor: ...`, `test: ...` o `docs: ...`.
- Escribir la descripción para poder entender y diagnosticar el cambio en el futuro: explicar el problema que motivó el PR, el comportamiento resultante, las decisiones relevantes, las comprobaciones ejecutadas y sus resultados, y cualquier limitación o validación pendiente.
- Indicar efectos de migraciones y cambios en datos cuando corresponda. Agregar notas de diagnóstico o recuperación si aportan información concreta.
- Nunca declarar pruebas aprobadas si no se ejecutaron. Si la validación está bloqueada, explicarlo y abrir el PR como borrador.
- Evitar comentarios que repitan el código, plantillas comentadas y explicaciones obvias. Conservar comentarios que documenten restricciones relevantes y anotaciones generadas del esquema.
- No incluir cambios locales ajenos a la entrega, secretos, tokens ni datos personales de clientes.
- Si no se puede crear o actualizar el PR por permisos o autenticación, informar el bloqueo y proporcionar el enlace para abrirlo manualmente; no afirmar que el PR fue creado.
