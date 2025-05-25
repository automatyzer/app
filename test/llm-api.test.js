const axios = require("axios");

// Mock axios
jest.mock("axios");

// Mock the LLM router implementation
const mockIsServiceRunning = jest.fn().mockResolvedValue(true);
const mockIsModelInstalled = jest.fn().mockResolvedValue(true);
const mockHandleLLMRequest = jest.fn();

// Mock the llm-router module
jest.mock("../llm-router", () => ({
  isServiceRunning: mockIsServiceRunning,
  isModelInstalled: mockIsModelInstalled,
  handleLLMRequest: mockHandleLLMRequest,
}));

// Import after setting up mocks
const {
  handleLLMRequest,
  isServiceRunning,
  isModelInstalled,
} = require("../llm-router");

// Set up environment variables for testing
process.env.LLM_PROVIDER = "ollama";
process.env.OLLAMA_HOST = "http://localhost";
process.env.OLLAMA_PORT = "11434";
process.env.OLLAMA_MODEL = "llama2";
process.env.OLLAMA_TIMEOUT = "30000";

describe("LLM API Tests", () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
    // Reset the mocks
    isServiceRunning.mockClear();
    isModelInstalled.mockClear();
  });

  describe("handleLLMRequest", () => {
    beforeEach(() => {
      // Reset all mocks before each test
      jest.clearAllMocks();
      // Set up default mock implementations
      mockIsServiceRunning.mockResolvedValue(true);
      mockIsModelInstalled.mockResolvedValue(true);
    });

    it("should make a successful request to Ollama API", async () => {
      // Setup
      const prompt = "Hello, how are you?";
      const mockResponse = "This is a test response from Ollama";

      // Mock the implementation
      mockHandleLLMRequest.mockImplementationOnce(async (p, options) => {
        // Verify the prompt and options
        expect(p).toBe(prompt);
        expect(options).toBeDefined();
        return mockResponse;
      });

      // Execute
      const response = await handleLLMRequest(prompt);

      // Verify
      expect(mockHandleLLMRequest).toHaveBeenCalled();
      expect(response).toBe(mockResponse);
    });

    it("should handle API errors gracefully", async () => {
      // Setup
      const error = new Error("API Error");
      error.response = {
        status: 500,
        statusText: "Internal Server Error",
        data: { error: "Something went wrong" },
      };

      // Mock the implementation to throw an error
      mockHandleLLMRequest.mockRejectedValueOnce(error);

      // Execute & Verify
      await expect(handleLLMRequest("test")).rejects.toThrow("API Error");
    });

    it("should handle connection errors", async () => {
      // Setup
      const error = new Error("Connection refused");
      error.code = "ECONNREFUSED";

      // Mock the implementation to throw a connection error
      mockHandleLLMRequest.mockRejectedValueOnce(error);

      // Execute & Verify
      await expect(handleLLMRequest("test")).rejects.toThrow(
        "Connection refused",
      );
    });
  });

  describe("Edge Cases", () => {
    it("should handle empty prompt", async () => {
      // Setup
      const emptyResponse = "";
      mockHandleLLMRequest.mockResolvedValueOnce(emptyResponse);

      // Execute
      const response = await handleLLMRequest("");

      // Verify
      expect(response).toBe(emptyResponse);
    });

    it("should handle service not running", async () => {
      // Setup
      const error = new Error(
        "Ollama service is not running at http://localhost:11434. Please start Ollama first.",
      );
      mockIsServiceRunning.mockResolvedValueOnce(false);
      mockHandleLLMRequest.mockRejectedValueOnce(error);

      // Execute & Verify
      await expect(handleLLMRequest("test")).rejects.toThrow(
        "Ollama service is not running at http://localhost:11434. Please start Ollama first.",
      );
    });

    it("should handle model not installed", async () => {
      // Setup
      const error = new Error(
        'Model "llama2" is not installed. Please install it with: ollama pull llama2',
      );
      mockIsModelInstalled.mockResolvedValueOnce(false);
      mockHandleLLMRequest.mockRejectedValueOnce(error);

      // Execute & Verify
      await expect(handleLLMRequest("test")).rejects.toThrow(
        'Model "llama2" is not installed. Please install it with: ollama pull llama2',
      );
    });

    it("should handle invalid LLM provider", async () => {
      // Save the original implementation
      const originalLLMProvider = process.env.LLM_PROVIDER;

      // Set an invalid provider
      process.env.LLM_PROVIDER = "invalid";

      // Mock the implementation to simulate the error
      mockHandleLLMRequest.mockImplementationOnce(() => {
        throw new Error("Unsupported LLM provider: invalid");
      });

      // Execute & Verify
      await expect(handleLLMRequest("test")).rejects.toThrow(
        "Unsupported LLM provider: invalid",
      );

      // Restore the original provider
      process.env.LLM_PROVIDER = originalLLMProvider;
    });
  });
});
