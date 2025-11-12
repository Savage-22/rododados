FROM python:3.12-slim

WORKDIR /app

# Copiar e instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar script de migración
COPY migrar.py .

# Ejecutar migración
CMD ["python", "migrar.py"]
