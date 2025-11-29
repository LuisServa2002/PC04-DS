#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "=== Aplicando Recursos de Kubernetes ==="
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

# Verificar que las imágenes están disponibles en Minikube
echo ""
echo "Verificando imágenes Docker..."
if ! minikube image ls | grep -q "compose-frontend"; then
    echo "ADVERTENCIA: Imágenes no encontradas en Minikube"
    echo "Ejecuta primero:"
    echo "  eval \$(minikube docker-env)"
    echo "  docker compose -f compose/docker-compose.yml build"
    exit 1
fi
echo "OK: Imágenes disponibles"

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.."

# Verificar que existen los manifiestos
if [ ! -d "k8s" ]; then
    echo "ERROR: Directorio k8s/ no existe"
    exit 1
fi

echo ""
echo "--- Fase 1: Namespace ---"
kubectl apply -f k8s/namespace.yaml
echo ""

echo "--- Fase 2: Deployments ---"
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/attacker-deployment.yaml
echo ""

echo "--- Fase 3: Services ---"
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/backend-service.yaml
echo ""

echo "--- Fase 4: NetworkPolicies ---"
kubectl apply -f k8s/networkpolicy-default-deny.yaml
kubectl apply -f k8s/networkpolicy-allow-dns.yaml
kubectl apply -f k8s/networkpolicy-allow-frontend-backend.yaml
kubectl apply -f k8s/networkpolicy-isolate-attacker.yaml
echo ""

# Esperar a que los pods estén listos
echo "Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=frontend -n zero-trust-lab --timeout=60s
kubectl wait --for=condition=ready pod -l app=backend -n zero-trust-lab --timeout=60s
kubectl wait --for=condition=ready pod -l app=attacker -n zero-trust-lab --timeout=60s
echo "OK: Todos los pods están listos"

# Mostrar estado final
echo ""
echo "=== Estado Final ==="
echo ""

echo "Pods:"
kubectl get pods -n zero-trust-lab
echo ""

echo "Services:"
kubectl get services -n zero-trust-lab
echo ""

echo "NetworkPolicies:"
kubectl get networkpolicies -n zero-trust-lab
echo ""

# Contar recursos
PODS_RUNNING=$(kubectl get pods -n zero-trust-lab --field-selector=status.phase=Running --no-headers | wc -l)
SERVICES=$(kubectl get services -n zero-trust-lab --no-headers | wc -l)
NETPOLS=$(kubectl get networkpolicies -n zero-trust-lab --no-headers | wc -l)

echo "Resumen:"
echo "  Pods corriendo: $PODS_RUNNING/3"
echo "  Services: $SERVICES/2"
echo "  NetworkPolicies: $NETPOLS/5"
echo ""

if [ "$PODS_RUNNING" -eq 3 ] && [ "$SERVICES" -eq 2 ] && [ "$NETPOLS" -eq 5 ]; then
    echo "ÉXITO: Todos los recursos aplicados correctamente"
    echo ""
    echo "Próximos pasos:"
    echo "  - Ejecutar scanner: ./scripts/k8s-scan.sh"
    echo "  - Acceder a frontend: minikube service frontend -n zero-trust-lab"
else
    echo "ADVERTENCIA: Algunos recursos no se aplicaron correctamente"
    echo "Revisa los logs con: kubectl logs -n zero-trust-lab <pod-name>"
fi

echo ""
