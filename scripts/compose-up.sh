#!/usr/bin/env bash
# scripts/compose-up.sh
# Script para levantar el stack de Docker Compose
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
echo "  Sprint 1: Levantando servicios..."
echo "=================================================="
echo ""

# 1. Verificar que Docker está corriendo
print_info "Verificando que Docker está corriendo..."
if ! docker info >/dev/null 2>&1; then
    print_error "Docker no está corriendo. Por favor, inicia Docker Desktop."
    exit 1
fi
print_success "Docker está corriendo"

# 2. Verificar que docker compose está disponible (V2 o V1)
print_info "Verificando docker compose..."
if docker compose version &>/dev/null; then
    DOCKER_COMPOSE="docker compose"
    print_success "docker compose (V2) está disponible"
elif command -v docker-compose &>/dev/null; then
    DOCKER_COMPOSE="docker-compose"
    print_success "docker-compose (V1) está disponible"
else
    print_error "Docker Compose no está instalado"
    print_info "Instala con: brew install docker-compose"
    print_info "O usa: alias docker-compose='docker compose'"
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

# 5. Verificar si existe .env, si no, copiar desde .env.example
if [ ! -f ".env" ]; then
    print_warning "Archivo .env no encontrado"
    if [ -f ".env.example" ]; then
        print_info "Copiando .env.example a .env..."
        cp .env.example .env
        print_success "Archivo .env creado desde .env.example"
    else
        print_warning "Continuando sin archivo .env (se usarán valores por defecto)"
    fi
fi

# 6. Construir imágenes (si no existen o hay cambios)
print_info "Construyendo imágenes Docker..."
if $DOCKER_COMPOSE build; then
    print_success "Imágenes construidas exitosamente"
else
    print_error "Error al construir imágenes"
    exit 1
fi

# 7. Levantar servicios en modo detached
print_info "Levantando servicios..."
if $DOCKER_COMPOSE up -d; then
    print_success "Servicios levantados en modo detached"
else
    print_error "Error al levantar servicios"
    exit 1
fi

# 8. Esperar 10 segundos para que los servicios inicien
print_info "Esperando 10 segundos para que los servicios inicien..."
sleep 10

# 9. Verificar estado de los contenedores
print_info "Verificando estado de los servicios..."
echo ""
$DOCKER_COMPOSE ps
echo ""

# 10. Contar contenedores corriendo
RUNNING_CONTAINERS=$($DOCKER_COMPOSE ps --filter "status=running" --quiet | wc -l)

if [ "$RUNNING_CONTAINERS" -eq 3 ]; then
    print_success "Los 3 servicios están corriendo correctamente"
    echo ""
    print_info "Servicios disponibles:"
    echo "  - Frontend: http://localhost:8080"
    echo "  - Backend:  http://backend:5000 (solo accesible internamente)"
    echo "  - Attacker: (scanner disponible para ejecutar)"
    echo ""
    print_info "Para ver logs en tiempo real:"
    echo "  $DOCKER_COMPOSE logs -f"
    echo ""
    print_info "Para ejecutar el scanner:"
    echo "  ./scripts/compose-scan.sh"
    echo ""
    print_info "Para bajar el stack:"
    echo "  ./scripts/compose-down.sh"
    echo ""
    print_success "Stack levantado exitosamente"
else
    print_warning "Esperados: 3 contenedores, Corriendo: $RUNNING_CONTAINERS"
    print_info "Verifica los logs para más detalles:"
    echo "  $DOCKER_COMPOSE logs"
fi

echo "=================================================="
echo ""
