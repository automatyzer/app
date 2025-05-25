#!/bin/bash

# Set script to exit immediately if any command fails
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Load environment variables
get_env_value() {
    local key="$1"
    local value=$(grep -E "^$key=" .env | cut -d '=' -f2- | tr -d "'\"")
    echo "$value"
}

# Export environment variables
if [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        if [[ $line =~ ^[^#]*= && ! $line =~ ^[[:space:]]*# ]]; then
            key=$(echo "$line" | cut -d '=' -f1)
            value=$(echo "$line" | cut -d '=' -f2-)
            # Remove surrounding quotes if any
            value=$(echo "$value" | sed -e 's/^["\x27]//' -e 's/["\x27]$//')
            export "$key"="$value"
        fi
    done < .env
else
    echo "Error: .env file not found."
    exit 1
fi

# Function to check if a service is running
is_service_running() {
    local url=$1
    if curl --output /dev/null --silent --head --fail "$url"; then
        return 0  # Service is running
    else
        return 1  # Service is not running
    fi
}

# Function to start Ollama if not running
start_ollama() {
    local ollama_url="${OLLAMA_HOST}:${OLLAMA_PORT}/api/tags"
    echo "Checking if Ollama is running at $ollama_url..."
    
    if is_service_running "$ollama_url"; then
        echo "Ollama is already running."
    else
        echo "Starting Ollama service..."
        if ! command -v ollama &> /dev/null; then
            echo "Error: Ollama is not installed. Please install it first."
            exit 1
        fi
        # Start Ollama in the background
        nohup ollama serve > ollama.log 2>&1 &
        OLLAMA_PID=$!
        echo "Ollama started with PID $OLLAMA_PID"
        
        # Wait for Ollama to start
        echo "Waiting for Ollama to be ready..."
        until is_service_running "$ollama_url"; do
            sleep 1
            echo -n "."
        done
        echo -e "\nOllama is ready!"
    fi
}

# Function to start n8n
start_n8n() {
    echo "Starting n8n..."
    if [ ! -f "n8n_setup.sh" ]; then
        echo "Error: n8n_setup.sh not found."
        exit 1
    fi
    chmod +x n8n_setup.sh
    ./n8n_setup.sh
    echo "n8n is starting in the background..."
    echo "You can access n8n at: http://localhost:${N8N_PORT}"
}

# Function to start the main application
start_application() {
    echo "Starting the application..."
    if [ ! -f "package.json" ]; then
        echo "Error: package.json not found. Are you in the right directory?"
        exit 1
    fi
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "Installing Node.js dependencies..."
        npm install
    fi
    
    # Start the application
    echo "Starting the application..."
    npm start
}

# Main execution
main() {
    echo "=== Starting Mail LLM Automation ==="
    
    # Start Ollama
    start_ollama
    
    # Start n8n in the background
    start_n8n &
    
    # Start the main application
    start_application
}

# Run the main function
main "$@"
