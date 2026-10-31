# Base de empresas

Cada operario y contacto pertenece a una Company. Una conversación obtiene su empresa a través del contacto. Por ahora un operario pertenece a una sola empresa y el email de acceso continúa siendo único globalmente.

Un whatsapp_id puede repetirse entre empresas, pero no dentro de una misma empresa. El índice compuesto en PostgreSQL respalda esa regla. La aplicación rechaza asignaciones de conversaciones a operarios de otra empresa y cambios de empresa de contactos/operarios ya guardados. Eliminar una empresa con contactos u operarios está bloqueado.

## Migración

La aplicación todavía no llegó a producción. La migración usa `change` y modifica solo estructura: crea empresas, referencias obligatorias e índice de contactos por empresa. No crea empresas ni reasigna datos. La Quinquenal y el administrador se crean mediante `db:seed`.

La prueba construye el esquema anterior vacío y verifica migración y rollback, incluida la restauración del índice único global. Si una base local tiene agentes o contactos anteriores, habrá que decidir qué hacer con esos datos antes de aplicar referencias obligatorias; este cambio no borra ni reinicia bases existentes. Revertir el índice global sobre datos con teléfonos repetidos entre empresas requiere resolver esas duplicaciones primero.

## Administración y seeds

Avo incorpora empresas y permite elegir empresa al crear contactos y operarios. La pertenencia no se puede cambiar una vez guardados. Las seeds crean la empresa y el administrador directamente con datos de ejemplo fijos, sobre una base limpia. Para cargarlas nuevamente se utiliza `rails db:drop db:create db:migrate db:seed`, que elimina los datos anteriores. SEED_ADMIN_PASSWORD deja de utilizarse.

## Alcance

Este PR establece pertenencia e integridad a nivel de modelos y claves foráneas; todavía no limita las rutas, listados ni selectores de Avo por empresa. No habilitar varios clientes reales hasta implementar autorización por empresa en el próximo PR. La validación de asignación y la inmutabilidad son de Active Record: escrituras SQL directas pueden omitirlas.

## Validación

- 24 ejemplos RSpec aprobados en orden aleatorio (seed 391) en PostgreSQL temporal, incluyendo migración/rollback de estructura y unicidad respaldada por base de datos.
- TestProf habilita `let_it_be`: los specs usan fixtures persistidos y `refind: true` cuando hay mutaciones, y `let` para valores por ejemplo, sin `let!`, variables locales ni métodos auxiliares.
- RuboCop sin infracciones en los 20 archivos Ruby revisados.
- Seeds ejecutados dos veces sin errores ni duplicación del administrador.
- La instancia habitual de PostgreSQL en el puerto 5432 sigue cerrando conexiones; no se modificó su configuración.
- Revisión visual de Avo pendiente. Sin llamadas a Meta y sin credenciales del proveedor.
- Las comprobaciones locales utilizan el cambio previo de image_processing presente en el workspace, excluido de este PR.
- Se intentó repetir la suite con copias temporales del Gemfile/lock de main, pero `bundle check` indicó dependencias faltantes. Queda pendiente la validación con las dependencias exactas del PR; se abre como borrador por ese motivo y la revisión de Avo pendiente.
