#!/bin/bash

# n8n setup and startup script

# Default configuration
N8N_PORT=5678
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http
N8N_WEBHOOK_URL="${N8N_PROTOCOL}://${N8N_HOST}:${N8N_PORT}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if n8n container is already running
if [ "$(docker ps -q -f name=n8n)" ]; then
  echo "n8n is already running. Stopping existing container..."
  docker stop n8n > /dev/null
  docker rm n8n > /dev/null
fi

# Start n8n container
echo "Starting n8n on ${N8N_WEBHOOK_URL}"

docker run -it --rm --name n8n \
  -p ${N8N_PORT}:5678 \
  -v ~/.n8n:/home/node/.n8n \
  -e N8N_HOST=${N8N_HOST} \
  -e N8N_PORT=${N8N_PORT} \
  -e N8N_PROTOCOL=${N8N_PROTOCOL} \
  -e N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL} \
  -e N8N_EMAIL_MODE=smtp \
  -e N8N_EMAIL_TEMPLATES_ENABLED=true \
  -e NODE_ENV=production \
  docker.n8n.io/n8nio/n8n

echo "n8n is now running at ${N8N_WEBHOOK_URL}"
