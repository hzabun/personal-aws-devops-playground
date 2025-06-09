FROM python:3.13.3-alpine

# Set a working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY ec2-ansible/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy flask application code
COPY ec2-ansible/app/hello.py .

# Create a non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Set default port
ENV PORT=5000

# Run flask app when container starts
ENTRYPOINT flask --app hello run --host=0.0.0.0 --port $PORT