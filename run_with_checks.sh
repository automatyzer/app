#!/bin/bash

# Set script to exit immediately if a command exits with a non-zero status
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# Make sure the check_services script is executable
chmod +x scripts/check_services.sh

log "INFO" "Checking required services..."

# Run the service check script
if ./scripts/check_services.sh; then
    log "INFO" "All services are ready. Starting the application..."
    # Start the main application
    npm start
else
    log "ERROR" "Failed to start required services. Please check the logs above."
    exit 1
fi
