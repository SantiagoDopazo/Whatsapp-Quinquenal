# Entorno de pruebas

La aplicación conserva image_processing 2. El adaptador ruby-vips se declara explícitamente con carga diferida; los entornos que procesen imágenes necesitan libvips (el Dockerfile ya lo instala). No se valida procesamiento de adjuntos en esta entrega.

En test se desactivan las variantes de Active Storage: los ejemplos actuales verifican modelos y HTTP, sin transformar archivos. Al incorporar adjuntos se necesitarán pruebas con el procesador real.

RSpec carga las factories por rutas relativas si la integración de FactoryBot no las encontró, para soportar los glob de Windows. CI ejecuta RSpec y se activa también en pushes a main; antes ejecutaba la tarea de Minitest pese a que las pruebas están en spec. Los scripts de bin se invocan con Ruby para no depender del bit ejecutable de los checkouts creados en Windows.

En este equipo las tareas db:migrate no encuentran los archivos por sus rutas absolutas de Windows. Para la comprobación local se creó una base temporal vacía en 127.0.0.1:55439 y se ejecutó `ActiveRecord::Base.connection_pool.migration_context.migrate` desde Rails runner con la ruta relativa db/migrate. Se conserva la base habitual sin cambios.

## Controles remotos y dependencias

Al habilitar las tareas reales de CI se verificaron 24 ejemplos aprobados en Linux. Se corrigió el estilo de inicializadores y se actualizó Brakeman a 8.1.0, requerido por su control de versión vigente.

La auditoría remota detectó dependencias con avisos publicados: Avo 4.1.6 (autorización en asociaciones y configuración global de locale), crass 1.0.7 (sanitización CSS) y ViewComponent 4.12.0 (estado compartido en instancias reutilizadas). El lock pasa a Avo 4.3.10, crass 1.0.8 y ViewComponent 4.20.0, incorporando csv como dependencia de Avo. No se deshabilitan controles ni se agregan excepciones de auditoría.

Referencias: [Avo](https://github.com/avo-hq/avo/security/advisories/GHSA-x65r-p6hf-94hv), [crass](https://github.com/rgrove/crass/security/advisories/GHSA-pq4g-8rxf-4g29), [ViewComponent](https://github.com/ViewComponent/view_component/security/advisories/GHSA-8qw7-6phv-7q6p). Con las nuevas dependencias se ejecutaron nuevamente los 24 ejemplos locales (seed 4819); falta volver a comprobar la auditoría remota sobre este último commit.

## Alcance de las pruebas

Las pruebas verifican comportamiento de negocio en modelos, controllers/requests, workers, helpers y POROs. No se mantienen specs de migraciones ni comprobaciones de estructura, creación de tablas o rollback mediante SQL. Las restricciones relevantes para el negocio se verifican desde los modelos y sus operaciones. Los resultados de migración/rollback mencionados en entregas anteriores son históricos.
