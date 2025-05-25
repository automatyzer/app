<div align="center">
  <h1>📧 Mail LLM Automation</h1>
  
  [![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
  [![Test Status](https://github.com/automatyzer/app/actions/workflows/test.yml/badge.svg)](https://github.com/automatyzer/app/actions)
  [![Code Coverage](https://img.shields.io/codecov/c/github/automatyzer/app/main)](https://codecov.io/gh/automatyzer/app)
  [![Docker Pulls](https://img.shields.io/docker/pulls/n8nio/n8n?label=n8n%20pulls)](https://hub.docker.com/r/n8nio/n8n)
  [![Ollama](https://img.shields.io/badge/Ollama-✓-blue)](https://ollama.ai/)
  [![Electron](https://img.shields.io/badge/Electron-✓-9FEAF9.svg)](https://www.electronjs.org/)
  
  <p>Automate email responses with local LLMs (Ollama/Bielik) and n8n workflows</p>
</div>

A desktop application that automates email responses using local LLMs (via Ollama/Bielik) and n8n workflows. This application allows you to process incoming emails, generate responses using local language models, and automate email workflows with n8n.

## ✨ Features

- 📧 **Automated Email Processing** - Handle incoming emails automatically
- 🤖 **Local LLM Integration** - Supports Ollama and Bielik for private, offline processing
- ⚡ **Workflow Automation** - Built-in n8n for powerful email workflows
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux
- 🔒 **Privacy-First** - All processing happens locally on your machine
- 🎨 **Modern UI** - Clean, intuitive interface for managing email automation
- 🔄 **Extensible** - Easy to add custom workflows and integrations
- 🧪 **Tested** - Comprehensive test coverage for reliable operation
- 🚀 **Quick Setup** - Get started in minutes with the included setup scripts

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ (LTS recommended)
- npm 9+ or yarn
- Docker (for n8n)
- [Ollama](https://ollama.ai/) installed locally
- Git (for development)

> **Note**: For production use, ensure you have at least 8GB of RAM and 10GB of free disk space.

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/automatyzer/app.git
   cd automatyzer/app
   ```

2. **Install dependencies**

   ```bash
   make setup
   ```

   This will:

   - Install Node.js dependencies
   - Create a `.env` file from `sample.env`
   - Set up the environment

3. **Configure your environment**

   ```bash
   # Edit the .env file with your settings
   nano .env
   ```

4. **Start the application**

   ```bash
   make start
   ```

5. **In a new terminal, start n8n**
   ```bash
   make start-n8n
   ```

## 🛠️ Makefile Commands

The project includes a Makefile with useful commands:

| Command               | Description                                |
| --------------------- | ------------------------------------------ |
| `make` or `make help` | Show this help message                     |
| `make setup`          | Install dependencies and setup environment |
| `make start`          | Start the application                      |
| `make stop`           | Stop the application                       |
| `make start-n8n`      | Start n8n service                          |
| `make test`           | Run tests                                  |
| `make build`          | Build the application                      |
| `make package`        | Create a distributable package             |
| `make clean`          | Remove build artifacts and dependencies    |

## 🔧 Configuration

Edit the `.env` file to configure:

```env
# Email Configuration
IMAP_HOST=imap.gmail.com
IMAP_PORT=993
IMAP_USER=your_email@gmail.com
IMAP_PASS=your_password

# LLM Configuration
LLM_DEFAULT_MODEL=ollama  # or 'bielik'
OLLAMA_HOST=http://localhost:11434
OLLAMA_MODEL=llama2

# n8n Configuration
N8N_PORT=5678
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http
```

## 🏗️ Project Structure

```
├── app/
│   ├── main.js                 # Electron main process
│   ├── llm-router.js           # LLM API router (Ollama/Bielik)
│   ├── n8n_setup.sh            # n8n Docker setup script
│   ├── run.sh                  # Application startup script
│   ├── test/                   # Test files
│   │   ├── llm-api.test.js     # LLM API test cases
│   │   └── setup.js            # Test environment setup
│   ├── ui/                     # Frontend files
│   │   └── index.html          # Main application UI
│   ├── workflows/              # n8n workflow templates
│   │   └── email_to_response.json
│   └── .env                    # Environment configuration
├── .github/                   # GitHub workflows
│   └── workflows/
│       └── test.yml          # CI/CD pipeline
├── Makefile                   # Build and development commands
├── package.json               # Project configuration
└── README.md                  # Documentation
```

## 🤖 LLM Integration

The application supports multiple LLM backends for generating email responses:

### Ollama (Recommended)

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama server
ollama serve

# Download a model (e.g., llama2)
ollama pull llama2
```

### Bielik

```bash
# Clone the Bielik repository
git clone https://github.com/yourorg/bielik.git
cd bielik

# Follow Bielik setup instructions
# ...
```

### Testing LLM Integration

Run the test suite to verify LLM connectivity:

```bash
# Install test dependencies
npm install --save-dev jest supertest

# Run tests
npm test
```

## 🧪 Testing

The application includes a comprehensive test suite:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Test Coverage

We maintain high test coverage to ensure reliability. Current coverage includes:

- LLM API integration
- Email processing
- Error handling
- Configuration validation

## 🚀 Deployment

### Production Build

Create a production-ready build:

```bash
# Install dependencies
npm install --production

# Build the application
npm run build

# Package for your platform
npm run package
```

### Environment Variables

Required environment variables for production:

```env
NODE_ENV=production
APP_PORT=3000
OLLAMA_HOST=http://localhost:11434
# ... other required variables
```

## 🔄 n8n Workflows

Pre-configured workflows are located in the `workflows/` directory. To import a workflow:

1. Open n8n at http://localhost:5678
2. Go to Workflows > Import from File
3. Select the desired JSON file from the `workflows/` directory

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📚 Documentation

- [API Reference](docs/API.md)
- [Workflow Examples](docs/WORKFLOWS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🌟 Show Your Support

Give a ⭐️ if this project helped you!

## 📧 Contact

Project Link: [https://github.com/automatyzer/app](https://github.com/automatyzer/app)

## 🙏 Acknowledgments

- [Ollama](https://ollama.ai/) - For the amazing local LLM framework
- [n8n](https://n8n.io/) - For powerful workflow automation
- [Electron](https://www.electronjs.org/) - For cross-platform desktop apps
- All contributors who have helped shape this project

## 🙏 Acknowledgments

- [Ollama](https://ollama.ai/) - For the local LLM framework
- [n8n](https://n8n.io/) - For the workflow automation
- [Electron](https://www.electronjs.org/) - For the desktop application framework

## Prerequisites

- Node.js 16+
- Docker (for n8n)
- Ollama or Bielik installed locally

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/automatyzer/app.git
   cd app
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Configure your environment:
   - Copy `.env.example` to `.env`
   - Update the configuration with your email and LLM settings

## Usage

1. Start the application:

   ```bash
   npm start
   ```

2. The app will launch the desktop interface and start n8n in the background

## Project Structure

```
app/
├── app/                        # Desktop application (Electron)
│   ├── main.js                 # Electron bootstrap
│   ├── llm-router.js          # API proxy for local LLMs (Ollama/Bielik)
│   ├── n8n_setup.sh           # n8n autostart with parameters
│   ├── ui/
│   │   └── index.html         # Simple LLM frontend
│   ├── workflows/
│   │   └── email_to_response.json  # Example n8n workflow
│   └── .env                   # Credentials (IMAP/SMTP, models)
├── install.sh                 # Local dependency installation script
├── package.json               # Node/Electron config
└── README.md                  # This file
```

## License

MIT
