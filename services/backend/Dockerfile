FROM python:3.12-slim

WORKDIR /app

# Crear usuario no privilegiado
RUN groupadd -r appuser && useradd -r -g appuser appuser

COPY services/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY services/backend/app.py .
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
