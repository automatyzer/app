const axios = require('axios');

// Default configuration
const DEFAULT_CONFIG = {
  ollama: {
    baseUrl: 'http://localhost:11434',
    defaultModel: 'llama2',
    endpoint: '/api/generate'
  },
  bielik: {
    baseUrl: 'http://localhost:8080',
    defaultModel: 'bielik-7b',
    endpoint: '/v1/chat/completions'
  }
};

/**
 * Handle LLM request by routing to the appropriate service
 * @param {string} prompt - The prompt to send to the LLM
 * @param {Object} options - Options including model and service
 * @returns {Promise<string>} - The generated response
 */
async function handleLLMRequest(prompt, options = {}) {
  const { 
    model = DEFAULT_CONFIG.ollama.defaultModel, 
    service = 'ollama' 
  } = options;

  const config = DEFAULT_CONFIG[service] || DEFAULT_CONFIG.ollama;
  
  try {
    let response;
    
    if (service === 'ollama') {
      response = await axios.post(
        `${config.baseUrl}${config.endpoint}`,
        {
          model,
          prompt,
          stream: false
        }
      );
      return response.data.response;
    } 
    
    // Bielik API format
    response = await axios.post(
      `${config.baseUrl}${config.endpoint}`,
      {
        model,
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7
      }
    );
    
    return response.data.choices[0].message.content;
    
  } catch (error) {
    console.error('Error calling LLM service:', error);
    throw new Error(`Failed to get response from ${service}: ${error.message}`);
  }
}

/**
 * List available models from the LLM service
 * @param {string} service - The service to list models from ('ollama' or 'bielik')
 * @returns {Promise<Array>} - List of available models
 */
async function listModels(service = 'ollama') {
  const config = DEFAULT_CONFIG[service] || DEFAULT_CONFIG.ollama;
  
  try {
    const response = await axios.get(`${config.baseUrl}/api/tags`);
    return response.data.models || [];
  } catch (error) {
    console.error('Error listing models:', error);
    throw new Error(`Failed to list models from ${service}: ${error.message}`);
  }
}

module.exports = {
  handleLLMRequest,
  listModels
};
