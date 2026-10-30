# Mensajes — PR 06

Depende de cuentas y líneas del PR 05 (#42). Esta entrega modela el historial sin conectarse a Meta ni agregar todavía una ruta para enviar mensajes.

Message pertenece a una conversación y a su misma línea. Una clave foránea compuesta respalda esa correspondencia incluso al omitir validaciones de Active Record. Una conversación anterior sin número debe recibir una línea conocida antes de admitir mensajes.

Los mensajes entrantes guardan dirección inbound, estado received e identificador externo obligatorio. Los salientes guardan dirección outbound, autor autorizado, estado inicial queued e identificador client_request_id estable (UUID generado si no se proporciona). El identificador externo se incorpora al confirmar aceptación del proveedor y luego no puede reemplazarse. Índices únicos por línea e identificador externo/client_request_id respaldan la deduplicación ante concurrencia. El consumidor debe resolver RecordNotUnique recuperando el mensaje existente; este PR no implementa recepción ni envío.

Se admite texto no vacío y un marcador unsupported entrante para tipos todavía no implementados. Los marcadores no inventan contenido de texto. No hay adjuntos, notas internas ni plantillas en este modelo todavía.

## Estados y actividad

Los estados salientes son queued, sending, accepted, sent, delivered, read, failed y unknown. Accepted significa que el proveedor aceptó el mensaje; no equivale a entrega. Unknown permite conservar un resultado incierto sin devolverlo a queued ni reenviarlo automáticamente. Una confirmación posterior puede reconciliarlo.

`record_status!` bloquea la fila y aplica transiciones; estados repetidos o anteriores del progreso normal se ignoran. Delivered/read no retroceden a failed y los tiempos de estado no disminuyen. No se permite reescribir contenido, autor ni identidad del mensaje. La baja de un operario conserva los mensajes y deja autor_id nulo por clave foránea; un sistema futuro de auditoría puede conservar una identidad anonimizada si se requiere.

La creación de un mensaje actualiza last_activity_at de la conversación dentro de la misma transacción, mediante una actualización condicional que solo avanza el tiempo. Eventos antiguos no reordenan el chat hacia atrás y un rollback no deja actividad sin mensaje. Las actualizaciones de estado no simulan mensajes nuevos.

## Acceso y conservación

CompanyAccess restringe el ámbito de la API/futuro BO a conversaciones de la empresa y números autorizados. Avo es interno: solo Developer puede consultar el historial entre empresas. Los agentes y administradores de empresas no tienen acceso al panel. Se rechaza creación, edición y borrado de mensajes y se ocultan esos controles incluso para desarrolladores. No se pueden eliminar conversaciones con mensajes mediante los modelos. La baja de un contacto con historial también requiere resolver esa conservación previamente.

La migración agrega messages, índices, restricciones de contenido/estado y claves foráneas. No modifica conversaciones existentes ni envía datos. El rollback elimina los mensajes; exportar el historial antes de revertir una base utilizada.

## Validación

90 ejemplos RSpec aprobados (seed 6241) con PostgreSQL temporal tras separar Avo interno de las cuentas de empresa: integridad compuesta, unicidad respaldada por DB, autores y permisos, estados y resultados inciertos, actualización/rollback de actividad, administración interna de solo lectura y migración/rollback. Revisión visual manual pendiente. Sin prueba real ni simulación del proveedor: todavía no hay cliente HTTP ni webhook.

## Consultas explícitas de acceso

CompanyAccess.messages filtra por las conversaciones autorizadas; se elimina scope(model) sin cambiar permisos ni datos. Los specs conservan las comprobaciones de acceso por línea y sin agente. Validación: 95 ejemplos RSpec sin fallos en PostgreSQL temporal y RuboCop de los cuatro archivos Ruby modificados sin infracciones.
