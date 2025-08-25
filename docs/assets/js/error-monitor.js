/**
 * FreshThreads Error Monitoring System
 * Simple error tracking and recovery
 */

class ErrorMonitor {
  constructor() {
    this.errors = [];
    this.maxErrors = 50;
    this.init();
  }

  init() {
    // Global error handler
    window.addEventListener('error', (event) => {
      this.logError({
        type: 'JavaScript Error',
        message: event.message,
        filename: event.filename,
        line: event.lineno,
        column: event.colno,
        timestamp: new Date().toISOString()
      });
    });

    // Unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.logError({
        type: 'Unhandled Promise Rejection',
        message: event.reason?.message || event.reason,
        timestamp: new Date().toISOString()
      });
    });

    console.log('✅ FreshThreads Error Monitor initialized');
  }

  logError(error) {
    // Filter out browser extension errors that we can't control
    if (this.isExtensionError(error)) {
      console.debug('🔇 Ignoring browser extension error:', error.message);
      return;
    }

    this.errors.push(error);

    // Keep only recent errors
    if (this.errors.length > this.maxErrors) {
      this.errors = this.errors.slice(-this.maxErrors);
    }

    // Log to console for debugging
    console.error('🚨 Error logged:', error);

    // Show user-friendly message for critical errors
    if (this.isCriticalError(error)) {
      this.showErrorToast('Something went wrong. Please refresh the page.');
    }
  }

  isExtensionError(error) {
    const extensionPatterns = [
      'chrome-extension://',
      'moz-extension://',
      'web_accessible_resources',
      'extension://',
      'safari-web-extension://',
      'ms-browser-extension://'
    ];

    const message = error.message || '';
    const filename = error.filename || '';

    return extensionPatterns.some(pattern =>
      message.includes(pattern) || filename.includes(pattern)
    );
  }

  isCriticalError(error) {
    const criticalPatterns = [
      'ReferenceError',
      'TypeError: Cannot read property',
      'SyntaxError',
      'Unexpected end of input'
    ];

    return criticalPatterns.some(pattern =>
      error.message?.includes(pattern) || error.type?.includes(pattern)
    );
  }

  showErrorToast(message) {
    // Simple toast notification
    const toast = document.createElement('div');
    toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: #dc3545;
      color: white;
      padding: 1rem 1.5rem;
      border-radius: 8px;
      z-index: 10000;
      max-width: 300px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    `;
    toast.textContent = message;

    document.body.appendChild(toast);

    setTimeout(() => {
      toast.remove();
    }, 5000);
  }

  getErrorSummary() {
    return {
      totalErrors: this.errors.length,
      recentErrors: this.errors.slice(-5),
      criticalErrors: this.errors.filter(e => this.isCriticalError(e))
    };
  }

  // Add to window for debugging
  exportLogs() {
    const summary = this.getErrorSummary();
    console.log('📊 Error Summary:', summary);
    return summary;
  }
}

// Initialize global error monitor
window.errorMonitor = new ErrorMonitor();

// Expose for debugging
window.getErrorLogs = () => window.errorMonitor.exportLogs();
