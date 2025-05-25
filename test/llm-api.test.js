const axios = require('axios');
const { handleLLMRequest } = require('../llm-router');

// Mock axios for testing
jest.mock('axios');

describe('LLM API Tests', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  describe('handleLLMRequest', () => {
    it('should make a successful request to Ollama API', async () => {
      const mockResponse = {
        data: {
          response: 'This is a test response from Ollama',
          done: true
        }
      };
      
      axios.post.mockResolvedValueOnce(mockResponse);
      
      const prompt = 'Hello, how are you?';
      const response = await handleLLMRequest(prompt);
      
      expect(axios.post).toHaveBeenCalledWith(
        'http://localhost:11434/api/generate',
        {
          model: 'llama2',
          prompt: prompt,
          stream: false,
          options: {
            temperature: 0.7,
            num_predict: 2048
          }
        },
        expect.any(Object)
      );
      
      expect(response).toBe(mockResponse.data.response);
    });

    it('should handle API errors gracefully', async () => {
      const errorMessage = 'API Error';
      axios.post.mockRejectedValueOnce(new Error(errorMessage));
      
      await expect(handleLLMRequest('test')).rejects.toThrow(`Failed to get response from ollama: ${errorMessage}`);
    });
  });

  // Add more test cases for different scenarios
  describe('Edge Cases', () => {
    it('should handle empty prompt', async () => {
      const mockResponse = {
        data: {
          response: '',
          done: true
        }
      };
      
      axios.post.mockResolvedValueOnce(mockResponse);
      
      const response = await handleLLMRequest('');
      expect(response).toBe('');
    });

    it('should handle very long prompts', async () => {
      const longPrompt = 'a'.repeat(10000);
      const mockResponse = {
        data: {
          response: 'Processed long prompt',
          done: true
        }
      };
      
      axios.post.mockResolvedValueOnce(mockResponse);
      
      const response = await handleLLMRequest(longPrompt);
      expect(response).toBe('Processed long prompt');
    });
  });
});
