# Cuentas y líneas — PR 05

Depende del PR 04 (#41); la rama sale de feat/company-authorization. No conecta ni migra números en Meta.

WhatsappAccount representa una cuenta de WhatsApp Business de una empresa. PhoneNumber representa una de sus líneas. Ambos guardan nombre, identificador externo y estado local pending/connected/disabled; estos estados son configuración administrativa y todavía no certifican conexión real. PhoneNumber además guarda el número visible. Los identificadores externos son únicos globalmente para resolver eventos sin ambigüedad. No se guardan tokens ni credenciales en estos modelos.

Todos los operarios acceden a todas las líneas y conversaciones de su empresa mediante current_agent.company.phone_numbers y current_agent.company.conversations. No existen permisos individuales por número. Asignar un operario indica quién atiende el chat y no restringe su visibilidad. Las referencias cruzadas entre empresas siguen rechazándose. Avo continúa reservado a Developer.

Todas las conversaciones requieren un número de la misma empresa del contacto. Un índice parcial único impide dos conversaciones open/pending para el mismo contacto y línea, también ante escrituras concurrentes. Al cerrar se puede crear otro chat; reabrir el anterior falla si ya hay uno activo. Contacto y línea no se cambian una vez establecidos para conservar la identidad del chat. Las cuentas y números tampoco se pueden trasladar entre empresas.

## Esquema de desarrollo

La migración agrega dos tablas y una referencia obligatoria de conversations a phone_numbers. No se contempla backfill ni conversaciones anteriores sin línea porque la aplicación está en desarrollo y se trabaja sobre una base limpia. La pertenencia de contacto, línea y agente a la misma empresa se valida en los modelos.

Contacto y número de una conversación no pueden cambiar después del alta; cada regla tiene su validación explícita y se ejecuta solo cuando cambia la asociación correspondiente. El índice parcial impide dos chats activos del mismo contacto/número. El rollback elimina la configuración de cuentas y líneas y la referencia de origen.

## Validación

Se comprueban separación por empresa, acceso compartido entre operarios, asignaciones dentro de la empresa, chats independientes por línea, unicidad e inmutabilidad de contacto y número. La revisión visual manual sigue pendiente; sin llamadas a Meta.

## Cambio de esquema antes de integrar

La migración de líneas todavía no integrada a main no crea permisos por número y exige phone_number_id NOT NULL. Una base local que ya ejecutó la versión anterior necesita recrearse para reflejar este esquema; no se agrega una migración destructiva ni se ejecuta sobre bases habituales.
