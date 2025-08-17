"""
PayPal Business Account Integration Automation
Handles PayPal API setup, webhook configuration, and payment processing
"""

import json
import os
from datetime import datetime

import requests
from dotenv import load_dotenv

load_dotenv()


class PayPalAutomation:
    def __init__(self):
        self.client_id = os.getenv("PAYPAL_CLIENT_ID", "")
        self.client_secret = os.getenv("PAYPAL_CLIENT_SECRET", "")
        self.sandbox = os.getenv("PAYPAL_SANDBOX", "true").lower() == "true"
        self.base_url = (
            "https://api-m.sandbox.paypal.com"
            if self.sandbox
            else "https://api-m.paypal.com"
        )
        self.access_token = None

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def get_access_token(self):
        """Get PayPal access token for API calls"""
        if not self.client_id or not self.client_secret:
            self.log("❌ PayPal credentials not found in .env file")
            return False

        url = f"{self.base_url}/v1/oauth2/token"
        headers = {
            "Accept": "application/json",
            "Accept-Language": "en_US",
        }
        data = "grant_type=client_credentials"

        try:
            response = requests.post(
                url,
                headers=headers,
                data=data,
                auth=(self.client_id, self.client_secret),
            )
            response.raise_for_status()

            token_data = response.json()
            self.access_token = token_data["access_token"]
            self.log("✅ PayPal access token obtained")
            return True

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Failed to get PayPal access token: {e}")
            return False

    def setup_webhooks(self):
        """Setup PayPal webhooks for payment notifications"""
        if not self.access_token:
            if not self.get_access_token():
                return False

        webhook_url = "https://freshthreads.xyz/api/paypal/webhook"

        webhook_data = {
            "url": webhook_url,
            "event_types": [
                {"name": "PAYMENT.CAPTURE.COMPLETED"},
                {"name": "PAYMENT.CAPTURE.DENIED"},
                {"name": "CHECKOUT.ORDER.APPROVED"},
                {"name": "CHECKOUT.ORDER.COMPLETED"},
            ],
        }

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.access_token}",
        }

        try:
            url = f"{self.base_url}/v1/notifications/webhooks"
            response = requests.post(url, headers=headers, json=webhook_data)
            response.raise_for_status()

            webhook_info = response.json()
            self.log(f"✅ PayPal webhook created: {webhook_info['id']}")

            # Save webhook ID to .env
            self.update_env_file("PAYPAL_WEBHOOK_ID", webhook_info["id"])
            return True

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Failed to create PayPal webhook: {e}")
            return False

    def update_env_file(self, key, value):
        """Update .env file with new values"""
        env_file = ".env"

        # Read existing content
        if os.path.exists(env_file):
            with open(env_file, "r") as f:
                lines = f.readlines()
        else:
            lines = []

        # Update or add the key
        key_found = False
        for i, line in enumerate(lines):
            if line.startswith(f"{key}="):
                lines[i] = f"{key}={value}\n"
                key_found = True
                break

        if not key_found:
            lines.append(f"{key}={value}\n")

        # Write back to file
        with open(env_file, "w") as f:
            f.writelines(lines)

        self.log(f"✅ Updated .env with {key}")

    def test_connection(self):
        """Test PayPal API connection"""
        self.log("Testing PayPal API connection...")
        return self.get_access_token()

    def generate_integration_code(self):
        """Generate HTML/JS code for PayPal integration"""
        integration_code = f"""
<!-- PayPal Integration Code for FreshThreads -->
<script src="https://www.paypal.com/sdk/js?client-id={self.client_id}&currency=USD"></script>
<div id="paypal-button-container"></div>

<script>
paypal.Buttons({{
    createOrder: function(data, actions) {{
        return actions.order.create({{
            purchase_units: [{{
                amount: {{
                    value: '29.99' // Replace with actual product price
                }}
            }}]
        }});
    }},
    onApprove: function(data, actions) {{
        return actions.order.capture().then(function(details) {{
            alert('Transaction completed by ' + details.payer.name.given_name);
            // Handle successful payment
            window.location.href = '/order-success.html';
        }});
    }},
    onError: function(err) {{
        console.error('PayPal error:', err);
        alert('Payment failed. Please try again.');
    }}
}}).render('#paypal-button-container');
</script>
"""

        with open("docs/paypal-integration.html", "w") as f:
            f.write(integration_code)

        self.log("✅ PayPal integration code generated: docs/paypal-integration.html")


def main():
    paypal = PayPalAutomation()

    print("=== PayPal Business Automation ===")
    print("1. Test connection")
    print("2. Setup webhooks")
    print("3. Generate integration code")
    print("4. Full setup")

    choice = input("Select option (1-4): ").strip()

    if choice == "1":
        paypal.test_connection()
    elif choice == "2":
        paypal.setup_webhooks()
    elif choice == "3":
        paypal.generate_integration_code()
    elif choice == "4":
        if paypal.test_connection():
            paypal.setup_webhooks()
            paypal.generate_integration_code()
            print("✅ Full PayPal setup completed!")
    else:
        print("Invalid option")


if __name__ == "__main__":
    main()
