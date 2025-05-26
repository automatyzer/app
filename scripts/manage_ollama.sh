#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

OLLAMA_HOST="127.0.0.1"
OLLAMA_PORT="11434"
OLLAMA_URL="http://${OLLAMA_HOST}:${OLLAMA_PORT}"
OLLAMA_HOME="${HOME}/.ollama"
OLLAMA_LOG="${OLLAMA_HOME}/ollama.log"
PID_FILE="${OLLAMA_HOME}/ollama.pid"

# Create Ollama home directory if it doesn't exist
mkdir -p "${OLLAMA_HOME}"

# Function to check if Ollama is running
is_ollama_running() {
    if ps -p $(cat "${PID_FILE}" 2>/dev/null) > /dev/null 2>&1; then
        # Check if the process is actually ollama
        if ps -p $(cat "${PID_FILE}") -o command= | grep -q "ollama serve"; then
            # Verify the API is responding
            if curl -s -o /dev/null --connect-timeout 2 "${OLLAMA_URL}/api/tags"; then
                return 0
            fi
        fi
    fi
    return 1
}

# Function to start Ollama
start_ollama() {
    echo -e "${YELLOW}Starting Ollama service...${NC}"
    
    # Kill any existing ollama processes
    pkill -f "ollama serve" || true
    
    # Start Ollama in the background
    nohup ollama serve --host ${OLLAMA_HOST}:${OLLAMA_PORT} >> "${OLLAMA_LOG}" 2>&1 &
    echo $! > "${PID_FILE}"
    
    # Wait for Ollama to start
    local max_retries=10
    local retry_delay=2
    
    for ((i=1; i<=max_retries; i++)); do
        if curl -s -o /dev/null --connect-timeout 2 "${OLLAMA_URL}/api/tags"; then
            echo -e "${GREEN}✓ Ollama service started successfully${NC}"
            echo -e "  - API: ${OLLAMA_URL}"
            echo -e "  - Logs: ${OLLAMA_LOG}"
            return 0
        fi
        sleep ${retry_delay}
    done
    
    echo -e "${RED}✗ Failed to start Ollama service${NC}"
    echo -e "Check the logs at: ${OLLAMA_LOG}"
    return 1
}

# Function to stop Ollama
stop_ollama() {
    echo -e "${YELLOW}Stopping Ollama service...${NC}"
    
    if [ -f "${PID_FILE}" ]; then
        local pid=$(cat "${PID_FILE}")
        if ps -p ${pid} > /dev/null 2>&1; then
            kill ${pid} || true
            echo -e "${GREEN}✓ Ollama service stopped${NC}"
        else
            echo -e "${YELLOW}Ollama service is not running${NC}"
        fi
        rm -f "${PID_FILE}" 2>/dev/null || true
    else
        echo -e "${YELLOW}Ollama service is not running${NC}"
    fi
}

# Function to check Ollama status
status_ollama() {
    if is_ollama_running; then
        local pid=$(cat "${PID_FILE}" 2>/dev/null)
        echo -e "${GREEN}✓ Ollama service is running${NC}"
        echo -e "  - PID: ${pid}"
        echo -e "  - API: ${OLLAMA_URL}"
        echo -e "  - Logs: ${OLLAMA_LOG}"
        return 0
    else
        echo -e "${YELLOW}Ollama service is not running${NC}"
        return 1
    fi
}

# Main script
case "$1" in
    start)
        if is_ollama_running; then
            echo -e "${YELLOW}Ollama service is already running${NC}"
            status_ollama
        else
            start_ollama
        fi
        ;;
    stop)
        stop_ollama
        ;;
    restart)
        stop_ollama
        sleep 2
        start_ollama
        ;;
    status)
        status_ollama
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
