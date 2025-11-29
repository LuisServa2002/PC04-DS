# Backlog Sprint 02 (Zero Trust)
## Issue 01 : Namespace para el proyecto

**ID** : 19

**Descripción:** Crear un namespace dedicado para aislar los recursos del proyecto en Kubernetes.

**Criterios de aceptación:**
- Archivo `namespace.yaml` existe y es válido
- Namespace `zero-trust-lab` está creado
- `kubectl get ns zero-trust-lab` muestra el namespace
- Archivo sigue estructura YAML correcta

**Responsable:** Diego Pineda

**Estimación:** 1

## Issue 02 : Deployment y Service para Frontend

**ID** : 20

**Descripción:** Crear manifiestos de Kubernetes para desplegar el servicio Frontend.

**Criterios de aceptación:**
 Deployment crea 1 pod de frontend
- Pod está en estado `Running`
- Service expone el puerto correctamente
- Se puede acceder al frontend: `minikube service frontend -n zero-trust-lab`
- Manifiestos tienen `resources.requests` y `resources.limits`

**Responsable:** Diego Pineda

**Estimación:** 3

## Issue 03 : Deployment y Service para Backend

**ID** : 21

**Descripción:** Crear manifiestos de Kubernetes para desplegar el servicio Backend (solo accesible internamente).

**Criterios de aceptación:**
- Deployment crea 1 pod de backend
- Pod está en estado `Running`
- Service es tipo ClusterIP (interno)
- Backend NO es accesible desde fuera del cluster
- Frontend puede hacer `curl` a `backend:5000`

**Responsable:** Diego Pineda

**Estimación:** 3

## Issue 04 : Deployment para Attacker

**ID** : 22

**Descripción:** Crear manifiesto para el pod Attacker que ejecutará el scanner.

**Criterios de aceptación:**
- Deployment crea 1 pod attacker
- Pod permanece Running
- Se puede ejecutar: `kubectl exec -it <pod> -n zero-trust-lab -- /bin/sh`
- Pod tiene `scanner.py` en `/app/`

**Responsable:** Diego Pineda

**Estimación:** 2

## Issue 05 : NetworkPolicy - Default Deny

**ID** : 23

**Descripción:** Crear NetworkPolicy que bloquea TODO el tráfico por defecto.

**Criterios de aceptación:**
- Archivo existe
- Política aplicada: `kubectl get networkpolicies -n zero-trust-lab`
- Frontend NO puede conectarse a backend
- Attacker NO puede conectarse a nada

**Responsable:** Diego Pineda

**Estimación:** 2

## Issue 06 : NetworkPolicy - Allow DNS

**ID** : 24

**Descripción:** Crear NetworkPolicy que permite resolución DNS.

**Criterios de aceptación:**
- Archivo existe
- Política aplicada
- Pods pueden resolver DNS: `kubectl exec <pod> -- nslookup backend`
- Pero aún NO pueden conectarse (sin ingress)

**Responsable:** Diego Pineda 

**Estimación:** 2 

## Issue 07 : NetworkPolicy - Allow Comunicacion del Frontend al Backend 

**ID** : 25

**Descripción:** Crear NetworkPolicy que permite SOLO frontend → `backend:5000`.

**Criterios de aceptación:**
- Archivo existe
- Frontend puede conectarse a `backend:5000`
- Attacker NO puede conectarse a `backend:5000`
- Scanner reporta backend CLOSED desde attacke

**Responsable:** Diego Pineda

**Estimación:** 3

## Issue 08 : NetworkPolicy - Isolate Attacker

**ID** : 26

**Descripción:** Crear NetworkPolicy que aísla completamente al attacker.

**Criterios de aceptación:**
- Archivo existe
- Attacker NO puede conectarse a backend
- Attacker NO puede conectarse a frontend
- Scanner reporta TODO CLOSED

**Responsable:** Diego Pineda

**Estimación:** 2

## Issue 09 : Adaptar scanner para Kubernetes

**ID** : 27

**Descripción:** Modificar scanner.py para funcionar en Kubernetes.

**Criterios de aceptación:**
- Scanner detecta nombres K8s
- Ejecutable en pod attacker
- Genera JSON válido
- Funciona: `kubectl exec <pod> -- python /app/scanner.py`

**Responsable:** Mateo Torres

**Estimación:** 2

## Issue 10 : Script k8s-apply.sh

**ID** : 28

**Descripción:** Crear script que aplica todos los manifiestos de Kubernetes.

**Criterios de aceptación:**
- Script ejecuta sin errores
- Aplica todos los manifiestos
- Muestra estado final
- Funciona: `./scripts/k8s-apply.sh`

**Responsable:** Luis Trujillo

**Estimación:** 2

## Issue 11 : Script k8s-scan.sh 

**ID** : 29

**Descripción:** Crear script que ejecuta el scanner en el pod attacker.

**Criterios de aceptación:**
- cript ejecuta sin errores
- Genera `reports/k8s-connectivity.json`
- Muestra resumen en terminal
- Funciona: `./scripts/k8s-scan.sh`

**Responsable:** Luis Trujillo

**Estimación:** 2

## Issue 12 : Script k8s-clean.sh

**ID** : 30

**Descripción:** Crear script que elimina todos los recursos de Kubernetes.

**Criterios de aceptación:**
- Script ejecuta sin errores
- Elimina namespace completo
- Pide confirmación
- Funciona: `./scripts/k8s-clean.sh`

**Responsable:** Luis Trujillo

**Estimación:** 1

## Issue 13 : Script compare-reports.py

**ID** : 31

**Descripción:** Crear script que compara reportes de Compose vs K8s.

**Criterios de aceptación:**
- Script lee ambos reportes
- Calcula métricas correctamente
- Genera comparison.json
- Muestra resumen en terminal

**Responsable:** Mateo Torres

**Estimación:** 2

## Issue 14 : Actualizar Makefile

**ID** : 32

**Descripción:** Actualizar targets del Makefile para solucionar errores técnicos.

**Criterios de aceptación:**
- Todos los targets funcionan
- `make help` muestra comandos K8s
- Targets llaman a scripts correctos

**Responsable:** Mateo Torres

**Estimación:** 1
