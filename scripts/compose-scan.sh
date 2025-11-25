#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "=== Ejecutando Scanner de Red ==="
echo ""

# Verificar que Docker está corriendo
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker no está corriendo"
    exit 1
fi

# Cambiar al directorio compose
cd "$(dirname "$0")/../compose"

# Verificar que el stack está corriendo
echo "Verificando que el stack está corriendo..."
if ! docker compose ps | grep -q "Up"; then
    echo "ERROR: El stack no está corriendo"
    echo "Ejecuta primero: ./scripts/compose-up.sh"
    exit 1
fi
echo "OK: Stack está corriendo"

# Verificar que el contenedor attacker existe
if ! docker ps | grep -q "zero-trust-attacker"; then
    echo "ERROR: Contenedor attacker no encontrado"
    exit 1
fi

# Conectar attacker a backend-net (simula brecha de seguridad)
echo "==== Simulando brecha de seguridad ===="
echo ""
echo "El attacker se esta conectado a la red backend-net ..."
docker network connect zero-trust-backend-net zero-trust-attacker 2>/dev/null || echo "(Ya estaba conectado)"

# Ejecutar scanner
echo ""
echo "Ejecutando scanner..."
echo ""

cd ..
mkdir -p reports

# Capturar output del scanner
SCAN_OUTPUT=$(docker exec zero-trust-attacker python /app/scanner.py 2>&1)

# Mostrar output
echo "$SCAN_OUTPUT"

# Extraer JSON del output (líneas entre { y })
JSON_OUTPUT=$(echo "$SCAN_OUTPUT" | sed -n '/^{/,/^}/p')

if [ -z "$JSON_OUTPUT" ]; then
    echo ""
    echo "ERROR: No se generó JSON válido"
    exit 1
fi

# Guardar reporte
REPORT_FILE="reports/compose-connectivity.json"
echo "$JSON_OUTPUT" >"$REPORT_FILE"

if [ -f "$REPORT_FILE" ]; then
    echo ""
    echo "OK: Reporte guardado en $REPORT_FILE"

    # Mostrar resumen si jq está disponible
    if command -v jq &>/dev/null; then
        echo ""
        echo "Resumen del escaneo:"
        OPEN=$(jq -r '.summary.open' "$REPORT_FILE")
        CLOSED=$(jq -r '.summary.closed' "$REPORT_FILE")
        ERRORS=$(jq -r '.summary.errors' "$REPORT_FILE")

        echo "  Puertos abiertos: $OPEN"
        echo "  Puertos cerrados: $CLOSED"
        echo "  Errores: $ERRORS"
    fi
else
    echo "ERROR: No se pudo crear el reporte"
    exit 1
fi
