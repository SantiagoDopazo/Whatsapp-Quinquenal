# Autorización por empresa — PR 04

Depende del PR 03 de empresas y del PR de soporte de pruebas #40. La empresa siempre se obtiene del usuario autenticado, nunca de un parámetro de selección global. No hay administrador global ni acceso de soporte entre clientes.

`GET /agents/:id` conserva su respuesta (id, email, name y role), pero busca solo agentes de la empresa del usuario. Un ID ajeno devuelve 404, igual que uno inexistente; sin autenticación devuelve 401. Los operarios pueden consultar compañeros de su empresa.

Avo es administración y requiere rol admin. Los operarios reciben 403, incluida cualquier petición manipulada para promover su propio rol. La futura bandeja de atención tendrá su propia interfaz y permisos. Cada recurso limita tanto query_scope como find_scope mediante CompanyAccess: listados, detalle, edición, borrado y selectores comparten el mismo ámbito. Sin usuario, el ámbito está vacío.

Al crear operarios y contactos desde Avo, la empresa se asigna desde la sesión. Una referencia de empresa, contacto o agente ajena se rechaza antes de guardar. La empresa propia puede editarse, pero no se pueden crear ni eliminar empresas desde el BO. El alta de empresas sigue siendo una operación de aprovisionamiento fuera del BO.

No agrega migraciones ni modifica datos existentes. Las validaciones de integridad del PR 03 siguen vigentes para escrituras de modelos; no se incorpora seguridad de filas de PostgreSQL.

Verificación: 35 ejemplos RSpec aprobados (seed 4819), incluidas pruebas HTTP con login real, dos empresas, IDs ajenos, referencias cruzadas y elevación de privilegios. RuboCop sin infracciones en los 13 archivos Ruby de esta entrega. Sin conexión a Meta. La revisión visual manual del BO queda pendiente; las respuestas HTML, formularios y mutaciones se verifican mediante requests.
