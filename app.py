#!/usr/bin/env python3
"""
FreshThreads Backend API Server
Main Flask application that combines all API modules.
"""

from flask import Flask, jsonify
from flask_cors import CORS
import os
import logging
from datetime import datetime

# Note: Individual API modules can be run standalone
# This main app provides a unified entry point

# Configure logging
os.makedirs('logs', exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('logs/backend.log', mode='a')
    ]
)

logger = logging.getLogger(__name__)


def create_app():
    """Create and configure the Flask application."""
    app = Flask(__name__)

    # Configure CORS for frontend domains
    CORS(app, origins=[
        'https://freshthreadsllc.com',          # Production frontend
        'https://mooit-artist.github.io',      # GitHub Pages
        'http://localhost:5500',                # Local development
        'https://localhost:5500',               # Local development HTTPS
        'http://127.0.0.1:5500',               # Alternative local
        'https://127.0.0.1:5500'               # Alternative local HTTPS
    ])

    # Health check endpoint
    @app.route('/health', methods=['GET'])
    def health_check():
        """Health check endpoint for monitoring."""
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'version': '1.0.0',
            'service': 'freshthreads-backend'
        }), 200

    # API info endpoint
    @app.route('/api', methods=['GET'])
    def api_info():
        """API information endpoint."""
        return jsonify({
            'name': 'FreshThreads API',
            'version': '1.0.0',
            'description': 'Backend API for FreshThreads e-commerce platform',
            'endpoints': {
                'health': '/health',
                'info': '/api',
                'printify': 'Run: python api/printify_proxy.py (port 8000)',
                'payment': 'Run: python api/payment_api.py (port 8001)',
                'contact': 'Run: python api/contact_api.py (port 8002)'
            },
            'note': 'Individual APIs can run standalone or use this unified server',
            'timestamp': datetime.utcnow().isoformat()
        }), 200

    # TODO: Import and register API blueprints when ready
    # For now, APIs run as standalone services

    return app


# Create the application instance
app = create_app()

if __name__ == '__main__':
    # Development server
    port = int(os.environ.get('PORT', 8000))
    debug = os.environ.get('FLASK_ENV') == 'development'

    logger.info(f"Starting FreshThreads Backend API on port {port}")
    logger.info(f"Debug mode: {debug}")
    logger.info("Note: This is a unified entry point.")
    logger.info("Individual APIs can also run standalone:")
    logger.info("  - Printify API: python api/printify_proxy.py")
    logger.info("  - Payment API: python api/payment_api.py")
    logger.info("  - Contact API: python api/contact_api.py")

    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )
