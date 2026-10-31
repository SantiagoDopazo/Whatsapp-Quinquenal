# Cuentas y líneas — PR 05

Depende del PR 04 (#41); la rama sale de feat/company-authorization. No conecta ni migra números en Meta.

WhatsappAccount representa una cuenta de WhatsApp Business de una empresa. PhoneNumber representa una de sus líneas. Ambos guardan nombre, identificador externo y estado local pending/connected/disabled; estos estados son configuración administrativa y todavía no certifican conexión real. PhoneNumber además guarda el número visible. Los identificadores externos son únicos globalmente para resolver eventos sin ambigüedad. No se guardan tokens ni credenciales en estos modelos.

Todos los operarios acceden a todas las líneas y conversaciones de su empresa mediante current_agent.company.phone_numbers y current_agent.company.conversations. No existen permisos individuales por número. Asignar un operario indica quién atiende el chat y no restringe su visibilidad. Las referencias cruzadas entre empresas siguen rechazándose. Avo continúa reservado a Developer.

Las conversaciones nuevas requieren un número de la misma empresa del contacto. Un índice parcial único impide dos conversaciones open/pending para el mismo contacto y línea, también ante escrituras concurrentes. Al cerrar se puede crear otro chat; reabrir el anterior falla si ya hay uno activo. Contacto y línea no se cambian una vez establecidos para conservar la identidad del chat. Las cuentas y números tampoco se pueden trasladar entre empresas.

## Datos anteriores y migración

La migración agrega dos tablas y una referencia nullable a conversations. No crea cuentas ficticias, no asigna números a conversaciones anteriores y no borra datos. Las conversaciones sin línea quedan disponibles para administración interna y para todos los operarios de su empresa; se puede asignar explícitamente una línea conocida. Antes de asignarlas se debe resolver cualquier colisión con otro chat activo del mismo contacto y número. Los operarios pueden ver también las conversaciones anteriores sin línea.

La obligatoriedad para nuevas conversaciones se aplica en Active Record. La columna admite NULL para conservar las anteriores; las escrituras SQL directas pueden omitir las validaciones de pertenencia. Se agregan claves foráneas, índices únicos y restricciones de estados en PostgreSQL. El rollback conserva conversaciones/contactos, pero elimina configuración de cuentas y líneas y su referencia en los chats; exportar esa configuración antes de revertir una base usada.

## Validación

Se comprueban separación por empresa, acceso compartido entre operarios, asignaciones dentro de la empresa, chats independientes por línea, unicidad y migración/rollback. La revisión visual manual sigue pendiente; sin llamadas a Meta.

## Cambio de esquema antes de integrar

Se retira la tabla de permisos de la migración de líneas todavía no integrada a main. Una base local que ya ejecutó la versión anterior necesita recrearse para reflejar este esquema; no se agrega una migración destructiva ni se ejecuta sobre bases habituales.

Resultado de esta simplificación: 61 ejemplos RSpec aprobados en una base temporal nueva, incluyendo ausencia de la tabla de permisos y migración/rollback. RuboCop de los nueve archivos Ruby modificados sin infracciones.
