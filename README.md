# WhatsApp — La Quinquenal

Backend Rails y PostgreSQL para una bandeja compartida de WhatsApp. El primer cliente será La Quinquenal, con cinco números y varios operarios. La integración real con WhatsApp y el frontend de atención se desarrollan por entregas.

## Panel interno y BO de empresas

Avo es exclusivo de los desarrolladores del sistema. Su propósito es administrar flags, configuración del backend y configuración de cada frontend/empresa. El acceso usa cuentas Developer independientes de los agentes; ser administrador de una empresa no permite entrar a Avo.

Las empresas tendrán su propio frontend BO y usarán la API como Agent, con aislamiento por empresa y permisos por número. La configuración que reciba cada frontend debe limitarse a los valores autorizados de su empresa, sin secretos del backend.

La separación de identidades y el acceso interno están implementados. Los flags, sus pantallas de configuración y el frontend BO todavía no están implementados.

## Documentación

- [Estado de entregas y pendientes para retomar](docs/development-status.md).
- [Acceso interno, API por empresa y alta de desarrolladores](docs/company-authorization.md).
- [Entorno de pruebas y comprobaciones de CI](docs/test-environment.md).
- [Base de empresas y migración](docs/company-foundation.md).
