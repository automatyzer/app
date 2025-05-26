#!/bin/bash

# Set script to exit immediately if a command exits with a non-zero status
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/../"

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

OLLAMA_HOME="${HOME}/.ollama"
OLLAMA_LOG="${OLLAMA_HOME}/ollama.log"
OLLAMA_HOST="0.0.0.0:11434"

# Create Ollama home directory if it doesn't exist
mkdir -p "${OLLAMA_HOME}"

# Check if Ollama is already running
if curl -s -o /dev/null --connect-timeout 2 "http://localhost:11434/api/tags"; then
    log "INFO" "Ollama is already running at http://localhost:11434"
    exit 0
fi

log "INFO" "Starting Ollama service..."
log "INFO" "Logs: ${OLLAMA_LOG}"

# Kill any existing Ollama processes
pkill -f "ollama serve" || true

# Start Ollama in the background, binding to 127.0.0.1
nohup ollama serve --host 127.0.0.1:11434 >> "${OLLAMA_LOG}" 2>&1 &
OLLAMA_PID=$!

echo "${OLLAMA_PID}" > "${OLLAMA_HOME}/ollama.pid"

# Wait for Ollama to start
MAX_RETRIES=10
RETRY_DELAY=3

for ((i=1; i<=MAX_RETRIES; i++)); do
    if curl -s -o /dev/null --connect-timeout 2 "http://localhost:11434/api/tags"; then
        log "SUCCESS" "Ollama is now running at http://localhost:11434"
        log "INFO" "PID: ${OLLAMA_PID}"
        log "INFO" "Logs: ${OLLAMA_LOG}"
        exit 0
    fi
    
    if [ $i -lt $MAX_RETRIES ]; then
        log "INFO" "Waiting for Ollama to start... (attempt ${i}/${MAX_RETRIES})"
        sleep ${RETRY_DELAY}
    fi
done

log "ERROR" "Failed to start Ollama after ${MAX_RETRIES} attempts"
log "INFO" "Check the logs at: ${OLLAMA_LOG}"

# Clean up if we failed to start
if ps -p ${OLLAMA_PID} > /dev/null; then
    kill ${OLLAMA_PID}
fi

exit 1
