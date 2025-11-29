#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "=== Ejecutando Scanner en Kubernetes ==="
echo ""

# Verificar que kubectl está disponible
if ! command -v kubectl &>/dev/null; then
    echo "ERROR: kubectl no está instalado"
    exit 1
fi

# Verificar que Minikube está corriendo
echo "Verificando Minikube..."
if ! minikube status | grep -q "Running"; then
    echo "ERROR: Minikube no está corriendo"
    echo "Ejecuta primero: minikube start --cni=calico"
    exit 1
fi
echo "OK: Minikube está corriendo"

# Verificar que el namespace existe
echo "Verificando namespace zero-trust-lab..."
if ! kubectl get namespace zero-trust-lab &>/dev/null; then
    echo "ERROR: Namespace zero-trust-lab no existe"
    echo "Ejecuta primero: ./scripts/k8s-apply.sh"
    exit 1
fi
echo "OK: Namespace existe"

# Verificar que el pod attacker existe y está Running
echo "Verificando pod attacker..."
ATTACKER_POD=$(kubectl get pod -n zero-trust-lab -l app=attacker -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$ATTACKER_POD" ]; then
    echo "ERROR: No se encontró pod attacker"
    echo "Ejecuta primero: ./scripts/k8s-apply.sh"
    exit 1
fi

POD_STATUS=$(kubectl get pod -n zero-trust-lab "$ATTACKER_POD" -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" != "Running" ]; then
    echo "ERROR: Pod attacker no está Running (estado: $POD_STATUS)"
    exit 1
fi
echo "OK: Pod attacker está corriendo ($ATTACKER_POD)"

# Crear directorio reports si no existe
mkdir -p "$(dirname "$0")/../reports"

# Ejecutar scanner
echo ""
echo "Ejecutando scanner..."
echo ""

cd "$(dirname "$0")/.."

# Capturar output del scanner
SCAN_OUTPUT=$(kubectl exec -n zero-trust-lab "$ATTACKER_POD" -- python /app/scanner.py 2>&1)

# Mostrar output completo
echo "$SCAN_OUTPUT"

# Extraer JSON del output (líneas entre { y })
JSON_OUTPUT=$(echo "$SCAN_OUTPUT" | sed -n '/^{/,/^}/p')

if [ -z "$JSON_OUTPUT" ]; then
    echo ""
    echo "ERROR: No se generó JSON válido"
    exit 1
fi

# Guardar reporte
REPORT_FILE="reports/k8s-connectivity.json"
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

        if [ "$OPEN" -eq 0 ]; then
            echo ""
            echo "ÉXITO: NetworkPolicies bloqueando todo el tráfico no autorizado"
        else
            echo ""
            echo "ADVERTENCIA: Hay $OPEN puertos abiertos"
        fi
    fi
else
    echo "ERROR: No se pudo crear el reporte"
    exit 1
fi

echo ""
