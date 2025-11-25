#!/usr/bin/env bash
# scripts/compose-down.sh
# Script para bajar el stack de Docker Compose y limpiar recursos
# Sprint 1 - Zero-Trust Network Sandbox

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_info() {
    echo -e "${BLUE}  ${1}${NC}"
}

print_success() {
    echo -e "${GREEN} ${1}${NC}"
}

print_error() {
    echo -e "${RED} ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}  ${1}${NC}"
}

# Banner
echo ""
echo "=================================================="
echo "  Zero-Trust Network Sandbox - Compose Stack"
echo "  Sprint 1: Bajando servicios..."
echo "=================================================="
echo ""

# 1. Verificar que Docker está corriendo
print_info "Verificando que Docker está corriendo..."
if ! docker info >/dev/null 2>&1; then
    print_error "Docker no está corriendo"
    exit 1
fi
print_success "Docker está corriendo"

# 2. Detectar versión de Docker Compose
print_info "Detectando Docker Compose..."
if docker compose version &>/dev/null; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &>/dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    print_error "Docker Compose no está instalado"
    exit 1
fi

# 3. Cambiar al directorio compose/
print_info "Cambiando al directorio compose/..."
cd "$(dirname "$0")/../compose"

# 4. Verificar que existe docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    print_error "No se encontró docker-compose.yml"
    exit 1
fi

# 4. Mostrar contenedores antes de bajar
print_info "Estado actual de los contenedores:"
echo ""
docker-compose ps 2>/dev/null || echo "  (No hay contenedores corriendo)"
echo ""

# 5. Bajar servicios
print_info "Bajando servicios..."
if docker-compose down; then
    print_success "Servicios bajados exitosamente"
else
    print_error "Error al bajar servicios"
    exit 1
fi

# 7. Preguntar si se quieren limpiar volúmenes (opcional)
read -p "¿Deseas eliminar volúmenes también? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Eliminando volúmenes..."
    if $DOCKER_COMPOSE down --volumes; then
        print_success "Volúmenes eliminados"
    else
        print_warning "No se pudieron eliminar algunos volúmenes"
    fi
fi

# 8. Preguntar si se quieren eliminar las imágenes
read -p "¿Deseas eliminar las imágenes construidas? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Eliminando imágenes..."

    # Eliminar imágenes específicas del proyecto
    docker rmi zero-trust-frontend:latest 2>/dev/null || true
    docker rmi zero-trust-backend:latest 2>/dev/null || true
    docker rmi zero-trust-attacker:latest 2>/dev/null || true

    # Eliminar imágenes sin nombre (dangling)
    print_info "Limpiando imágenes huérfanas..."
    docker image prune -f

    print_success "Imágenes eliminadas"
fi

# 8. Verificar que no quedan contenedores del proyecto
print_info "Verificando limpieza..."
REMAINING=$(docker ps -a --filter "name=zero-trust" --quiet | wc -l)

if [ "$REMAINING" -eq 0 ]; then
    print_success "No quedan contenedores del proyecto"
else
    print_warning "Aún quedan $REMAINING contenedores con nombre 'zero-trust'"
    print_info "Para eliminarlos manualmente:"
    echo "  docker rm -f \$(docker ps -a --filter 'name=zero-trust' --quiet)"
fi

# 9. Verificar redes
print_info "Verificando redes..."
NETWORKS=$(docker network ls --filter "name=zero-trust" --quiet | wc -l)

if [ "$NETWORKS" -eq 0 ]; then
    print_success "No quedan redes del proyecto"
else
    print_warning "Aún quedan $NETWORKS redes con nombre 'zero-trust'"
    print_info "Para eliminarlas manualmente:"
    echo "  docker network rm \$(docker network ls --filter 'name=zero-trust' --quiet)"
fi

echo ""
print_success "Stack bajado exitosamente"
echo ""
print_info "Para volver a levantar el stack:"
echo "  ./scripts/compose-up.sh"
echo ""
echo "=================================================="
echo ""
