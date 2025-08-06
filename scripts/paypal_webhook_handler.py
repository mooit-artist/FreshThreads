#!/usr/bin/env python3
"""
PayPal Webhook Handler - FreshThreads LLC
Processes PayPal webhook notifications for real-time order updates
"""

import json
import os
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
from flask import Flask, request, jsonify
import smtplib
from email.mime.text import MimeText
from email.mime.multipart import MimeMultipart

# Load environment variables
env_file = Path(__file__).parent.parent / "config" / "paypal-config.env"
load_dotenv(env_file)

class PayPalWebhookHandler:
    def __init__(self):
        self.business_email = os.getenv('ORDER_NOTIFICATION_EMAIL')
        self.admin_email = os.getenv('ADMIN_NOTIFICATION_EMAIL')
        self.logs_dir = Path(__file__).parent.parent / "logs" / "paypal"
        self.logs_dir.mkdir(parents=True, exist_ok=True)

    def handle_webhook(self, webhook_data: dict) -> dict:
        """Process incoming PayPal webhook"""

        try:
            event_type = webhook_data.get('event_type')
            resource = webhook_data.get('resource', {})

            print(f"📨 Received webhook: {event_type}")

            if event_type == 'PAYMENT.SALE.COMPLETED':
                return self.handle_payment_completed(resource)
            elif event_type == 'PAYMENT.SALE.DENIED':
                return self.handle_payment_denied(resource)
            elif event_type == 'INVOICING.INVOICE.PAID':
                return self.handle_invoice_paid(resource)
            elif event_type == 'INVOICING.INVOICE.CANCELLED':
                return self.handle_invoice_cancelled(resource)
            else:
                print(f"⚠️ Unhandled webhook event: {event_type}")
                return {"status": "ignored", "event": event_type}

        except Exception as e:
            print(f"❌ Error handling webhook: {str(e)}")
            return {"status": "error", "error": str(e)}

    def handle_payment_completed(self, payment_data: dict) -> dict:
        """Handle completed payment"""

        try:
            payment_id = payment_data.get('id')
            amount = payment_data.get('amount', {})
            total = amount.get('total', '0')
            currency = amount.get('currency', 'USD')

            print(f"✅ Payment completed: {payment_id} - {currency} {total}")

            # Send notification email
            self.send_notification_email(
                subject=f"FreshThreads - Payment Received: {currency} {total}",
                message=f"""
                New payment received for FreshThreads LLC:

                Payment ID: {payment_id}
                Amount: {currency} {total}
                Status: Completed
                Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

                Please process this order promptly.
                """,
                to_email=self.business_email
            )

            # Log to file
            self.log_transaction('payment_completed', payment_data)

            return {
                "status": "processed",
                "payment_id": payment_id,
                "amount": f"{currency} {total}"
            }

        except Exception as e:
            print(f"❌ Error processing payment completion: {str(e)}")
            return {"status": "error", "error": str(e)}

    def handle_payment_denied(self, payment_data: dict) -> dict:
        """Handle denied payment"""

        try:
            payment_id = payment_data.get('id')
            print(f"❌ Payment denied: {payment_id}")

            # Send alert email
            self.send_notification_email(
                subject="FreshThreads - Payment Denied Alert",
                message=f"""
                Payment denied for FreshThreads LLC:

                Payment ID: {payment_id}
                Status: Denied
                Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

                Please review and follow up if necessary.
                """,
                to_email=self.admin_email
            )

            return {"status": "processed", "payment_id": payment_id}

        except Exception as e:
            print(f"❌ Error processing payment denial: {str(e)}")
            return {"status": "error", "error": str(e)}

    def send_notification_email(self, subject: str, message: str, to_email: str):
        """Send email notification (logging for now)"""

        try:
            print(f"📧 Email notification: {subject}")
            print(f"📧 To: {to_email}")
            print(f"📧 Message: {message[:100]}...")

            # Log email instead of sending (for testing)
            self.log_email(subject, message, to_email)

        except Exception as e:
            print(f"❌ Error sending email: {str(e)}")

    def log_transaction(self, event_type: str, data: dict):
        """Log transaction to file"""

        try:
            log_file = self.logs_dir / f"transactions-{datetime.now().strftime('%Y-%m')}.log"

            log_entry = {
                "timestamp": datetime.now().isoformat(),
                "event_type": event_type,
                "data": data
            }

            with open(log_file, 'a') as f:
                f.write(json.dumps(log_entry) + '\n')

        except Exception as e:
            print(f"❌ Error logging transaction: {str(e)}")

    def log_email(self, subject: str, message: str, to_email: str):
        """Log email notification"""

        try:
            log_dir = self.logs_dir.parent / "notifications"
            log_dir.mkdir(exist_ok=True)
            log_file = log_dir / f"emails-{datetime.now().strftime('%Y-%m')}.log"

            log_entry = {
                "timestamp": datetime.now().isoformat(),
                "subject": subject,
                "to": to_email,
                "message": message
            }

            with open(log_file, 'a') as f:
                f.write(json.dumps(log_entry) + '\n')

        except Exception as e:
            print(f"❌ Error logging email: {str(e)}")

# Flask web server for webhook endpoint
app = Flask(__name__)
webhook_handler = PayPalWebhookHandler()

@app.route('/api/paypal/webhook', methods=['POST'])
def paypal_webhook():
    try:
        webhook_data = request.get_json()
        result = webhook_handler.handle_webhook(webhook_data)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "PayPal Webhook Handler"})

if __name__ == "__main__":
    print("🚀 Starting PayPal webhook server...")
    print("📍 Webhook endpoint: http://localhost:5000/api/paypal/webhook")
    app.run(host='0.0.0.0', port=5000, debug=False)
