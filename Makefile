.PHONY: help install setup start stop clean test build package check-services

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
TARGET_MAX_CHAR_NUM=20

## Show help\.
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u

## Install dependencies
install:
	@echo "${YELLOW}Installing dependencies...${RESET}"
	npm install
	@echo "${GREEN}✓ Dependencies installed${RESET}"

## Setup environment and install dependencies
setup: install
	@echo "${YELLOW}Setting up environment...${RESET}"
	@if [ ! -f ".env" ]; then \
		cp sample.env .env; \
		echo "${YELLOW}ℹ️  Please edit .env file with your configuration${RESET}"; \
	else \
		echo "${GREEN}✓ .env file already exists${RESET}"; \
	fi
	@echo "${GREEN}✓ Setup complete${RESET}"

## Start Ollama service
start-ollama:
	@echo "${YELLOW}Starting Ollama service...${RESET}"
	@if [ -f "scripts/start_ollama.sh" ]; then \
		if ./scripts/start_ollama.sh; then \
			echo "${GREEN}✓ Ollama service started${RESET}"; \
		else \
			echo "${RED}✗ Failed to start Ollama service${RESET}"; \
			exit 1; \
		fi; \
	else \
		echo "${YELLOW}Ollama start script not found. Make sure Ollama is running.${RESET}"; \
	fi

## Start n8n service
start-n8n:
	@echo "${YELLOW}Starting n8n service...${RESET}"
	@if [ -f "n8n_setup.sh" ]; then \
		if docker ps -a --format '{{.Names}}' | grep -q '^n8n$$'; then \
			echo "${YELLOW}Removing existing n8n container...${RESET}"; \
			docker rm -f n8n >/dev/null 2>&1 || true; \
		fi; \
		if ./n8n_setup.sh; then \
			echo "${GREEN}✓ n8n service started${RESET}"; \
		else \
			echo "${RED}✗ Failed to start n8n service${RESET}"; \
			exit 1; \
		fi; \
	else \
		echo "${YELLOW}n8n setup script not found. Make sure n8n is running.${RESET}"; \
	fi

## Check if required services are running
check-services: start-ollama start-n8n
	@echo "${GREEN}✓ All required services are running${RESET}"

## Start the application
start: check-services
	@echo "${YELLOW}Starting application...${RESET}"
	npm start

## Stop the application
stop:
	@echo "${YELLOW}Stopping application...${RESET}"
	@pkill -f "electron ." || true
	@echo "${GREEN}✓ Application stopped${RESET}"



## Run tests
test:
	@echo "${YELLOW}Running tests...${RESET}"
	npm test

## Build the application
build:
	@echo "${YELLOW}Building application...${RESET}"
	npm run build

## Create distribution package
package:
	@echo "${YELLOW}Creating package...${RESET}"
	npm run package

## Clean build artifacts
clean:
	@echo "${YELLOW}Cleaning...${RESET}"
	rm -rf node_modules
	rm -rf dist
	rm -rf out
	rm -f package-lock.json
	rm -f npm-debug.log*
	@echo "${GREEN}✓ Clean complete${RESET}"

## Show help by default
.DEFAULT_GOAL := help
