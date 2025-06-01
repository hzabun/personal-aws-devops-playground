FROM python:3.13.3-alpine

# Set a working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/hello.py app/

# Create a non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Set a default port as an environment variable
ENV PORT=5000

# Use ENTRYPOINT for the main process
ENTRYPOINT flask --app hello run --host=0.0.0.0 --port $PORT

