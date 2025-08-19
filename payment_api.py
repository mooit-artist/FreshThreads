#!/usr/bin/env python3
"""
Fresh Threads LLC - Payment Processing API
Handles Stripe and PayPal payment processing with Printify order creation
"""

import os
import json
import logging
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import stripe
import requests

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration from environment variables
STRIPE_SECRET_KEY = os.getenv(
    'STRIPE_SECRET_KEY', 'STRIPE_SECRET_KEY_PLACEHOLDER')
STRIPE_WEBHOOK_SECRET = os.getenv('STRIPE_WEBHOOK_SECRET', '')
PAYPAL_CLIENT_ID = os.getenv(
    'PAYPAL_CLIENT_ID_SANDBOX', 'PAYPAL_CLIENT_ID_PLACEHOLDER')
PAYPAL_CLIENT_SECRET = os.getenv(
    'PAYPAL_CLIENT_SECRET_SANDBOX', 'PAYPAL_CLIENT_SECRET_PLACEHOLDER')
PRINTIFY_API_KEY = os.getenv(
    'PRINTIFY_API_KEY', 'PRINTIFY_API_KEY_PLACEHOLDER')
PRINTIFY_SHOP_ID = os.getenv('PRINTIFY_SHOP_ID', '6563836')

# Initialize Stripe
stripe.api_key = STRIPE_SECRET_KEY

# Printify API configuration
PRINTIFY_API_URL = "https://api.printify.com/v1"


def get_printify_headers():
    """Get headers for Printify API requests"""
    return {
        'Authorization': f'Bearer {PRINTIFY_API_KEY}',
        'Content-Type': 'application/json',
        'User-Agent': 'FreshThreads/1.0'
    }


@app.route('/api/create-checkout-session', methods=['POST'])
def create_checkout_session():
    """Create a Stripe checkout session"""
    try:
        data = request.get_json()

        # Validate required fields
        if not data.get('line_items'):
            return jsonify({'error': 'Line items are required'}), 400

        # Create Stripe checkout session
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=data['line_items'],
            mode='payment',
            success_url=data.get('success_url', request.host_url +
                                 'order-success.html?session_id={CHECKOUT_SESSION_ID}'),
            cancel_url=data.get('cancel_url', request.host_url + 'cart.html'),
            customer_email=data.get('customer_email'),
            metadata={
                'source': 'fresh_threads_website',
                'shop_id': PRINTIFY_SHOP_ID
            },
            shipping_address_collection={
                'allowed_countries': ['US', 'CA'],
            },
            shipping_options=[
                {
                    'shipping_rate_data': {
                        'type': 'fixed_amount',
                        'fixed_amount': {
                            'amount': 599,  # $5.99 in cents
                            'currency': 'usd',
                        },
                        'display_name': 'Standard shipping',
                        'delivery_estimate': {
                            'minimum': {
                                'unit': 'business_day',
                                'value': 5,
                            },
                            'maximum': {
                                'unit': 'business_day',
                                'value': 7,
                            },
                        },
                    },
                },
            ],
        )

        logger.info(f"Created Stripe checkout session: {session.id}")
        return jsonify({'id': session.id})

    except stripe.error.StripeError as e:
        logger.error(f"Stripe error: {str(e)}")
        return jsonify({'error': f'Stripe error: {str(e)}'}), 400
    except Exception as e:
        logger.error(f"Checkout session creation error: {str(e)}")
        return jsonify({'error': 'Failed to create checkout session'}), 500


@app.route('/api/process-paypal-order', methods=['POST'])
def process_paypal_order():
    """Process a completed PayPal order"""
    try:
        data = request.get_json()
        paypal_order = data.get('paypal_order')
        items = data.get('items', [])
        customer = data.get('customer', {})

        if not paypal_order or not items:
            return jsonify({'error': 'PayPal order and items are required'}), 400

        # Log the PayPal order
        logger.info(f"Processing PayPal order: {paypal_order.get('id')}")

        # Create Printify order
        printify_order = create_printify_order({
            'payment_method': 'paypal',
            'payment_id': paypal_order.get('id'),
            'items': items,
            'customer': customer,
            'total_amount': paypal_order.get('purchase_units', [{}])[0].get('amount', {}).get('value', 0)
        })

        return jsonify({
            'success': True,
            'paypal_order_id': paypal_order.get('id'),
            'printify_order_id': printify_order.get('id') if printify_order else None,
            'message': 'Order processed successfully'
        })

    except Exception as e:
        logger.error(f"PayPal order processing error: {str(e)}")
        return jsonify({'error': 'Failed to process PayPal order'}), 500


@app.route('/api/create-printify-order', methods=['POST'])
def create_printify_order_endpoint():
    """Create an order in Printify"""
    try:
        data = request.get_json()
        printify_order = create_printify_order(data)
        return jsonify(printify_order)
    except Exception as e:
        logger.error(f"Printify order creation error: {str(e)}")
        return jsonify({'error': 'Failed to create Printify order'}), 500


