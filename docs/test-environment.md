# Entorno de pruebas

La aplicación conserva image_processing 2. El adaptador ruby-vips se declara explícitamente con carga diferida; los entornos que procesen imágenes necesitan libvips (el Dockerfile ya lo instala). No se valida procesamiento de adjuntos en esta entrega.

En test se desactivan las variantes de Active Storage: los ejemplos actuales verifican modelos y HTTP, sin transformar archivos. Al incorporar adjuntos se necesitarán pruebas con el procesador real.

RSpec carga las factories por rutas relativas si la integración de FactoryBot no las encontró, para soportar los glob de Windows. CI ejecuta RSpec y se activa también en pushes a main; antes ejecutaba la tarea de Minitest pese a que las pruebas están en spec. Los scripts de bin se invocan con Ruby para no depender del bit ejecutable de los checkouts creados en Windows.

En este equipo las tareas db:migrate no encuentran los archivos por sus rutas absolutas de Windows. Para la comprobación local se creó una base temporal vacía en 127.0.0.1:55439 y se ejecutó `ActiveRecord::Base.connection_pool.migration_context.migrate` desde Rails runner con la ruta relativa db/migrate. Se conserva la base habitual sin cambios.
