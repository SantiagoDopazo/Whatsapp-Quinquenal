# Base de empresas

Cada operario y contacto pertenece a una Company. Una conversación obtiene su empresa a través del contacto. Por ahora un operario pertenece a una sola empresa y el email de acceso continúa siendo único globalmente.

Un whatsapp_id puede repetirse entre empresas, pero no dentro de una misma empresa. El índice compuesto en PostgreSQL respalda esa regla. La aplicación rechaza asignaciones de conversaciones a operarios de otra empresa y cambios de empresa de contactos/operarios ya guardados. Eliminar una empresa con contactos u operarios está bloqueado.

## Migración

`bundle exec rails db:migrate` crea La Quinquenal y le asigna todos los agentes y contactos existentes, conservando sus IDs y las conversaciones. Este backfill supone que los datos anteriores pertenecen a una sola empresa. La migración es transaccional y no ofrece rollback: una reversión descartaría pertenencias y podría chocar con teléfonos repetidos entre empresas. Antes de aplicarla a datos reales, realizar y verificar un backup; para volver al estado previo, restaurar el backup junto con la versión anterior del código.

El esquema fue generado ejecutando la migración contra una instancia temporal de PostgreSQL 17. La prueba de migración construye el esquema anterior con datos y verifica la conservación de relaciones y estados.

## Administración y seeds

Avo incorpora empresas y permite elegir empresa al crear contactos y operarios. La pertenencia no se puede cambiar una vez guardados. Los seeds se pueden repetir sin duplicar el administrador; `SEED_ADMIN_PASSWORD` permite elegir su contraseña al crearlo, manteniendo el valor de demostración anterior cuando no está configurada. Ejecutar seeds no cambia la contraseña de un administrador existente.

## Alcance

Este PR establece pertenencia e integridad a nivel de modelos y claves foráneas; todavía no limita las rutas, listados ni selectores de Avo por empresa. No habilitar varios clientes reales hasta implementar autorización por empresa en el próximo PR. La validación de asignación y la inmutabilidad son de Active Record: escrituras SQL directas pueden omitirlas.

## Validación

- 23 ejemplos RSpec aprobados en PostgreSQL temporal, incluyendo preservación de datos en la migración y unicidad respaldada por base de datos.
- RuboCop sin infracciones en los 20 archivos Ruby revisados.
- Seeds ejecutados dos veces sin errores ni duplicación del administrador.
- La instancia habitual de PostgreSQL en el puerto 5432 sigue cerrando conexiones; no se modificó su configuración.
- Revisión visual de Avo pendiente. Sin llamadas a Meta y sin credenciales del proveedor.
- Las comprobaciones locales utilizan el cambio previo de image_processing presente en el workspace, excluido de este PR.
- Se intentó repetir la suite con copias temporales del Gemfile/lock de main, pero `bundle check` indicó dependencias faltantes. Queda pendiente la validación con las dependencias exactas del PR; se abre como borrador por ese motivo y la revisión de Avo pendiente.
