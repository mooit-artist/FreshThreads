// ESLint Configuration for FreshThreads
// Modern ESLint v9+ flat config format

export default [
  {
    // Apply to JavaScript files
    files: ["**/*.js"],

    // Ignore patterns
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/*.min.js"
    ],

    // Language options
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: {
        // Browser globals
        window: "readonly",
        document: "readonly",
        console: "readonly",
        fetch: "readonly",
        localStorage: "readonly",
        sessionStorage: "readonly",
        alert: "readonly",
        confirm: "readonly",
        setTimeout: "readonly",
        setInterval: "readonly",
        clearTimeout: "readonly",
        clearInterval: "readonly",
        MutationObserver: "readonly",

        // Node.js globals (for scripts)
        process: "readonly",
        __dirname: "readonly",
        __filename: "readonly",
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        Buffer: "readonly",
        global: "readonly",

        // Custom globals for FreshThreads
        PayPal: "readonly",
        printifyApiKey: "readonly"
      }
    },

    // Rules
    rules: {
      // Error prevention
      "no-unused-vars": "warn",
      "no-undef": "error",
      "no-console": "off", // Allow console in development

      // Best practices
      "eqeqeq": "error",
      "no-eval": "error",
      "no-implied-eval": "error",
      "no-new-func": "error",

      // Code style (relaxed for existing code)
      "semi": ["warn", "always"],
      "quotes": ["warn", "single", { "allowTemplateLiterals": true, "avoidEscape": true }],
      "indent": ["warn", 2],      // Modern JavaScript
      "prefer-const": "warn",
      "prefer-arrow-callback": "warn",
      "arrow-spacing": "error",

      // E-commerce specific
      "no-alert": "off" // Allow alerts for user feedback
    }
  },

  // Specific rules for different file types
  {
    // Browser-specific files
    files: ["docs/**/*.js"],
    languageOptions: {
      globals: {
        PayPal: "readonly",
        printifyApiKey: "readonly"
      }
    }
  },

  {
    // Node.js scripts
    files: ["scripts/**/*.js"],
    languageOptions: {
      sourceType: "commonjs",
      globals: {
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        process: "readonly",
        __dirname: "readonly",
        __filename: "readonly"
      }
    }
  }
];
