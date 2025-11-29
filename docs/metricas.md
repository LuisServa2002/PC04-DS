# Métricas del Proyecto

---

## Sprint 1

### Métricas de Proceso (Scrum/Kanban)

#### Throughput
- **Issues completados**: 11 de 13
- **Story Points completados**: 21 de 22

#### Lead Time
- **Promedio**: 1.9 horas
- **Desglose por issue**:
  - Issue #1: 1 hora
  - Issue #2: 2 horas
  - Issue #3: 3 horas
  - Issue #4: 3 horas
  - Issue #6: 3 horas
  - Issue #7: 2 horas
  - Issue #8: 2 horas
  - Issue #9: 2 horas
  - Issue #10: 1 hora
  - Issue #12: 1 hora
  - Issue #13: 1 hora

#### WIP (Work In Progress)
- **Límite acordado**: 2 issues simultáneos por persona
- **WIP máximo observado**: 4 issues
- **Veces que violamos el límite**: 1

---

### Métricas de Calidad Técnica / CI

#### Builds/Ejecuciones
- **Total de ejecuciones de make compose-up**: 6
  - Exitosas: 4
  - Fallidas: 2 (errores en docker-compose.yml por la versión de docker)
- **Total de ejecuciones de make compose-scan**: 4
  - Exitosas: 4
  - Fallidas: 0
- **Tiempo promedio de `docker-compose build`**: ~20 segundos

---

### Métricas de Seguridad (Zero-Trust)

#### Puertos alcanzables (Compose - SIN NetworkPolicies)

**Escenario**: Attacker conectado a backend-net (simula brecha de seguridad)

- **Puertos alcanzables**: 2
  - frontend:8080 → OPEN
  - backend:5000 → OPEN  **PROBLEMA IDENTIFICADO**
- **Puertos cerrados**: 1
  - backend:5432 → CLOSED (puerto simulado)

**Reporte JSON**: `reports/compose-connectivity.json`

#### Vulnerabilidades detectadas

| ID | Descripción | Severidad | Estado |
|----|-------------|-----------|--------|
| V-001 | Attacker puede acceder a backend:5000 sin restricciones | Alta | Identificada |
| V-002 | Frontend y backend en la misma red sin aislamiento explícito | Media | Identificada |

**Total vulnerabilidades**: 2 (Alta: 1, Media: 1)
**Vulnerabilidades mitigadas en Sprint 1**: 0
**Pendientes para Sprint 2**: 2 (se mitigarán con NetworkPolicies en K8s)


## Sprint 2

### Métricas de Proceso (Scrum/Kanban)

#### Throughput
- **Issues completados**: 15 de 15
- **Story Points completados**: 29 de 29

#### Lead Time
- **Promedio**: 1.9 horas
- **Desglose por issue**:
  - Issue #19: 1 hora
  - Issue #20: 3 horas
  - Issue #21: 3 horas
  - Issue #22: 2 horas
  - Issue #23: 2 horas
  - Issue #24: 2 horas
  - Issue #25: 3 horas
  - Issue #26: 2 horas
  - Issue #27: 2 hora
  - Issue #28: 2 hora
  - Issue #29: 2 hora
  - Issue #30: 1 hora
  - Issue #31: 2 hora
  - Issue #32: 1 hora
  - Issue #37: 1 hora


#### WIP (Work In Progress)
- **Límite acordado**: 2 issues simultáneos por persona
- **WIP máximo observado**: 4 issues
- **Veces que violamos el límite**: 0

---

### Métricas de Calidad Técnica / CI

#### Builds/Ejecuciones
- **Total de ejecuciones de make k8s-apply**: 3
  - Exitosas: 3
  - Fallidas: 0
- **Total de ejecuciones de make k8s-scan**: 3
  - Exitosas: 3
  - Fallidas: 0
- **Tiempo promedio de despliegue K8s**: 15 segundos

---

### Métricas de Seguridad (Zero-Trust)

#### Puertos alcanzables (K8s - CON NetworkPolicies)

**Escenario**: Attacker aislado en pod separado intentando acceder a servicios

- **Puertos alcanzables**: 0
  - frontend:8080 → CLOSED
  - backend:5000 → CLOSED
  - backend:5432 → CLOSED
- **Puertos bloqueados**: 3

**Reporte JSON**: `reports/k8s-connectivity.json`

#### Comparación Compose vs Kubernetes

| Métrica | Compose (Sprint 1) | K8s (Sprint 2) | Mejora |
|---------|-------------------|----------------|--------|
| Puertos abiertos | 2 | 0 | 66% |
| Superficie de ataque | Alta | Nula | - |
| Tiempo de detección | Manual | Automatizado | ✓ |

**Reporte de comparación**: `reports/comparison.json`

#### Vulnerabilidades mitigadas

| ID | Descripción | Severidad | Estado Sprint 1 | Estado Sprint 2 |
|----|-------------|-----------|-----------------|-----------------|
| V-001 | Attacker puede acceder a backend:5000 sin restricciones | Alta | Identificada | **Mitigada** |
| V-002 | Frontend y backend en la misma red sin aislamiento explícito | Media | Identificada | **Mitigada** |

**Total vulnerabilidades Sprint 2**: 0 
**Vulnerabilidades mitigadas**: 1
**Nuevas vulnerabilidades identificadas**: 0

#### NetworkPolicies implementadas

- `default-deny-all`: Bloquea todo tráfico por defecto 
- `allow-dns`: Permite resolución DNS para todos los pods 
- `allow-frontend-to-backend`: Permite comunicación frontend → backend:5000 
- `isolate-attacker`: Aísla completamente el pod attacker 

---