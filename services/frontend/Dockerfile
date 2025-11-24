FROM python:3.12-slim

WORKDIR /app

# Usuario sin privilegios de root
RUN groupadd -r appuser && useradd -r -g appuser appuser

COPY services/frontend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY services/frontend/app.py .
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]
