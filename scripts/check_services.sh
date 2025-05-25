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

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    log "ERROR" "Ansible is not installed. Please install it first."
    log "INFO" "You can install it with: sudo apt-get install ansible"
    exit 1
fi

log "INFO" "Starting service checks..."

# Run the Ansible playbook in check mode first to test connectivity
if ansible-playbook -i "localhost," -c local ansible/check_services.yml --check; then
    log "INFO" "All services are running correctly."
    exit 0
else
    log "WARNING" "Some services need attention. Attempting to fix..."
    
    # Run the playbook for real to fix issues
    if ansible-playbook -i "localhost," -c local ansible/check_services.yml; then
        log "INFO" "Successfully fixed all services."
        exit 0
    else
        log "ERROR" "Failed to fix some services. Please check the logs above."
        exit 1
    fi
fi
