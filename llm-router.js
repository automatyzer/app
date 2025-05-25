const axios = require("axios");
require("dotenv").config();

// Configuration from environment variables
const CONFIG = {
  app: {
    port: process.env.APP_PORT || 3000,
    nodeEnv: process.env.NODE_ENV || "development",
    logLevel: process.env.LOG_LEVEL || "info",
  },
  llm: {
    provider: process.env.LLM_PROVIDER || "ollama",
    timeout: parseInt(process.env.LLM_TIMEOUT) || 30000,
    maxTokens: parseInt(process.env.LLM_MAX_TOKENS) || 2048,
    temperature: parseFloat(process.env.LLM_TEMPERATURE) || 0.7,
  },
  ollama: {
    host: process.env.OLLAMA_HOST || "http://localhost",
    port: process.env.OLLAMA_PORT || 11434,
    model: process.env.OLLAMA_MODEL || "llama2",
    timeout: parseInt(process.env.OLLAMA_TIMEOUT) || 30000,
    baseUrl() {
      // If host already includes protocol and port, return as is
      if (this.host.match(/^https?:\/\//) && this.host.match(/:\d+$/)) {
        return this.host;
      }
      // If host has protocol but no port, add port
      if (this.host.match(/^https?:\/\//)) {
        return `${this.host.replace(/\/+$/, "")}:${this.port}`;
      }
      // If no protocol, add http:// and port
      return `http://${this.host.replace(/\/+$/, "")}:${this.port}`;
    },
    endpoint: "/api/generate",
  },
  bielik: {
    host: process.env.BIELIK_HOST || "http://localhost",
    port: process.env.BIELIK_PORT || 8080,
    model: process.env.BIELIK_MODEL || "bielik-7b",
    apiKey: process.env.BIELIK_API_KEY || "",
    timeout: parseInt(process.env.BIELIK_TIMEOUT) || 30000,
    baseUrl() {
      // If host already includes protocol and port, return as is
      if (this.host.match(/^https?:\/\//) && this.host.match(/:\d+$/)) {
        return this.host;
      }
      // If host has protocol but no port, add port
      if (this.host.match(/^https?:\/\//)) {
        return `${this.host.replace(/\/+$/, "")}:${this.port}`;
      }
      // If no protocol, add http:// and port
      return `http://${this.host.replace(/\/+$/, "")}:${this.port}`;
    },
    endpoint: "/v1/chat/completions",
  },
};

/**
 * Handle LLM request by routing to the appropriate service
 * @param {string} prompt - The prompt to send to the LLM
 * @param {Object} options - Options including model and service
 * @returns {Promise<string>} - The generated response
 */
async function isServiceRunning(baseUrl) {
  try {
    await axios.get(`${baseUrl}/api/tags`, { timeout: 2000 });
    return true;
  } catch (error) {
    console.error(`Service at ${baseUrl} is not running:`, error.message);
    return false;
  }
}

async function isModelInstalled(model) {
  try {
    const response = await axios.get(`${CONFIG.ollama.baseUrl()}/api/tags`, {
      timeout: CONFIG.ollama.timeout,
    });
    return response.data.models.some((m) => m.name.includes(model));
  } catch (error) {
    console.error("Error checking installed models:", error.message);
    return false;
  }
}

async function handleLLMRequest(prompt, options = {}) {
  const {
    model = CONFIG.llm.provider === "ollama"
      ? CONFIG.ollama.model
      : CONFIG.bielik.model,
    service = CONFIG.llm.provider,
    temperature = CONFIG.llm.temperature,
    maxTokens = CONFIG.llm.maxTokens,
  } = options;

  const config = service === "bielik" ? CONFIG.bielik : CONFIG.ollama;
  const timeout = config.timeout || CONFIG.llm.timeout;

  try {
    // Check if service is running
    if (service === "ollama" && !(await isServiceRunning(config.baseUrl()))) {
      throw new Error(
        `Ollama service is not running at ${config.baseUrl()}. Please start Ollama first.`,
      );
    }

    // Check if model is installed (for Ollama)
    if (service === "ollama" && !(await isModelInstalled(model))) {
      throw new Error(
        `Model "${model}" is not installed. Please install it with: ollama pull ${model}`,
      );
    }

    const requestConfig = {
      timeout,
      headers: {},
    };

    // Add API key for Bielik if provided
    if (service === "bielik" && config.apiKey) {
      requestConfig.headers["Authorization"] = `Bearer ${config.apiKey}`;
    }

    let response;

    if (service === "ollama") {
      response = await axios.post(
        `${config.baseUrl()}${config.endpoint}`,
        {
          model,
          prompt,
          stream: false,
          options: {
            temperature,
            num_predict: maxTokens,
          },
        },
        requestConfig,
      );
      return response.data.response;
    }

    // Bielik API format
    response = await axios.post(
      `${config.baseUrl()}${config.endpoint}`,
      {
        model,
        messages: [{ role: "user", content: prompt }],
        temperature,
        max_tokens: maxTokens,
      },
      requestConfig,
    );

    return response.data.choices[0].message.content;
  } catch (error) {
    console.error("Error calling LLM service:", error);

    let errorMessage = `Failed to get response from ${service}`;

    if (error.code === "ECONNREFUSED") {
      errorMessage = `Cannot connect to ${service} service at ${config.baseUrl}. `;
      if (service === "ollama") {
        errorMessage += "Make sure Ollama is running with: ollama serve";
      }
    } else if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      errorMessage = `${service} error: ${error.response.status} - ${error.response.statusText}`;
      if (error.response.data && error.response.data.error) {
        errorMessage += `\n${error.response.data.error}`;
      }
    } else if (error.request) {
      // The request was made but no response was received
      errorMessage = `No response from ${service} at ${config.baseUrl}`;
    }

    throw new Error(errorMessage);
  }
}

/**
 * List available models from the LLM service
 * @param {string} service - The service to list models from ('ollama' or 'bielik')
 * @returns {Promise<Array>} - List of available models
 */
async function listModels(service = CONFIG.llm.provider) {
  const config = service === "bielik" ? CONFIG.bielik : CONFIG.ollama;

  try {
    if (service === "ollama") {
      const response = await axios.get(`${config.baseUrl()}/api/tags`, {
        timeout: config.timeout,
      });
      return response.data.models || [];
    } else {
      // For Bielik, we might need to implement a different endpoint or handle it differently
      console.warn("Listing models for Bielik is not yet implemented");
      return [];
    }
  } catch (error) {
    console.error(`Error listing models from ${service}:`, error.message);
    throw new Error(`Failed to list models from ${service}: ${error.message}`);
  }
}

module.exports = {
  handleLLMRequest,
  listModels,
};
