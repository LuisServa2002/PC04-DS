# services/attacker/Dockerfile
# Imagen base fija - Python 3.12 slim para tamaño reducido
FROM python:3.12-slim

# Metadata de la imagen
LABEL maintainer="Zero Trust Team"
LABEL description="Network scanner (attacker) for Zero Trust Network Sandbox"

# Crear usuario no-root para ejecutar la aplicación (UID 1000)
RUN groupadd -r appuser -g 1000 && \
    useradd -r -u 1000 -g appuser appuser

# Establecer directorio de trabajo
WORKDIR /app

# Copiar requirements.txt primero (aprovecha cache de Docker)
COPY services/attacker/requirements.txt .

# Instalar dependencias (si hay alguna en el futuro)
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el script del scanner
COPY services/attacker/scanner.py .

# Cambiar permisos del directorio /app al usuario appuser
RUN chown -R appuser:appuser /app

# Cambiar a usuario no-root
USER appuser

# Este contenedor no expone puertos (es un scanner)
# Se ejecutará bajo demanda con docker exec

# Mantener el contenedor corriendo (para poder ejecutar el scanner cuando se necesite)
CMD ["tail", "-f", "/dev/null"]
