# Registro de Riesgos - Zero-Trust Network Sandbox

## R1: Docker no funciona correctamente
**Descripción:** Docker Desktop no inicia, tiene problemas de permisos, o da errores de configuración en algunos equipos.

**Probabilidad:** Alta  
**Impacto:** Crítico

**Plan de mitigación:**
- Verificar instalación y funcionamiento el primer día del proyecto
- Probar comandos básicos: `docker --version`, `docker run hello-world`
- Tener documentadas soluciones para errores comunes de Docker
- Usar laptop de otro compañero temporalmente si persisten los problemas

**Estado:** Abierto

## R2: Complejidad de Kubernetes y NetworkPolicies
**Descripción:** El equipo no tiene experiencia previa con Kubernetes. Los conceptos de NetworkPolicies pueden ser difíciles de implementar correctamente.

**Probabilidad:** Alta  
**Impacto:** Alto

**Plan de mitigación:**
- Dedicar tiempo durante el Sprint 1 para aprender Kubernetes básico
- Utilizar ejemplos simples de la documentación oficial
- Probar NetworkPolicies progresivamente (de simple a complejo)
- Buscar ayuda en documentación y foros si surgen bloqueos

**Estado:** Abierto

## R3: Problemas de conectividad entre contenedores
**Descripción:** El scanner desde el contenedor attacker no puede comunicarse con otros servicios debido a problemas de DNS o configuración de red.

**Probabilidad:** Media  
**Impacto:** Alto

**Plan de mitigación:**
- Verificar la conectividad de red entre servicios desde el inicio
- Probar resolución DNS dentro de los contenedores
- Implementar verificación de conectividad en los scripts de testing
- Usar direcciones IP como alternativa si falla la resolución por nombre

**Estado:** Abierto

## R4: Configuración insegura en servicios
**Descripción:** Los contenedores o políticas de red se configuran de manera que permiten acceso no autorizado, comprometiendo el principio Zero Trust.

**Probabilidad:** Media  
**Impacto:** Alto

**Plan de mitigación:**
- Revisar y validar todas las NetworkPolicies antes de implementarlas
- Verificar que los servicios corran con usuarios no privilegiados
- Ejecutar el scanner regularmente para validar las restricciones
- Documentar y corregir cualquier configuración que permita acceso no autorizado

**Estado:** Abierto

## R5: Minikube/Kubernetes consume demasiados recursos
**Descripción:** Minikube requiere 2GB+ RAM mínimo. En laptops con 8GB RAM y otras aplicaciones abiertas, el sistema se vuelve lento o Minikube no inicia.

**Probabilidad:** Media  
**Impacto:** Alto

**Plan de mitigación:**
- Verificar recursos disponibles antes de instalar Minikube
- Configurar Minikube con recursos limitados: `minikube start --memory=2048 --cpus=2`
- Cerrar aplicaciones no esenciales durante el trabajo con Kubernetes
- Considerar usar Kubernetes online (Killercoda) como alternativa

**Estado:** Abierto

## R6: Conflictos de merge por trabajo paralelo
**Descripción:** Múltiples personas trabajando en los mismos archivos simultáneamente causan conflictos de Git difíciles de resolver.

**Probabilidad:** Media  
**Impacto:** Medio

**Plan de mitigación:**
- Coordinar el trabajo en archivos críticos mediante comunicación en el equipo
- Utilizar branches por feature y hacer merge frecuente a develop
- Realizar `git pull origin develop` antes de empezar a trabajar
- Establecer responsables específicos para archivos críticos

**Estado:** Abierto