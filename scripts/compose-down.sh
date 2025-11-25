#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "=== Bajando stack de Docker Compose ==="
echo ""

# Verificar que Docker está corriendo
echo "Verificando Docker..."
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker no está corriendo"
    exit 1
fi

# Cambiar al directorio compose/
cd "$(dirname "$0")/../compose"

# Verificar que existe docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: No se encontró docker-compose.yml"
    exit 1
fi

# Mostrar estado actual
echo ""
echo "Estado actual:"
docker compose ps 2>/dev/null || echo "(No hay contenedores corriendo)"

# Bajar servicios
echo ""
echo "Bajando servicios..."
docker compose down

echo "OK: Servicios bajados"

# Preguntar si eliminar volúmenes
echo ""
read -p "¿Eliminar volúmenes? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Eliminando volúmenes..."
    docker compose down --volumes
    echo "OK: Volúmenes eliminados"
fi

# Preguntar si eliminar imágenes
echo ""
read -p "¿Eliminar imágenes construidas? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Eliminando imágenes..."
    docker rmi compose-frontend compose-backend compose-attacker 2>/dev/null || true
    docker image prune -f >/dev/null
    echo "OK: Imágenes eliminadas"
fi

# Verificar limpieza
echo ""
REMAINING=$(docker ps -a --filter "name=zero-trust" --quiet | wc -l)
if [ "$REMAINING" -eq 0 ]; then
    echo "OK: No quedan contenedores del proyecto"
else
    echo "ADVERTENCIA: Quedan $REMAINING contenedores con nombre 'zero-trust'"
    echo "Elimínalos con: docker rm -f \$(docker ps -a --filter 'name=zero-trust' --quiet)"
fi

echo ""
echo "Stack bajado exitosamente"
echo ""
