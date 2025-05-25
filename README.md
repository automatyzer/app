# Mail LLM Automation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

A desktop application that automates email responses using local LLMs (via Ollama/Bielik) and n8n workflows. This application allows you to process incoming emails, generate responses using local language models, and automate email workflows with n8n.

## ✨ Features

- 📧 Process incoming emails automatically
- 🤖 Generate responses using local LLMs (Ollama/Bielik)
- ⚡ Built-in n8n workflow automation
- 🖥️ Cross-platform desktop application
- 🔒 Local-first approach for privacy
- 🎨 Simple and intuitive UI
- 🔄 Easy to extend with custom workflows

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- npm 9+
- Docker (for n8n)
- Ollama or Bielik installed locally

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

| Command         | Description                                |
|-----------------|--------------------------------------------|
| `make` or `make help` | Show this help message                  |
| `make setup`    | Install dependencies and setup environment |
| `make start`    | Start the application                     |
| `make stop`     | Stop the application                      |
| `make start-n8n`| Start n8n service                         |
| `make test`     | Run tests                                 |
| `make build`    | Build the application                     |
| `make package`  | Create a distributable package            |
| `make clean`    | Remove build artifacts and dependencies   |

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

## 📦 Project Structure

```
├── app/
│   ├── main.js                 # Electron main process
│   ├── llm-router.js           # LLM API router
│   ├── n8n_setup.sh            # n8n setup script
│   ├── ui/                     # Frontend files
│   │   └── index.html
│   ├── workflows/              # n8n workflows
│   │   └── email_to_response.json
│   └── .env                    # Environment variables
├── Makefile                    # Build and development commands
├── package.json                # Project configuration
└── README.md                   # This file
```

## 🤖 LLM Integration

The application supports multiple LLM backends:

1. **Ollama** (Recommended)
   - Install: https://ollama.ai/
   - Start server: `ollama serve`
   - Pull model: `ollama pull llama2`

2. **Bielik**
   - Setup instructions: [Bielik Documentation](#)

## 🔄 n8n Workflows

Pre-configured workflows are located in the `workflows/` directory. To import a workflow:

1. Open n8n at http://localhost:5678
2. Go to Workflows > Import from File
3. Select the desired JSON file from the `workflows/` directory

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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