#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "=== Limpiando Recursos de Kubernetes ==="
echo ""

# Verificar que kubectl está disponible
if ! command -v kubectl &>/dev/null; then
    echo "ERROR: kubectl no está instalado"
    exit 1
fi

# Verificar que el namespace existe
if ! kubectl get namespace zero-trust-lab &>/dev/null; then
    echo "Namespace zero-trust-lab no existe (ya estaba limpio)"
    exit 0
fi

# Mostrar recursos actuales
echo "Recursos actuales en zero-trust-lab:"
kubectl get all -n zero-trust-lab
echo ""

# Pedir confirmación
read -p "¿Deseas eliminar el namespace zero-trust-lab? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operación cancelada"
    exit 0
fi

# Eliminar namespace (esto elimina todo lo que contiene)
echo "Eliminando namespace..."
kubectl delete namespace zero-trust-lab

echo ""
echo "Namespace eliminado correctamente"
echo ""

# Preguntar si eliminar reportes
read -p "¿Deseas eliminar los reportes también? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$(dirname "$0")/.."
    rm -f reports/k8s-connectivity.json
    rm -f reports/comparison.json
    echo "Reportes eliminados"
fi

echo ""
echo "Limpieza completada"
echo ""
