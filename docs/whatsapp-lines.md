# Cuentas, líneas y permisos — PR 05

Depende del PR 04 (#41); la rama sale de feat/company-authorization. No conecta ni migra números en Meta.

WhatsappAccount representa una cuenta de WhatsApp Business de una empresa. PhoneNumber representa una de sus líneas. Ambos guardan nombre, identificador externo y estado local pending/connected/disabled; estos estados son configuración administrativa y todavía no certifican conexión real. PhoneNumber además guarda el número visible. Los identificadores externos son únicos globalmente para resolver eventos sin ambigüedad. No se guardan tokens ni credenciales en estos modelos.

Cada operario comienza sin acceso a líneas. Un administrador puede crear y eliminar PhoneNumberAccess desde Avo para otorgar o revocar acceso; solo acepta referencias de su empresa. Los administradores tienen acceso a todas sus líneas. CompanyAccess limita conversaciones por empresa y por las líneas autorizadas. La asignación de una conversación rechaza operarios sin acceso. Revocar un permiso quita visibilidad inmediatamente, aunque conserva el agente asignado como dato histórico; un administrador deberá reasignar el chat para continuar trabajando con él.

Las conversaciones nuevas requieren un número de la misma empresa del contacto. Un índice parcial único impide dos conversaciones open/pending para el mismo contacto y línea, también ante escrituras concurrentes. Al cerrar se puede crear otro chat; reabrir el anterior falla si ya hay uno activo. Contacto y línea no se cambian una vez establecidos para conservar la identidad del chat. Las cuentas y números tampoco se pueden trasladar entre empresas.

## Datos anteriores y migración

La migración agrega tres tablas y una referencia nullable a conversations. No crea cuentas ficticias, no asigna números a conversaciones anteriores y no borra datos. Las conversaciones sin línea quedan disponibles solo para administradores y se pueden editar o asignar explícitamente a una línea conocida. Antes de asignarlas se debe resolver cualquier colisión con otro chat activo del mismo contacto y número. Los operarios no ven conversaciones sin origen conocido.

La obligatoriedad para nuevas conversaciones se aplica en Active Record. La columna admite NULL para conservar las anteriores; las escrituras SQL directas pueden omitir las validaciones de pertenencia. Se agregan claves foráneas, índices únicos y restricciones de estados en PostgreSQL. El rollback conserva conversaciones/contactos, pero elimina configuración de cuentas, líneas y permisos y su referencia en los chats; exportar esa configuración antes de revertir una base usada.

## Validación

- 56 ejemplos RSpec aprobados, seed 9721, con PostgreSQL temporal y dependencias exactas.
- Migración y rollback sobre un registro anterior: conserva el chat y no inventa una línea.
- Dos líneas para un contacto, unicidad de chat activo, asignación autorizada, revocación, referencias cruzadas e inmutabilidad.
- Requests de Avo: alta de cuenta con empresa de la sesión, listados por empresa y alta/baja de permisos.
- RuboCop sin infracciones en 41 archivos revisados. Revisión visual manual del BO pendiente; sin llamadas a Meta.
