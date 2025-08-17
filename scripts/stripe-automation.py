"""
Stripe Payment Processing Automation
Handles Stripe API setup, webhook configuration, and payment processing
"""

import json
import os
from datetime import datetime

import requests
from dotenv import load_dotenv

load_dotenv()


class StripeAutomation:
    def __init__(self):
        self.secret_key = os.getenv("STRIPE_SECRET_KEY", "")
        self.publishable_key = os.getenv("STRIPE_PUBLISHABLE_KEY", "")
        self.webhook_secret = os.getenv("STRIPE_WEBHOOK_SECRET", "")
        self.base_url = "https://api.stripe.com/v1"

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def test_connection(self):
        """Test Stripe API connection"""
        if not self.secret_key:
            self.log("❌ Stripe secret key not found in .env file")
            return False

        headers = {
            "Authorization": f"Bearer {self.secret_key}",
            "Content-Type": "application/x-www-form-urlencoded",
        }

        try:
            response = requests.get(f"{self.base_url}/account", headers=headers)
            response.raise_for_status()

            account_info = response.json()
            self.log(
                f"✅ Stripe connection successful. Account: {account_info.get('display_name', 'Unknown')}"
            )
            return True

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Stripe connection failed: {e}")
            return False

    def create_product(self, name, price_cents, description=""):
        """Create a product in Stripe"""
        if not self.secret_key:
            self.log("❌ Stripe secret key not configured")
            return None

        headers = {
            "Authorization": f"Bearer {self.secret_key}",
            "Content-Type": "application/x-www-form-urlencoded",
        }

        # Create product
        product_data = {"name": name, "description": description, "type": "good"}

        try:
            response = requests.post(
                f"{self.base_url}/products", headers=headers, data=product_data
            )
            response.raise_for_status()
            product = response.json()

            # Create price for the product
            price_data = {
                "product": product["id"],
                "unit_amount": price_cents,
                "currency": "usd",
            }

            response = requests.post(
                f"{self.base_url}/prices", headers=headers, data=price_data
            )
            response.raise_for_status()
            price = response.json()

            self.log(f"✅ Created product: {name} (${price_cents/100:.2f})")
            return {"product": product, "price": price}

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Failed to create product: {e}")
            return None

    def setup_webhooks(self):
        """Setup Stripe webhooks"""
        if not self.secret_key:
            self.log("❌ Stripe secret key not configured")
            return False

        webhook_url = "https://freshthreads.xyz/api/stripe/webhook"

        webhook_data = {
            "url": webhook_url,
            "enabled_events[]": [
                "payment_intent.succeeded",
                "payment_intent.payment_failed",
                "checkout.session.completed",
            ],
        }

        headers = {
            "Authorization": f"Bearer {self.secret_key}",
            "Content-Type": "application/x-www-form-urlencoded",
        }

        try:
            response = requests.post(
                f"{self.base_url}/webhook_endpoints", headers=headers, data=webhook_data
            )
            response.raise_for_status()

            webhook = response.json()
            self.log(f"✅ Stripe webhook created: {webhook['id']}")

            # Update .env file
            self.update_env_file("STRIPE_WEBHOOK_SECRET", webhook["secret"])
            return True

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Failed to create webhook: {e}")
            return False

    def update_env_file(self, key, value):
        """Update .env file with new values"""
        env_file = ".env"

        if os.path.exists(env_file):
            with open(env_file, "r") as f:
                lines = f.readlines()
        else:
            lines = []

        key_found = False
        for i, line in enumerate(lines):
            if line.startswith(f"{key}="):
                lines[i] = f"{key}={value}\n"
                key_found = True
                break

        if not key_found:
            lines.append(f"{key}={value}\n")

        with open(env_file, "w") as f:
            f.writelines(lines)

        self.log(f"✅ Updated .env with {key}")

    def generate_integration_code(self):
        """Generate Stripe integration code"""
        if not self.publishable_key:
            self.log("❌ Stripe publishable key not configured")
            return

        integration_code = f"""
<!-- Stripe Integration Code for FreshThreads -->
<script src="https://js.stripe.com/v3/"></script>
<button id="checkout-button">Buy Now with Stripe</button>

<script>
const stripe = Stripe('{self.publishable_key}');

document.getElementById('checkout-button').addEventListener('click', function() {{
    stripe.redirectToCheckout({{
        lineItems: [{{
            price: 'price_XXXXXXXXXX', // Replace with actual price ID
            quantity: 1,
        }}],
        mode: 'payment',
        successUrl: 'https://freshthreads.xyz/order-success.html',
        cancelUrl: 'https://freshthreads.xyz/checkout.html',
    }}).then(function(result) {{
        if (result.error) {{
            alert(result.error.message);
        }}
    }});
}});
</script>
"""

        with open("docs/stripe-integration.html", "w") as f:
            f.write(integration_code)

        self.log("✅ Stripe integration code generated: docs/stripe-integration.html")


def main():
    stripe = StripeAutomation()

    print("=== Stripe Business Automation ===")
    print("1. Test connection")
    print("2. Create sample product")
    print("3. Setup webhooks")
    print("4. Generate integration code")
    print("5. Full setup")

    choice = input("Select option (1-5): ").strip()

    if choice == "1":
        stripe.test_connection()
    elif choice == "2":
        name = input("Product name: ").strip() or "FreshThreads T-Shirt"
        price = input("Price in dollars: ").strip() or "29.99"
        stripe.create_product(name, int(float(price) * 100))
    elif choice == "3":
        stripe.setup_webhooks()
    elif choice == "4":
        stripe.generate_integration_code()
    elif choice == "5":
        if stripe.test_connection():
            stripe.setup_webhooks()
            stripe.generate_integration_code()
            stripe.create_product("FreshThreads T-Shirt", 2999, "Premium t-shirt")
            print("✅ Full Stripe setup completed!")
    else:
        print("Invalid option")


if __name__ == "__main__":
    main()
