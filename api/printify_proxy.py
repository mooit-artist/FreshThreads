#!/usr/bin/env python3
"""
Fresh Threads LLC - Printify API Proxy Server
This Flask server acts as a proxy for Printify API calls to solve CORS issues.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import os
import logging
from datetime import datetime

# Configure logging with fallback for permission issues
handlers = [logging.StreamHandler()]  # Always use console output

# Try to add file logging if possible
try:
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    handlers.append(logging.FileHandler('logs/printify_proxy.log'))
except (PermissionError, OSError) as e:
    print(
        f"Warning: Could not create log file: {e}. Using console logging only.")

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=handlers
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Printify API Configuration
PRINTIFY_API_URL = "https://api.printify.com/v1"
PRINTIFY_API_KEY = os.getenv(
    'PRINTIFY_API_KEY', 'PRINTIFY_API_KEY_PLACEHOLDER')

# Shop ID - can be set via environment or default
PRINTIFY_SHOP_ID = os.getenv('PRINTIFY_SHOP_ID', '6563836')


def get_printify_headers():
    """Get headers for Printify API requests"""
    return {
        'Authorization': f'Bearer {PRINTIFY_API_KEY}',
        'Content-Type': 'application/json',
        'User-Agent': 'FreshThreads/1.0'
    }


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'printify-proxy',
        'timestamp': datetime.now().isoformat()
    })


@app.route('/api/printify/<path:endpoint>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def proxy_printify_api(endpoint):
    """
    Proxy all Printify API requests to solve CORS issues

    Examples:
    GET /api/printify/shops.json -> GET https://api.printify.com/v1/shops.json
    GET /api/printify/shops/123/products.json -> GET https://api.printify.com/v1/shops/123/products.json
    """
    try:
        # Build the full Printify API URL
        printify_url = f"{PRINTIFY_API_URL}/{endpoint}"

        # Log the request
        logger.info(f"Proxying {request.method} {endpoint}")
        logger.info(f"Target URL: {printify_url}")

        # Prepare request parameters
        headers = get_printify_headers()

        # Forward the request to Printify
        if request.method == 'GET':
            response = requests.get(
                printify_url, headers=headers, params=request.args)
        elif request.method == 'POST':
            response = requests.post(
                printify_url, headers=headers, json=request.get_json(), params=request.args)
        elif request.method == 'PUT':
            response = requests.put(
                printify_url, headers=headers, json=request.get_json(), params=request.args)
        elif request.method == 'DELETE':
            response = requests.delete(
                printify_url, headers=headers, params=request.args)
        else:
            return jsonify({'error': 'Method not allowed'}), 405

        # Log the response
        logger.info(
            f"Printify API responded with status: {response.status_code}")

        # Return the response
        try:
            return jsonify(response.json()), response.status_code
        except ValueError:
            # If response is not JSON, return as text
            return response.text, response.status_code

    except requests.exceptions.RequestException as e:
        logger.error(f"Request to Printify API failed: {str(e)}")
        return jsonify({
            'error': 'Printify API request failed',
            'message': str(e)
        }), 500
    except Exception as e:
        logger.error(f"Proxy error: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500


@app.route('/api/printify/test', methods=['GET'])
def test_printify_connection():
    """Test endpoint to verify Printify connection"""
    try:
        response = requests.get(
            f"{PRINTIFY_API_URL}/shops.json", headers=get_printify_headers())

        if response.status_code == 200:
            shops = response.json()
            return jsonify({
                'status': 'success',
                'message': 'Connected to Printify API',
                'shops': shops,
                'shop_count': len(shops)
            })
        else:
            return jsonify({
                'status': 'error',
                'message': f'Printify API returned {response.status_code}',
                'response': response.text
            }), response.status_code

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Failed to connect to Printify: {str(e)}'
        }), 500


if __name__ == '__main__':
    import sys

    # Ensure logs directory exists
    os.makedirs('logs', exist_ok=True)

    # Check for SSL flag
    use_ssl = '--ssl' in sys.argv

    if use_ssl:
        # HTTPS configuration
        logger.info(
            "Starting Fresh Threads Printify Proxy Server with HTTPS...")
        logger.info(f"Printify API URL: {PRINTIFY_API_URL}")
        logger.info("Server will run on https://0.0.0.0:8443")

        # SSL context
        import ssl
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        context.load_cert_chain(
            '/app/ssl/certs/backend.crt', '/app/ssl/private/backend.key')

        # Run with HTTPS
        app.run(host='0.0.0.0', port=8443, debug=False, ssl_context=context)
    else:
        # HTTP configuration (default)
        logger.info("Starting Fresh Threads Printify Proxy Server...")
        logger.info(f"Printify API URL: {PRINTIFY_API_URL}")
        logger.info("Server will run on http://0.0.0.0:8000")

        # Run the Flask app on all interfaces for Docker
        app.run(host='0.0.0.0', port=8000, debug=False)
