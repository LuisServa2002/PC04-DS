FROM python:3.12-slim

WORKDIR /app

RUN groupadd -r appuser && useradd -r -g appuser appuser

COPY services/attacker/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY services/attacker/scanner.py .
RUN chown -R appuser:appuser /app

USER appuser

# Mantener contenedor activo para ejecutar scanner cuando se necesite
CMD ["tail", "-f", "/dev/null"]
