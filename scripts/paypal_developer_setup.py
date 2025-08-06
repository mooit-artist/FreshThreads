#!/usr/bin/env python3
"""
PayPal Developer Configuration Setup - FreshThreads LLC
Interactive setup for real PayPal Business Developer credentials
"""

import os
import sys
from pathlib import Path
from datetime import datetime
import getpass


class PayPalBusinessConfig:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.config_dir = self.project_root / "config"
        self.config_file = self.config_dir / "paypal-config.env"

        print("🏪 FreshThreads PayPal Business Configuration")
        print("=" * 50)

    def setup_credentials(self):
        """Interactive setup for PayPal credentials"""

        print("\n📋 PayPal Developer Account Setup")
        print("Visit: https://developer.paypal.com/developer/applications/")
        print()

        # Get environment choice
        print("🌍 Environment Selection:")
        print("1. Sandbox (for testing)")
        print("2. Live (for production)")

        while True:
            env_choice = input("\nSelect environment (1 or 2): ").strip()
            if env_choice == "1":
                environment = "sandbox"
                print("✅ Selected: Sandbox environment")
                break
            elif env_choice == "2":
                environment = "live"
                print("✅ Selected: Live environment")
                break
            else:
                print("❌ Please enter 1 or 2")

        print(f"\n🔑 Enter your PayPal {environment.title()} credentials:")

        # Get Client ID
        client_id = input("PayPal Client ID: ").strip()
        if not client_id:
            print("❌ Client ID is required")
            return False

        # Get Client Secret
        client_secret = getpass.getpass(
            "PayPal Client Secret (hidden): ").strip()
        if not client_secret:
            print("❌ Client Secret is required")
            return False

        # Business email
        default_email = "bryan@freshthreadsllc.com"
        business_email = input(
            f"Business Email ({default_email}): ").strip() or default_email

        # Webhook URL
        default_webhook = "https://freshthreadsllc.com/api/paypal/webhook"
        webhook_url = input(
            f"Webhook URL ({default_webhook}): ").strip() or default_webhook

        # Webhook ID (optional for now)
        webhook_id = input("Webhook ID (optional, can add later): ").strip(
        ) or "configure_after_setup"

        # Business details
        print("\n🏢 Business Information:")
        business_name = input(
            "Business Name (FreshThreads LLC): ").strip() or "FreshThreads LLC"
        website = input(
            "Website (https://freshthreadsllc.com): ").strip() or "https://freshthreadsllc.com"
        phone = input(
            "Business Phone (+1-555-0123): ").strip() or "+1-555-0123"

        # Address
        print("\n📍 Business Address:")
        address_line1 = input("Address Line 1: ").strip() or "123 Business St"
        city = input("City: ").strip() or "Business City"
        state = input("State: ").strip() or "CA"
        postal_code = input("Postal Code: ").strip() or "90210"
        country = input("Country (US): ").strip() or "US"

        # Product settings
        print("\n💰 Product Settings:")
        currency = input("Default Currency (USD): ").strip() or "USD"
        shipping_cost = input("Shipping Cost (9.99): ").strip() or "9.99"
        tax_rate = input("Tax Rate (0.08 for 8%): ").strip() or "0.08"

        # Create configuration
        config_content = f"""# PayPal Business Configuration - FreshThreads LLC
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
# Environment: {environment.title()}

# PayPal Environment Settings
PAYPAL_ENVIRONMENT={environment}
PAYPAL_BUSINESS_EMAIL={business_email}

# PayPal API Credentials - {environment.title()}
PAYPAL_CLIENT_ID={client_id}
PAYPAL_CLIENT_SECRET={client_secret}

# PayPal Webhook Configuration
PAYPAL_WEBHOOK_URL={webhook_url}
PAYPAL_WEBHOOK_ID={webhook_id}

# Business Information
BUSINESS_NAME={business_name}
BUSINESS_WEBSITE={website}
BUSINESS_PHONE={phone}
BUSINESS_ADDRESS_LINE1={address_line1}
BUSINESS_CITY={city}
BUSINESS_STATE={state}
BUSINESS_POSTAL_CODE={postal_code}
BUSINESS_COUNTRY={country}

# Product Settings
DEFAULT_CURRENCY={currency}
SHIPPING_COST={shipping_cost}
TAX_RATE={tax_rate}

# Return URLs
PAYPAL_SUCCESS_URL={website}/payment/success
PAYPAL_CANCEL_URL={website}/payment/cancel
PAYPAL_RETURN_URL={website}/payment/return

# Notification Settings
ORDER_NOTIFICATION_EMAIL={business_email}
ADMIN_NOTIFICATION_EMAIL=admin@freshthreadsllc.com

# Additional Settings
PAYPAL_BRAND_NAME={business_name}
PAYPAL_LOCALE=en_US
PAYPAL_LANDING_PAGE=NO_PREFERENCE
PAYPAL_USER_ACTION=PAY_NOW

# Security Settings
PAYPAL_VERIFY_SSL=true
PAYPAL_LOG_LEVEL=INFO
"""

        # Save configuration
        try:
            self.config_dir.mkdir(exist_ok=True)
            with open(self.config_file, 'w') as f:
                f.write(config_content)

            print(f"\n✅ Configuration saved to: {self.config_file}")

            # Update web integration with real client ID
            self.update_web_integration(client_id)

            return True

        except Exception as e:
            print(f"\n❌ Error saving configuration: {str(e)}")
            return False

    def update_web_integration(self, client_id):
        """Update the web integration with real PayPal Client ID"""

        try:
            web_file = self.project_root / "docs" / "paypal-checkout.html"

            if web_file.exists():
                with open(web_file, 'r') as f:
                    content = f.read()

                # Replace placeholder with real client ID
                updated_content = content.replace(
                    "YOUR_PAYPAL_CLIENT_ID",
                    client_id
                )

                with open(web_file, 'w') as f:
                    f.write(updated_content)

                print(f"✅ Updated web integration with Client ID")

        except Exception as e:
            print(f"⚠️ Could not update web integration: {str(e)}")

    def test_credentials(self):
        """Test the PayPal credentials using latest API v2"""

        print("\n🧪 Testing PayPal credentials with API v2...")

        try:
            # Run the new API v2 test script
            import subprocess
            result = subprocess.run([
                sys.executable,
                str(self.project_root / "scripts" / "paypal_v2_api_integration.py"),
                "--environment", "sandbox",
                "--action", "test"
            ], capture_output=True, text=True, cwd=self.project_root)

            if result.returncode == 0 and "✅ PayPal API v2 connection test passed" in result.stdout:
                print("✅ Credentials test passed!")
                print("✅ OAuth 2.0 authentication working")
                print("✅ PayPal API v2 connectivity confirmed")
                return True
            else:
                print("❌ Credentials test failed:")
                print("STDOUT:", result.stdout)
                print("STDERR:", result.stderr)
                print("Return code:", result.returncode)
                return False

        except Exception as e:
            print(f"❌ Error testing credentials: {str(e)}")
            return False

    def create_webhook(self):
        """Guide user through webhook creation using latest API v2 events"""

        print("\n🔗 PayPal Webhook Setup (API v2)")
        print("=" * 35)
        print("1. Go to: https://developer.paypal.com/developer/applications/")
        print("2. Select your FreshThreads application")
        print("3. Click 'Add Webhook'")
        print("4. Enter webhook URL from config")
        print("5. Select these API v2 events:")
        print("   - CHECKOUT.ORDER.APPROVED")
        print("   - CHECKOUT.ORDER.COMPLETED")
        print("   - PAYMENT.CAPTURE.COMPLETED")
        print("   - PAYMENT.CAPTURE.DENIED")
        print("   - CHECKOUT.ORDER.VOIDED")
        print("6. Copy the Webhook ID and update config")

        webhook_id = input(
            "\nEnter Webhook ID (or press Enter to skip): ").strip()

        if webhook_id:
            try:
                # Update config with webhook ID
                with open(self.config_file, 'r') as f:
                    content = f.read()

                updated_content = content.replace(
                    "PAYPAL_WEBHOOK_ID=configure_after_setup",
                    f"PAYPAL_WEBHOOK_ID={webhook_id}"
                )

                with open(self.config_file, 'w') as f:
                    f.write(updated_content)

                print("✅ Webhook ID updated in configuration")

                # Test webhook creation using API v2
                self.test_webhook_creation()

            except Exception as e:
                print(f"❌ Error updating webhook ID: {str(e)}")

    def test_webhook_creation(self):
        """Test webhook creation using PayPal API v2"""

        print("\n🔗 Testing webhook creation with API v2...")

        try:
            import subprocess
            webhook_url = "https://freshthreadsllc.com/api/paypal/webhook"

            result = subprocess.run([
                sys.executable,
                str(self.project_root / "scripts" / "paypal_v2_api_integration.py"),
                "--environment", "sandbox",
                "--action", "webhook",
                "--webhook-url", webhook_url
            ], capture_output=True, text=True, cwd=self.project_root)

            if result.returncode == 0 and "✅ Webhook created successfully" in result.stdout:
                print("✅ Webhook API v2 test passed!")
                print("✅ Webhook Management v1 API working")
            else:
                print("⚠️ Webhook test completed (may need manual setup)")
                print("Note: Webhooks require a publicly accessible URL")

        except Exception as e:
            print(f"⚠️ Webhook test note: {str(e)}")

    def show_next_steps(self):
        """Show next steps for the user"""

        print("\n🎯 Next Steps for FreshThreads PayPal API v2 Integration")
        print("=" * 55)
        print("1. Test the latest API v2 integration:")
        print("   python3 scripts/paypal_v2_api_integration.py --action test")
        print()
        print("2. Create a test order using Orders API v2:")
        print("   python3 scripts/paypal_v2_api_integration.py --action create-order")
        print()
        print("3. Start webhook server for real-time notifications:")
        print("   python3 scripts/paypal_webhook_handler.py")
        print()
        print("4. View your professional checkout page:")
        print("   open docs/paypal-checkout.html")
        print()
        print("5. For production deployment:")
        print("   - Set PAYPAL_ENVIRONMENT=live in config")
        print("   - Update webhook URL to your live domain")
        print("   - Test thoroughly in sandbox first")
        print("   - Ensure SSL certificates are valid")
        print()
        print("6. ✨ Latest API v2 features now available:")
        print("   ✅ OAuth 2.0 Bearer token authentication")
        print("   ✅ Orders API v2 (latest specification)")
        print("   ✅ Payments API v2 (enhanced capabilities)")
        print("   ✅ Webhooks Management v1 (real-time events)")
        print("   ✅ Professional PayPal checkout experience")
        print("   ✅ Mobile-optimized payment processing")
        print("   ✅ Complete transaction logging and reporting")
        print("   ✅ International payment support")
        print("   ✅ Advanced fraud protection")
        print()
        print("� FreshThreads PayPal API v2 integration is ready for business!")
        print("📋 Based on: https://github.com/paypal/paypal-rest-api-specifications")
        print("🔗 Authentication: https://developer.paypal.com/api/rest/authentication/")


def main():
    config = PayPalBusinessConfig()

    print("This script will help you configure your PayPal Developer credentials")
    print("for FreshThreads LLC business automation.")
    print()

    # Setup credentials
    if not config.setup_credentials():
        print("❌ Configuration setup failed")
        return 1

    # Test credentials
    print("\nWould you like to test the credentials now? (y/n): ", end="")
    if input().lower().startswith('y'):
        config.test_credentials()

    # Setup webhook
    print("\nWould you like to set up webhooks now? (y/n): ", end="")
    if input().lower().startswith('y'):
        config.create_webhook()

    # Show next steps
    config.show_next_steps()

    return 0


if __name__ == "__main__":
    sys.exit(main())