def create_printify_order(order_data):
    """Create an order in Printify system"""
    try:
        # Map order data to Printify format
        printify_order_data = {
            "external_id": f"FT_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{order_data.get('payment_id', 'unknown')}",
            "label": f"Fresh Threads Order - {order_data.get('customer', {}).get('firstName', '')} {order_data.get('customer', {}).get('lastName', '')}",
            "line_items": [],
            "shipping_method": 1,  # Standard shipping
            "is_printify_express": False,
            "send_shipping_notification": True,
            "address_to": {
                "first_name": order_data.get('customer', {}).get('firstName', ''),
                "last_name": order_data.get('customer', {}).get('lastName', ''),
                "email": order_data.get('customer', {}).get('email', ''),
                "phone": order_data.get('customer', {}).get('phone', ''),
                "country": "US",
                "region": order_data.get('customer', {}).get('state', ''),
                "address1": order_data.get('customer', {}).get('address', ''),
                "city": order_data.get('customer', {}).get('city', ''),
                "zip": order_data.get('customer', {}).get('zip', '')
            }
        }

        # Add line items (you'll need to map your cart items to Printify product variants)
        for item in order_data.get('items', []):
            printify_order_data['line_items'].append({
                "product_id": item.get('printifyProductId', ''),
                "variant_id": item.get('printifyVariantId', ''),
                "quantity": item.get('quantity', 1)
            })

        # Make request to Printify API
        response = requests.post(
            f"{PRINTIFY_API_URL}/shops/{PRINTIFY_SHOP_ID}/orders.json",
            headers=get_printify_headers(),
            json=printify_order_data
        )

        if response.status_code == 200:
            logger.info(
                f"Successfully created Printify order: {response.json().get('id')}")
            return response.json()
        else:
            logger.error(
                f"Printify API error: {response.status_code} - {response.text}")
            return None

    except Exception as e:
        logger.error(f"Error creating Printify order: {str(e)}")
        return None


@app.route('/api/webhook/stripe', methods=['POST'])
def stripe_webhook():
    """Handle Stripe webhooks"""
    payload = request.get_data()
    sig_header = request.headers.get('Stripe-Signature')

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )

        # Handle the event
        if event['type'] == 'checkout.session.completed':
            session = event['data']['object']
            logger.info(f"Stripe checkout completed: {session['id']}")

            # Create Printify order from Stripe session
            # You'll need to implement this based on your cart data storage

        elif event['type'] == 'payment_intent.succeeded':
            payment_intent = event['data']['object']
            logger.info(f"Stripe payment succeeded: {payment_intent['id']}")

        else:
            logger.info(f"Unhandled Stripe event type: {event['type']}")

        return jsonify({'status': 'success'})

    except ValueError as e:
        logger.error(f"Invalid payload: {str(e)}")
        return jsonify({'error': 'Invalid payload'}), 400
    except stripe.error.SignatureVerificationError as e:
        logger.error(f"Invalid signature: {str(e)}")
        return jsonify({'error': 'Invalid signature'}), 400


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'stripe': 'configured' if STRIPE_SECRET_KEY != 'STRIPE_SECRET_KEY_PLACEHOLDER' else 'not_configured',
            'paypal': 'configured' if PAYPAL_CLIENT_ID != 'PAYPAL_CLIENT_ID_PLACEHOLDER' else 'not_configured',
            'printify': 'configured' if PRINTIFY_API_KEY != 'PRINTIFY_API_KEY_PLACEHOLDER' else 'not_configured'
        }
    })


@app.route('/api/products', methods=['GET'])
def get_products():
    """Get products from Printify"""
    try:
        response = requests.get(
            f"{PRINTIFY_API_URL}/shops/{PRINTIFY_SHOP_ID}/products.json",
            headers=get_printify_headers()
        )

        if response.status_code == 200:
            return jsonify(response.json())
        else:
            return jsonify({'error': 'Failed to fetch products'}), 500

    except Exception as e:
        logger.error(f"Error fetching products: {str(e)}")
        return jsonify({'error': 'Failed to fetch products'}), 500


if __name__ == '__main__':
    # Validate configuration
    missing_config = []
    if STRIPE_SECRET_KEY == 'STRIPE_SECRET_KEY_PLACEHOLDER':
        missing_config.append('STRIPE_SECRET_KEY')
    if PAYPAL_CLIENT_ID == 'PAYPAL_CLIENT_ID_PLACEHOLDER':
        missing_config.append('PAYPAL_CLIENT_ID_SANDBOX')
    if PRINTIFY_API_KEY == 'PRINTIFY_API_KEY_PLACEHOLDER':
        missing_config.append('PRINTIFY_API_KEY')

    if missing_config:
        logger.warning(
            f"Missing environment variables: {', '.join(missing_config)}")
        logger.warning("Some features may not work properly")

    logger.info("Starting Fresh Threads Payment API...")
    logger.info(f"Printify Shop ID: {PRINTIFY_SHOP_ID}")

    app.run(host='127.0.0.1', port=8001, debug=True)
