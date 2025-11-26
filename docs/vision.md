# Visión del Proyecto: Zero-Trust Network Sandbox

## 1. Contexto
Zero Trust es un modelo de seguridad basado en el principio "nunca confíes, siempre verifica". A diferencia del modelo tradicional de seguridad perimetral, donde se confía en todo dentro de la red, Zero Trust asume que las amenazas pueden existir tanto fuera como dentro de la red, requiriendo verificación explícita para cada acceso.

## 2. Problema que Resuelve
En arquitecturas de contenedores tradicionales con Docker Compose, los servicios que comparten una red pueden comunicarse libremente entre sí. Esto crea riesgos de seguridad críticos:
- **Falta de micro-segmentación**: Todos los servicios se consideran confiables
- **Movimiento lateral**: Un atacante que compromete un servicio puede acceder a todos los demás
- **Superficie de ataque amplia**: No hay control granular sobre comunicaciones entre servicios

## 3. Alcance
### ¿Qué SÍ incluye?
- Tres servicios Python (frontend, backend, attacker)
- Docker Compose con segmentación básica de redes
- Kubernetes con NetworkPolicies para micro-segmentación
- Scanner de red automatizado en Python
- Scripts de orquestación y validación

### ¿Qué NO incluye?
- Aplicaciones web complejas o bases de datos reales
- Sistemas de autenticación/autorización (JWT, OAuth)
- Cifrado de tráfico (mTLS, service mesh)
- Despliegue en cloud providers
- Alta disponibilidad o escalado automático

## 4. Objetivos
### Objetivos Técnicos
1. Implementar servicios containerizados con mejores prácticas de seguridad
2. Demostrar vulnerabilidades en arquitecturas de red tradicionales
3. Aplicar NetworkPolicies de Kubernetes para implementar Zero Trust
4. Automatizar la validación de seguridad mediante scanner de red
5. Medir y comparar superficie de ataque antes/después

### Objetivos de Aprendizaje
1. Comprender principios Zero Trust aplicados a contenedores
2. Dominar NetworkPolicies de Kubernetes para micro-segmentación
3. Desarrollar habilidades en herramientas DevSecOps
4. Aprender debugging de conectividad en entornos restringidos

## 5. Inspiración en Caso Real
Este laboratorio se basa en un escenario real de una empresa fintech que sufrió un incidente de seguridad donde atacantes, tras comprometer el servicio frontend mediante phishing, pudieron moverse lateralmente y acceder directamente a APIs de transacciones sensibles debido a la falta de segmentación de red. El proyecto simula esta vulnerabilidad y demuestra cómo NetworkPolicies pueden prevenirla.