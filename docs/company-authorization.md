# API por empresa y Avo interno — PR 04

Depende de la base de empresas (PR 03) y del soporte de pruebas #40. Existen dos identidades separadas:

| Identidad | Acceso | Ámbito |
| --- | --- | --- |
| Agent, roles admin/agent | API autenticada y futuro frontend BO de empresas | Todos los datos de su empresa, sin permisos individuales por número |
| Developer | Login interno /login y Avo | Administración interna de todas las empresas |

El rol admin de Agent no habilita Avo. Una sesión o JWT de agente recibe 403 en el panel interno. Sus credenciales tampoco permiten iniciar sesión en /login. Developer tiene una tabla y un scope Devise independientes, sin company_id, sin JWT, sin registro público ni recurso CRUD para crear desarrolladores. Las cuentas internas se aprovisionan fuera del BO de clientes.

## API de las empresas

`POST /agents/sign_in` mantiene la autenticación de agentes; `GET /agents/:id` devuelve id, email, name y role solo para compañeros de la empresa del usuario. Un ID ajeno devuelve 404, igual que uno inexistente; sin autenticación devuelve 401. Las consultas parten de current_agent.company y sus asociaciones. No hay una clase de acceso adicional ni permisos individuales por número; el rol admin de una empresa tampoco concede privilegios internos.

El secreto JWT usa Rails.application.secret_key_base, respetando la resolución de Rails por entorno/credenciales. No depende exclusivamente de que pueda descifrarse el archivo de credenciales en el checkout de pruebas. Una sesión interna no inicia sesión como agente ni emite JWT de empresa.

## Panel interno

Avo es la consola interna de los desarrolladores para administrar flags de funcionalidades, configuración del backend y configuración de cada frontend/empresa. La configuración global del sistema y la específica de una empresa deben distinguirse explícitamente al modelarlas. El frontend de clientes consume únicamente la configuración autorizada de su empresa a través de la API; nunca accede a Avo ni recibe secretos del backend.

Esta entrega implementa la separación de identidades y el acceso al panel. Los modelos y pantallas de flags/configuración se incorporarán cuando se definan sus claves, valores y alcance; todavía no están implementados. Avo no es la bandeja operativa de atención de las empresas: esa interfaz BO será independiente.

Avo autentica current_developer y permite aprovisionar empresas, crear agentes/contactos eligiendo una empresa explícita y administrar registros de diferentes empresas. No se asigna una empresa a partir del desarrollador, que no pertenece a ninguna. Las validaciones de integridad de modelos siguen rechazando pertenencias o referencias cruzadas inconsistentes.

El formulario identifica el acceso como interno, protege contra CSRF y renueva la sesión al autenticar. DELETE /logout cierra la sesión Developer. Un visitante sin sesión va a /login. No se agregan usuarios internos por defecto ni se convierten agentes existentes.

## Alta inicial y recuperación de acceso

Ejecutar `bundle exec rails db:seed` sobre una base limpia crea el usuario de ejemplo dev@example.com, nombre Desarrollador y contraseña password123. El alta usa Developer.create! con valores fijos; no utiliza variables SEED_DEVELOPER_*. No comprueba existencia ni conserva idempotencia: repetir sobre una cuenta existente falla por email duplicado.

Las altas posteriores y los cambios de contraseña se realizan con acceso de confianza al servidor/Rails console. No hay recuperación pública de contraseñas internas en esta entrega. Las credenciales de agentes y desarrolladores son independientes, aunque sus emails coincidan. La autenticación interna no incorpora todavía MFA, auditoría de acciones ni una restricción de red: son controles posteriores al alcance actual.

## Migración y validación

La migración agrega developers con nombre, email único y contraseña cifrada por Devise. No modifica agentes, empresas ni contactos ni asigna privilegios a registros existentes. El rollback elimina las identidades internas y su acceso al panel; conserva los datos de las empresas.

Se verifican login interno, logout, rechazo de credenciales de empresas, sesiones separadas, aislamiento de la API con JWT real, integridad de referencias, alta de desarrollador con datos de ejemplo sobre una base limpia y migración/rollback. Las pruebas de vistas se ejecutan fuera del sandbox porque sus restricciones de enumeración de rutas absolutas impiden que Rails encuentre templates locales. La revisión visual manual queda pendiente; no hay llamadas a Meta.

## Consultas explícitas de acceso

Se usan current_agent.company.agents, contacts y conversations; desde PR 05 también phone_numbers y desde PR 06 messages. Todos los operarios comparten el ámbito de su empresa. La autenticación sigue siendo obligatoria antes de consultar; un ID ajeno devuelve 404.

Validación de seeds fijas: ejemplo de alta en PostgreSQL temporal y RuboCop de seeds/spec.

Las seeds crean empresa, agente y desarrollador directamente con datos fijos. Para volver a cargarlas, recrear la base mediante rails db:drop db:create db:migrate db:seed. Ese comando elimina los datos anteriores; db:seed por sí solo no limpia la base.
