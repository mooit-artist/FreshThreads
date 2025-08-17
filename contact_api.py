#!/usr/bin/env python3
"""
Flask backend for FreshThreads contact form with Office 365 integration
Serves as an endpoint for contact form submissions and sends emails via O365
"""

import os
import sys
import json
import logging
from datetime import datetime
from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
from werkzeug.exceptions import BadRequest
from dotenv import load_dotenv

# Load environment variables from config file
config_path = os.path.join(os.path.dirname(
    __file__), 'config', 'o365-config.env')
load_dotenv(config_path)

# Add scripts directory to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), 'scripts'))

try:
    from o365_email_handler import O365EmailHandler
except ImportError:
    print("Warning: O365EmailHandler not available. Install required packages.")
    O365EmailHandler = None

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(
            '/Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads/logs/contact_api.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for frontend integration

# Initialize email handler
email_handler = None
if O365EmailHandler:
    email_handler = O365EmailHandler()


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'email_handler': 'available' if email_handler else 'unavailable'
    })


@app.route('/contact', methods=['POST'])
def handle_contact_form():
    """Handle contact form submissions"""
    try:
        # Get form data
        if request.is_json:
            form_data = request.get_json()
        else:
            form_data = request.form.to_dict()

        logger.info(
            f"Received contact form submission from: {form_data.get('email', 'unknown')}")

        # Validate required fields
        required_fields = ['name', 'email', 'subject', 'message']
        missing_fields = []

        for field in required_fields:
            if not form_data.get(field, '').strip():
                missing_fields.append(field)

        if missing_fields:
            return jsonify({
                'success': False,
                'error': f"Missing required fields: {', '.join(missing_fields)}"
            }), 400

        # Validate email format
        email = form_data['email'].strip()
        import re
        email_pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
        if not re.match(email_pattern, email):
            return jsonify({
                'success': False,
                'error': 'Invalid email format'
            }), 400

        # Clean and sanitize data
        clean_data = {
            'name': form_data['name'].strip()[:100],  # Limit length
            'email': email,
            'subject': form_data['subject'].strip()[:200],
            'message': form_data['message'].strip()[:2000]
        }

        # Send email if handler is available
        if email_handler:
            result = email_handler.send_contact_form_email(clean_data)

            if result['success']:
                logger.info(
                    f"Email sent successfully via {result.get('method', 'unknown method')}")
                return jsonify({
                    'success': True,
                    'message': 'Your message has been sent successfully. We\'ll get back to you within 24 hours.'
                })
            else:
                logger.error(
                    f"Failed to send email: {result.get('error', 'Unknown error')}")
                return jsonify({
                    'success': False,
                    'error': 'Failed to send email. Please try again or contact us directly.'
                }), 500
        else:
            # Log the submission even if we can't send email
            logger.warning(
                "Email handler not available, logging submission only")

            # Save to file as backup
            log_submission(clean_data)

            return jsonify({
                'success': True,
                'message': 'Your message has been received. We\'ll get back to you within 24 hours.'
            })

    except BadRequest as e:
        logger.error(f"Bad request: {str(e)}")
        return jsonify({
            'success': False,
            'error': 'Invalid request format'
        }), 400

    except Exception as e:
        logger.error(f"Error handling contact form: {str(e)}")
        return jsonify({
            'success': False,
            'error': 'Internal server error. Please try again later.'
        }), 500


def log_submission(form_data):
    """Log form submission to file as backup"""
    try:
        log_dir = '/Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads/logs'
        os.makedirs(log_dir, exist_ok=True)

        log_file = os.path.join(log_dir, 'contact_submissions.log')

        with open(log_file, 'a', encoding='utf-8') as f:
            submission = {
                'timestamp': datetime.now().isoformat(),
                'data': form_data
            }
            f.write(json.dumps(submission) + '\n')

    except Exception as e:
        logger.error(f"Failed to log submission: {str(e)}")


@app.route('/test-email', methods=['GET'])
def test_email():
    """Test email functionality (for development)"""
    if not email_handler:
        return jsonify({
            'success': False,
            'error': 'Email handler not available'
        }), 500

    test_data = {
        'name': 'Test User',
        'email': 'test@example.com',
        'subject': 'Test Email',
        'message': 'This is a test message to verify email functionality.'
    }

    result = email_handler.send_contact_form_email(test_data)
    return jsonify(result)


@app.route('/', methods=['GET'])
def index():
    """Basic index page for the API"""
    return render_template_string("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>FreshThreads Contact API</title>
        <style>
            body { font-family: system-ui, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
            .endpoint { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
            .method { color: #007bff; font-weight: bold; }
        </style>
    </head>
    <body>
        <h1>FreshThreads Contact Form API</h1>
        <p>Backend service for handling contact form submissions with Office 365 integration.</p>

        <h2>Available Endpoints:</h2>

        <div class="endpoint">
            <p><span class="method">GET</span> <code>/health</code></p>
            <p>Health check endpoint</p>
        </div>

        <div class="endpoint">
            <p><span class="method">POST</span> <code>/contact</code></p>
            <p>Submit contact form data</p>
            <p>Required fields: name, email, subject, message</p>
        </div>

        <div class="endpoint">
            <p><span class="method">GET</span> <code>/test-email</code></p>
            <p>Test email functionality (development only)</p>
        </div>

        <h2>Status:</h2>
        <p>Email Handler: {{ 'Available' if email_handler else 'Not Available' }}</p>
        <p>Server Time: {{ timestamp }}</p>
    </body>
    </html>
    """, email_handler=email_handler is not None, timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))


if __name__ == '__main__':
    # Development server
    port = int(os.getenv('PORT', 5001))
    debug = os.getenv('FLASK_ENV') == 'development'

    print(f"Starting FreshThreads Contact API on port {port}")
    print(
        f"Email handler: {'Available' if email_handler else 'Not Available'}")
    print(f"Logs directory: /Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads/logs")

    app.run(host='0.0.0.0', port=port, debug=debug)
