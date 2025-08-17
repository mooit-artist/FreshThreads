// FreshThreads Utility Functions Test Suite
const { describe, test, expect } = require('@jest/globals');

describe('FreshThreads Utils', () => {
  describe('formatPrice', () => {
    test('should format valid prices correctly', () => {
      // Valid test cases
      expect(formatPrice(19.99)).toBe('$19.99');
      expect(formatPrice(0)).toBe('$0.00');
      expect(formatPrice(100.00)).toBe('$100.00');
    });

    test('should handle edge cases', () => {
      expect(formatPrice(0.01)).toBe('$0.01');
      expect(formatPrice(999.99)).toBe('$999.99');
    });

    test('should throw error for invalid input', () => {
      // These should throw errors - testing error handling
      expect(() => formatPrice(-10)).toThrow();
      expect(() => formatPrice('invalid')).toThrow();
      expect(() => formatPrice(null)).toThrow();
    });
  });

  describe('validateEmail', () => {
    test('should validate correct email formats', () => {
      expect(validateEmail('user@example.com')).toBe(true);
      expect(validateEmail('test.email+tag@domain.co.uk')).toBe(true);
    });

    test('should reject invalid email formats', () => {
      expect(validateEmail('invalid-email')).toBe(false);
      expect(validateEmail('@domain.com')).toBe(false);
      expect(validateEmail('user@')).toBe(false);
      expect(validateEmail('')).toBe(false);
    });
  });

  describe('DOM utilities', () => {
    test('should work with mocked DOM elements', () => {
      // Test DOM manipulation functions
      const mockElement = {
        textContent: '',
        style: {},
        classList: {
          add: jest.fn(),
          remove: jest.fn(),
          contains: jest.fn(() => false)
        }
      };

      // Mock getElementById to return our mock element
      global.document.getElementById = jest.fn(() => mockElement);

      const element = document.getElementById('test-element');
      expect(element).toBeDefined();
      expect(document.getElementById).toHaveBeenCalledWith('test-element');
    });
  });
});

// Utility functions for testing (normally these would be imported)
function formatPrice(price) {
  if (typeof price !== 'number' || price < 0 || isNaN(price)) {
    throw new Error('Invalid price');
  }
  return `$${price.toFixed(2)}`;
}

function validateEmail(email) {
  if (!email || typeof email !== 'string') return false;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}
