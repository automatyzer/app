// Configure test environment
process.env.NODE_ENV = "test";

// Set test timeout to 30 seconds
jest.setTimeout(30000);

// Global test configurations
global.console = {
  ...console,
  // Uncomment to debug
  // log: jest.fn(),
  // debug: jest.fn(),
  // info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};
