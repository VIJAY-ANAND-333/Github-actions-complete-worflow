# Use official minimal Python image
FROM python:3.9-slim

# OCI standard labels
LABEL org.opencontainers.image.authors="Vijay Anand" 

# Disable Python bytecode & enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production \
    FLASK_APP=app.py

# Create a non-root user
RUN addgroup --system appgroup && \
    adduser  --system --ingroup appgroup --no-create-home appuser

# Set work directory
WORKDIR /app

# Copy only requirements first (better layer caching)
COPY src/requirements.txt .

# Install dependencies securely
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src /app

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 9000

# Run Gunicorn with hardened config
CMD ["gunicorn", \
     "--bind", "0.0.0.0:9000", \
     "--workers", "3", \
     "--threads", "2", \
     "--timeout", "30", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app:app"]

     