# Backlog Sprint 01 (Zero Trust)
## Issue 01 : Estructura del proyecto y configuración inicial

**ID** : 1

**Descripción:** Crear la estructura de carpetas del proyecto y configurar archivos básicos como .gitignore y .dockerignore.

**Criterios de aceptación:**
- Estructura de carpetas completa y visible en GitHub
- .gitignore ignora archivos temporales y .env
- `README.md` tiene descripción del proyecto
- Todo el equipo puede clonar el repositorio
  
**Responsable:** Diego Pineda

**Estimación:** 1

## Issue 02 : Servicios Python básicos

**ID** : 2

**Descripción:** Implementar tres aplicaciones Python simples usando Flask: frontend, backend y attacker (con estructura básica).

**Criterios de aceptación:** 
- Frontend responde en puerto 8080 con mensaje "Frontend OK"
- Backend responde en puerto 5000 con mensaje "Backend OK"
- Attacker tiene archivo `scanner.py` con estructura básica
- Servicios corren localmente con python `app.py`

**Responsable:** Mateo Torres

**Estimación:** 2

## Issue 03 : Dockerfiles para los servicios

**ID** : 3

**Descripción:** Crear Dockerfiles para cada servicio siguiendo buenas prácticas de seguridad.

**Criterios de aceptación:**
- Cada servicio construye imagen sin errores
- Imágenes ejecutan como usuario no root
- Imágenes son menores a 200MB
- Servicios funcionan al correr docker run

**Responsable:** Diego Pineda

**Estimación:** 3

## Issue 04 : Docker Compose con redes 

**ID** : 4

**Descripción:** Crear archivo `docker-compose.yml` que levante los tres servicios con redes separadas.

**Criterios de aceptación:** 
- `docker-compose up` levanta 3 servicios
- Frontend puede conectarse a backend
- Attacker está aislado en su propia red
- Servicios tienen límites de recursos configurados

**Responsable:** Diego Pineda

**Estimación:** 3

## Issue 05 : Script de orquestación

**ID** : 6

**Descripción:** Crear scripts Bash para levantar y bajar el stack de Docker Compose fácilmente.

**Criterios de aceptación:**
- `./scripts/compose-up.sh` levanta el stack correctamente
- `./scripts/compose-down.sh` baja el stack y limpia
- Scripts muestran mensajes claros de éxito/error
- Scripts funcionan desde la raíz del proyecto

**Responsable:** Luis Trujillo

**Estimación:** 3

## Issue 06 : Implementar logica del scanner.py

**ID** : 7

**Descripción:** Implementar la lógica del scanner que intenta conectarse a diferentes puertos de los servicios.

**Criterios de aceptación:**
- Scanner intenta conectar a `frontend:8080`, `backend:5000`, etc.
- Genera JSON con resultados (OPEN/CLOSED)
- Ejecutable dentro del contenedor attacker
- JSON es válido y parseable

**Responsable:** Mateo Torres

**Estimación:** 2

## Issue 07 : Script de escaneo

**ID** : 8

**Descripción:** Crear script que ejecuta el scanner y guarda los resultados en un archivo JSON.

**Criterios de aceptación:**
- `./scripts/compose-scan.sh` ejecuta sin errores
- Genera archivo `reports/compose-connectivity.json`
- JSON contiene resultados del escaneo
- Script muestra mensajes informativos

**Responsable:** Luis Trujillo

**Estimación:** 2

## Issue 08 : Implementar Makefile

**ID** : 9

**Descripción:** Crear Makefile con comandos para facilitar el uso del proyecto.

**Criterios de aceptación:**
- `make help` muestra lista de comandos
- `make compose-up` funciona correctamente
- `make compose-scan` ejecuta el escaneo
- `make compose-down` baja el stack

**Responsable:** Mateo Torres

**Estimación:** 2

## Issue 09 : Documento visión

**ID** : 10

**Descripción:** Escribir documento que explica el contexto, problema y objetivos del proyecto.

**Criterios de aceptación:**
- Documento tiene mínimo 500 palabras
- Explica claramente el contexto de Zero Trust
- Define objetivos del proyecto
- Está bien redactado sin errores graves
  
**Responsable:** Luis Trujillo

**Estimación:** 1

## Issue 10 : Documento de Métricas

**ID** : 11

**Descripción:** Crear plantilla para registrar métricas del Sprint 1 (se llenará durante el sprint).

**Criterios de aceptación:**
- Documento tiene estructura clara
- Incluye: Throughput, Lead Time, WIP, Puertos Alcanzables.
- Cada métrica tiene definición y espacio para valor.
- Nota indica que se llenará durante el sprint.

**Responsable:** Mateo Torres

**Estimación:** 1

## Issue 11 : Documento Risk register

**ID** : 12

**Descripción:** Identificar y documentar los principales riesgos del proyecto con planes de mitigación.

**Criterios de aceptación:** 
- Documento lista mínimo 5 riesgos
- Cada riesgo tiene descripción, probabilidad e impacto
- Incluye planes de mitigación realistas
- Riesgos son específicos del proyecto

**Responsable:** Luis Trujillo

**Estimación:** 1

## Issue 12 : Documento Definition of done

**ID** : 13

**Descripción:** Crear documento con checklist de requisitos para considerar una historia como terminada.

**Criterios de aceptación:**
- Documento tiene checklist claro.
- Criterios son verificables (sí/no).
- Incluye nota sobre lo que NO se requiere.
- Es realista para nivel estudiantes.

**Responsable:** Luis Trujillo

**Estimación:** 1





