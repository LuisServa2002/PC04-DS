# Definition of Done (DoD)

## Criterios Mínimos para Marcar como DONE

### 1. Funcionalidad Verificada
- Código/script funciona según criterios de aceptación
- Probado en al menos 2 ambientes diferentes
- Comandos ejecutan desde raíz del proyecto: `make <target>` o `./scripts/<script>.sh`

### 2. Calidad de Código
- No hay `TODO` críticos sin justificar en el código
- Comentarios en español explican lógica compleja
- Code review aprobado por al menos otro miembro del equipo

### 3. Evidencias de Seguridad
- Evidencias generadas (scans, reports, SBOM) en carpeta `reports/`
- Scanner de red funciona y genera JSON válido (si aplica)
- No se introducen configuraciones inseguras

### 4. Documentación Actualizada
- `README.md` actualizado con cambios relevantes
- Nuevos comandos documentados en `Makefile` o scripts
- Commit sigue conventional commits (`feat:`, `fix:`, `docs:`, etc.)

### 5. Integridad del Sistema
- No rompe funcionalidad existente
- `./scripts/compose-up.sh` ejecuta sin errores (Sprint 1)
- Stack completo se levanta correctamente