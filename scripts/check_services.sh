#!/bin/bash

# Set script to exit immediately if a command exits with a non-zero status
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/../"

# Default values
N8N_HOST=${N8N_HOST:-0.0.0.0}
N8N_PORT=${N8N_PORT:-5678}
N8N_PROTOCOL=${N8N_PROTOCOL:-http}
N8N_EDITOR_BASE_URL=${N8N_EDITOR_BASE_URL:-http://localhost:5678}

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# Check if a service is running
check_service() {
    local name=$1
    local url=$2
    
    log "INFO" "Checking if $name is running at $url"
    
    if curl -s -o /dev/null --connect-timeout 5 "$url"; then
        log "SUCCESS" "$name is running"
        return 0
    else
        log "WARNING" "$name is not running or not accessible at $url"
        return 1
    fi
}

# Check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        log "ERROR" "Docker is not installed. Please install it first."
        log "INFO" "You can install it with: sudo apt-get install docker.io"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log "ERROR" "Docker daemon is not running. Please start it first."
        log "INFO" "You can start it with: sudo systemctl start docker"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    # Check if Ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        log "ERROR" "Ansible is not installed. Please install it first."
        log "INFO" "You can install it with: sudo apt-get install ansible"
        return 1
    fi

    # Check Docker
    if ! check_docker; then
        return 1
    fi

    log "INFO" "Starting service checks..."

    # Export environment variables for Ansible
    export N8N_HOST N8N_PORT N8N_PROTOCOL N8N_EDITOR_BASE_URL

    # Run the Ansible playbook in check mode first to test connectivity
    if ansible-playbook -i "localhost," -c local ansible/check_services.yml --check; then
        log "INFO" "All services are running correctly."
        return 0
    else
        log "WARNING" "Some services need attention. Attempting to fix..."
        
        # Run the playbook for real to fix issues
        if ansible-playbook -i "localhost," -c local ansible/check_services.yml; then
            log "INFO" "Successfully fixed all services."
            
            # Verify n8n is accessible
            local n8n_url="$N8N_PROTOCOL://$N8N_HOST:$N8N_PORT/healthz"
            if check_service "n8n" "$n8n_url"; then
                log "SUCCESS" "n8n is now running at $N8N_PROTOCOL://$N8N_HOST:$N8N_PORT"
            else
                log "ERROR" "n8n service is not accessible after startup"
                return 1
            fi
            
            return 0
        else
            log "ERROR" "Failed to fix some services. Please check the logs above."
            return 1
        fi
    fi
}

# Run the main function
if main; then
    exit 0
else
    exit 1
fi
