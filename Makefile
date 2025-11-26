.PHONY: help setup venv dev build test lint coverage scan sbom compose-up compose-scan compose-down k8s-apply k8s-scan k8s-clean clean

PYTHON := python3
VENV := venv
VENV_BIN := $(VENV)/bin
PIP := $(VENV_BIN)/pip
PYTHON_VENV := $(VENV_BIN)/python
GIT_SHA := $(shell git rev-parse --short HEAD 2>/dev/null || echo "dev")
IMAGE_TAG := $(GIT_SHA)

help: ## Mostrar comandos disponibles
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

venv: ## Crear entorno virtual Python
	@if [ ! -d "$(VENV)" ]; then \
		echo "Creando entorno virtual..."; \
		$(PYTHON) -m venv $(VENV); \
		echo "Entorno virtual creado"; \
	fi

setup: venv ## Preparar entorno local (venv + dependencias + verificar Docker)
	@echo "Verificando Docker..."
	@docker info >/dev/null 2>&1 || (echo "ERROR: Docker no está corriendo"; exit 1)
	@echo "Docker OK"
	@echo ""
	@echo "Instalando dependencias en entorno virtual..."
	$(PIP) install --upgrade pip
	$(PIP) install -r services/frontend/requirements.txt
	$(PIP) install -r services/backend/requirements.txt
	$(PIP) install -r services/attacker/requirements.txt
	$(PIP) install pytest pytest-cov flake8
	@echo ""
	@echo "Entorno preparado"
	@echo ""
	@echo "Siguiente paso: make dev (para levantar contenedores Docker)"

dev: compose-up ## Levantar entorno local (alias de compose-up)

build: ## Construir imágenes Docker con tags inmutables
	@echo "Construyendo imágenes con tag: $(IMAGE_TAG)"
	@cd compose && docker compose build
	@echo "Imágenes construidas"

test: ## Ejecutar tests automáticos
	@echo "Ejecutando tests..."
	@if [ ! -d "$(VENV)" ]; then \
		echo "ERROR: Entorno virtual no existe. Ejecuta: make setup"; \
		exit 1; \
	fi
	@if [ -d "tests/" ]; then \
		$(PYTHON_VENV) -m pytest tests/ -v; \
	else \
		echo "Directorio tests/ no encontrado. Creando estructura básica..."; \
		mkdir -p tests; \
	fi

lint: ## Verificar estilo de código
	@echo "Verificando estilo de código..."
	@if [ ! -d "$(VENV)" ]; then \
		echo "ERROR: Entorno virtual no existe. Ejecuta: make setup"; \
		exit 1; \
	fi
	$(VENV_BIN)/flake8 services/ --exclude=__pycache__ --max-line-length=100
	@echo "Código cumple estándares"

coverage: ## Ejecutar tests con reporte de cobertura
	@echo "Ejecutando tests con cobertura..."
	@if [ ! -d "$(VENV)" ]; then \
		echo "ERROR: Entorno virtual no existe. Ejecuta: make setup"; \
		exit 1; \
	fi
	@if [ -d "tests/" ]; then \
		$(PYTHON_VENV) -m pytest tests/ -v --cov=services --cov-report=term-missing --cov-report=html; \
		echo "Reporte HTML generado en htmlcov/index.html"; \
	else \
		echo "No hay tests para ejecutar"; \
	fi

scan: ## Ejecutar scans de seguridad (Compose y K8s)
	@echo "Ejecutando scans de seguridad..."
	@echo "  -> Compose scan"
	@bash scripts/compose-scan.sh
	@echo ""
	@echo "  -> K8s scan (si aplica)"
	@if command -v kubectl >/dev/null 2>&1; then \
		bash scripts/k8s-scan.sh 2>/dev/null || echo "K8s no disponible o no configurado"; \
	else \
		echo "kubectl no instalado, saltando K8s scan"; \
	fi
	@echo "Scans completados"

sbom: ## Generar SBOM (Software Bill of Materials)
	@echo "Generando SBOM..."
	@mkdir -p reports
	@if command -v syft >/dev/null 2>&1; then \
		syft packages dir:. -o json > reports/sbom.json; \
		echo "SBOM generado con syft en reports/sbom.json"; \
	elif command -v trivy >/dev/null 2>&1; then \
		trivy fs --format json --output reports/sbom.json .; \
		echo "SBOM generado con trivy en reports/sbom.json"; \
	else \
		echo "syft/trivy no instalados. Generando SBOM simulado..."; \
		echo '{"tool":"manual","timestamp":"'$$(date -u +%Y-%m-%dT%H:%M:%SZ)'","components":["python:3.12-slim","Flask==3.0.0","Werkzeug==3.0.1"]}' > reports/sbom.json; \
		echo "SBOM simulado generado en reports/sbom.json"; \
	fi

compose-up: ## Levantar stack de Docker Compose
	@echo "Levantando stack de Docker Compose..."
	@bash scripts/compose-up.sh

compose-scan: ## Ejecutar scanner en entorno Compose
	@echo "Ejecutando scanner en Compose..."
	@bash scripts/compose-scan.sh

compose-down: ## Bajar stack de Docker Compose
	@echo "Bajando stack de Docker Compose..."
	@bash scripts/compose-down.sh

k8s-apply: ## Aplicar manifiestos de Kubernetes
	@echo "Aplicando manifiestos de Kubernetes..."
	@bash scripts/k8s-apply.sh

k8s-scan: ## Ejecutar scanner en entorno K8s
	@echo "Ejecutando scanner en K8s..."
	@bash scripts/k8s-scan.sh

k8s-clean: ## Limpiar recursos de Kubernetes
	@echo "Limpiando recursos de Kubernetes..."
	@bash scripts/k8s-clean.sh

clean: ## Limpiar archivos temporales y reportes
	@echo "Limpiando archivos temporales..."
	rm -rf __pycache__ .pytest_cache .coverage htmlcov
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf reports/*.json reports/*.html 2>/dev/null || true
	@echo "Archivos temporales eliminados"
	@echo ""
	@echo "Para eliminar el entorno virtual: rm -rf $(VENV)"