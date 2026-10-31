# Contrato y configuración — PR 07

Depende del PR 06 (#43). El contrato está en api/openapi.yaml y los ejemplos sintéticos en api/examples. Las rutas GET/POST /webhooks/whatsapp están diseñadas para el PR 08 y aún no se montan. No se envía nada a Meta, no se registra ninguna cuenta y no se modifican números existentes.

## Configuración y secretos

config/whatsapp.env.example enumera nombres vacíos. No se carga automáticamente ni incluye valores reales. Inyectar variables en el proceso o en el gestor de secretos del despliegue. Los archivos .env y las claves de Rails están excluidos de Git.

| Variable | Uso |
| --- | --- |
| WHATSAPP_APP_SECRET | HMAC del cuerpo original de cada POST, distinto del token de acceso |
| WHATSAPP_VERIFY_TOKEN | Secreto elegido para el challenge GET; no es el token de Graph |
| WHATSAPP_ACCESS_TOKEN | Bearer de Graph; no necesario para recibir eventos |
| WHATSAPP_GRAPH_API_VERSION | Versión explícita con formato vNN.N, elegida para la app de Meta |

Whatsapp::Configuration requiere cada ajuste al usarlo y falla indicando el nombre, sin imprimir su contenido. La aplicación puede arrancar sin credenciales de Meta mientras se desarrolla la base independiente. La URL de Graph tiene host fijo; la versión no acepta una URL arbitraria. El formato no comprueba que la versión exista o esté habilitada para la app: verificar eso en Meta antes de una conexión real.

Para esta primera empresa se prevé una app de Meta y configuración de proceso compartida por sus cuentas/números. No modela todavía el aprovisionamiento de credenciales de terceros ni autoriza acceder a cuentas fuera de los registros de la empresa. WhatsappAccount.external_id será el WABA ID y PhoneNumber.external_id el phone number ID; el número visible no sirve para resolver el receptor.

Los filtros existentes de Rails cubren secret/token y las claves de verificación del GET. No registrar cuerpos de webhook, cabeceras Authorization ni valores de secretos. El PR 08 deberá evitar parámetros parseados y usar bytes originales al verificar la firma.

## Recepción prevista

El GET devuelve el challenge textual solo con modo subscribe y token válido. El POST requiere X-Hub-Signature-256 con HMAC-SHA256 del cuerpo original, resuelve todos los WABA/números del lote y confirma con 200 únicamente tras guardar y encolar. Un fallo de persistencia/cola devuelve 503; firma inválida 401; JSON/estructura inválidos 400; receptor no registrado 422. El límite local diseñado es 1 MiB: no representa un límite publicado por Meta.

Las entregas se pueden repetir: se deberá deduplicar la recepción y, por separado, los IDs de mensajes. El contrato no promete recepción exactamente una vez ni que 200 signifique que el mensaje ya esté procesado. Los ejemplos usan IDs WABA_TEST_001/PHONE_TEST_001, nombres ficticios y números sintéticos; no están listos para usarse contra el proveedor.

## Consulta del proveedor al 30/10/2026

Se consultó Orbit (Postman API Discovery) para suscribir una app al WABA, listar phone number IDs y enviar respuestas de texto. Confirmó Graph con Bearer, POST /{version}/{phone_number_id}/messages y POST /{version}/{waba_id}/subscribed_apps. El resultado fue parcial: no cubre el handshake ni la firma del receptor y conserva un ejemplo antiguo de versión v13.0. No se usa esa versión como configuración por defecto.

La [referencia oficial del SDK de WhatsApp](https://whatsapp.github.io/WhatsApp-Nodejs-SDK/api-reference/webhooks/start/) describe challenge GET y firma POST, pero el SDK está archivado. La documentación directa de Meta consultada devolvió HTTP 429 o no se pudo recuperar. Por eso sigue pendiente confirmar la versión de Graph y la configuración exacta de la app en documentación/dashboard vigentes antes de habilitar una conexión real. No se presenta la consulta parcial como verificación end-to-end.

Fuentes para retomar: [webhooks de Graph](https://developers.facebook.com/docs/graph-api/webhooks/getting-started), [changelog de Graph](https://developers.facebook.com/docs/graph-api/changelog), [documentación de WhatsApp](https://developers.facebook.com/documentation/business-messaging/whatsapp/webhooks/overview). No se validaron políticas de envío de texto/plantillas: eso corresponde a PR 10–12.

## Preparación manual de una línea de prueba

Usar la app y línea de prueba ofrecidas por Meta, registrar sus IDs en una empresa de pruebas y mantener las cinco líneas reales sin cambios. Elegir versión explícita y credenciales del entorno; configurar una URL HTTPS para el webhook cuando PR 08 esté implementado. Suscribir la app al WABA y al campo messages. Distinguir el test del dashboard de un mensaje real: ninguno está ejecutado en esta entrega.

No se asume importación de historial ni coexistencia con el celular. El alta, migración o cambio de operación de las cinco líneas requiere un procedimiento y verificación separados.

## Validación

95 ejemplos RSpec aprobados (seed 6241) tras separar Avo interno de las cuentas de empresa, incluidas pruebas de configuración ausente, versión inválida, URL fija e inspección sin secretos. RuboCop sin infracciones en los dos archivos Ruby nuevos. El contrato se verificó con `postman spec lint api/openapi.yaml --no-report-events --issueType syntax`: sin incidencias. No publica ni crea recursos en Postman. No hay prueba real de Meta ni secretos comprometidos.

## Refactor heredado de acceso

El acceso se consulta mediante las asociaciones de current_agent.company, sin permisos individuales por número ni clase de acceso adicional. No cambia el contrato de WhatsApp ni resuelve las verificaciones pendientes de Meta. Validación sobre esta rama: 100 ejemplos RSpec sin fallos con PostgreSQL temporal; RuboCop de los cuatro archivos Ruby del refactor sin infracciones.

Validación del acceso por empresa: 91 ejemplos RSpec sin fallos con PostgreSQL temporal y RuboCop de once archivos Ruby sin infracciones. No valida conexión real a Meta ni resuelve los pendientes de documentación del proveedor.
