#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "=== Levantando stack de Docker Compose ==="
echo ""

# Verificar que Docker está corriendo
echo "Verificando Docker..."
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker no está corriendo. Inicia Docker Desktop."
    exit 1
fi
echo "OK: Docker está corriendo"

# Cambiar al directorio compose/
cd "$(dirname "$0")/../compose"

# Verificar que existe docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: No se encontró docker-compose.yml"
    exit 1
fi

# Copiar .env.example si no existe .env
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "Creando .env desde .env.example..."
    cp .env.example .env
fi

# Construir imágenes
echo ""
echo "Construyendo imágenes..."
docker compose build

# Levantar servicios
echo ""
echo "Levantando servicios..."
docker compose up -d

# Esperar a que inicien
echo ""
echo "Esperando 10 segundos a que los servicios inicien..."
sleep 10

# Mostrar estado
echo ""
echo "Estado de los servicios:"
docker compose ps

# Contar contenedores corriendo
RUNNING=$(docker compose ps --filter "status=running" --quiet | wc -l)

echo ""
if [ "$RUNNING" -eq 3 ]; then
    echo "OK: Los 3 servicios estan corriendo"
    echo ""
    echo "Servicios disponibles:"
    echo "  - Frontend: http://localhost:8080"
    echo "  - Backend:  accesible internamente en puerto 5000"
    echo "  - Attacker: listo para ejecutar el script scanner"
    echo ""
else
    echo "ADVERTENCIA: Esperados 3 contenedores, corriendo: $RUNNING"
    echo "Revisa los logs con: docker compose logs"
fi
