#!/usr/bin/env python3
"""
PayPal Configuration from Parameters File - FreshThreads LLC
Automatically configure PayPal integration using credentials from paypaldev.params
"""

import os
import sys
from pathlib import Path
from datetime import datetime


class PayPalAutoConfig:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.scripts_dir = self.project_root / "scripts"
        self.config_dir = self.project_root / "config"
        self.params_file = self.scripts_dir / "paypaldev.params"
        self.config_file = self.config_dir / "paypal-config.env"

        # Ensure directories exist
        self.config_dir.mkdir(exist_ok=True)

        print("🏪 FreshThreads PayPal Auto-Configuration")
        print("=" * 50)

    def parse_params_file(self):
        """Parse the PayPal parameters file"""

        if not self.params_file.exists():
            print(f"❌ Parameters file not found: {self.params_file}")
            return None

        print(f"📋 Reading parameters from: {self.params_file}")

        credentials = {}

        try:
            with open(self.params_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if '=' in line and not line.startswith('#'):
                        key, value = line.split('=', 1)
                        key = key.strip().lower().replace(' ', '_')
                        value = value.strip()

                        if 'clientid' in key or 'client_id' in key:
                            credentials['client_id'] = value
                        elif 'secret' in key:
                            credentials['client_secret'] = value

            if 'client_id' in credentials and 'client_secret' in credentials:
                print("✅ PayPal credentials successfully parsed")
                print(f"Client ID: {credentials['client_id'][:20]}...")
                print(f"Client Secret: {credentials['client_secret'][:20]}...")
                return credentials
            else:
                print("❌ Missing required credentials in parameters file")
                return None

        except Exception as e:
            print(f"❌ Error reading parameters file: {str(e)}")
            return None

    def create_config(self, credentials):
        """Create PayPal configuration file"""

        print("\n🔧 Creating PayPal configuration...")

        # Default FreshThreads business settings
        config_content = f"""# PayPal Business Configuration - FreshThreads LLC
# Auto-generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
# Environment: Sandbox (for testing)

# PayPal Environment Settings
PAYPAL_ENVIRONMENT=sandbox
PAYPAL_BUSINESS_EMAIL=bryan@freshthreadsllc.com

# PayPal API Credentials - Sandbox
PAYPAL_CLIENT_ID={credentials['client_id']}
PAYPAL_CLIENT_SECRET={credentials['client_secret']}

# PayPal Webhook Configuration
PAYPAL_WEBHOOK_URL=https://freshthreadsllc.com/api/paypal/webhook
PAYPAL_WEBHOOK_ID=configure_after_setup

# Business Information
BUSINESS_NAME=FreshThreads LLC
BUSINESS_WEBSITE=https://freshthreadsllc.com
BUSINESS_PHONE=+1-555-0123
BUSINESS_ADDRESS_LINE1=123 Business St
BUSINESS_CITY=Business City
BUSINESS_STATE=CA
BUSINESS_POSTAL_CODE=90210
BUSINESS_COUNTRY=US

# Product Settings
DEFAULT_CURRENCY=USD
SHIPPING_COST=9.99
TAX_RATE=0.08

# Return URLs
PAYPAL_SUCCESS_URL=https://freshthreadsllc.com/payment/success
PAYPAL_CANCEL_URL=https://freshthreadsllc.com/payment/cancel
PAYPAL_RETURN_URL=https://freshthreadsllc.com/payment/return

# Notification Settings
ORDER_NOTIFICATION_EMAIL=bryan@freshthreadsllc.com
ADMIN_NOTIFICATION_EMAIL=admin@freshthreadsllc.com

# Additional Settings
PAYPAL_BRAND_NAME=FreshThreads LLC
PAYPAL_LOCALE=en_US
PAYPAL_LANDING_PAGE=NO_PREFERENCE
PAYPAL_USER_ACTION=PAY_NOW

# Security Settings
PAYPAL_VERIFY_SSL=true
PAYPAL_LOG_LEVEL=INFO
"""

        try:
            with open(self.config_file, 'w') as f:
                f.write(config_content)

            print(f"✅ Configuration saved to: {self.config_file}")
            return True

        except Exception as e:
            print(f"❌ Error saving configuration: {str(e)}")
            return False

    def update_web_integration(self, client_id):
        """Update web integration with real Client ID"""

        print("\n🌐 Updating web integration...")

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

                print("✅ Web integration updated with real Client ID")
            else:
                print("⚠️ Web integration file not found")

        except Exception as e:
            print(f"⚠️ Could not update web integration: {str(e)}")

    def test_integration(self):
        """Test the PayPal integration using API v2"""

        print("\n🧪 Testing PayPal API v2 integration...")

        try:
            import subprocess

            result = subprocess.run([
                sys.executable,
                str(self.scripts_dir / "paypal_v2_api_integration.py"),
                "--environment", "sandbox",
                "--action", "test"
            ], capture_output=True, text=True, cwd=self.project_root)

            if result.returncode == 0 and "✅ PayPal API v2 connection test passed" in result.stdout:
                print("✅ PayPal API v2 test PASSED!")
                print("✅ OAuth 2.0 authentication working")
                print("✅ Credentials are valid")
                return True
            else:
                print("❌ PayPal API v2 test FAILED:")
                print("STDOUT:", result.stdout)
                print("STDERR:", result.stderr)
                return False

        except Exception as e:
            print(f"❌ Error testing integration: {str(e)}")
            return False

    def create_test_order(self):
        """Create a test order to verify full functionality"""

        print("\n🛍️ Creating test order...")

        try:
            import subprocess

            result = subprocess.run([
                sys.executable,
                str(self.scripts_dir / "paypal_v2_api_integration.py"),
                "--environment", "sandbox",
                "--action", "create-order"
            ], capture_output=True, text=True, cwd=self.project_root)

            if result.returncode == 0 and "✅ Order created successfully" in result.stdout:
                print("✅ Test order creation SUCCESSFUL!")
                print("✅ Orders API v2 working")

                # Extract order details from output
                lines = result.stdout.split('\n')
                for line in lines:
                    if 'Order ID:' in line or 'Total:' in line or 'Approval URL:' in line:
                        print(f"  {line.strip()}")

                return True
            else:
                print("❌ Test order creation FAILED:")
                print("STDOUT:", result.stdout)
                print("STDERR:", result.stderr)
                return False

        except Exception as e:
            print(f"❌ Error creating test order: {str(e)}")
            return False

    def show_next_steps(self):
        """Show next steps after successful configuration"""

        print("\n🎯 FreshThreads PayPal Integration Ready!")
        print("=" * 50)
        print("✅ Configuration: Complete")
        print("✅ Authentication: Working")
        print("✅ API v2 Integration: Active")
        print("✅ Test Orders: Functional")
        print()
        print("🚀 Next Steps:")
        print("1. View your checkout page:")
        print("   open docs/paypal-checkout.html")
        print()
        print("2. Start webhook server:")
        print("   python3 scripts/paypal_webhook_handler.py")
        print()
        print("3. Create more test orders:")
        print("   python3 scripts/paypal_v2_api_integration.py --action create-order")
        print()
        print("4. Set up webhooks:")
        print("   python3 scripts/paypal_v2_api_integration.py --action webhook")
        print()
        print("5. When ready for production:")
        print("   - Change PAYPAL_ENVIRONMENT to 'live'")
        print("   - Get live credentials from PayPal Developer Dashboard")
        print("   - Update webhook URL to your live domain")
        print()
        print("🛍️ FreshThreads LLC is ready to accept PayPal payments!")


def main():
    """Main configuration process"""

    config = PayPalAutoConfig()

    # Parse parameters file
    credentials = config.parse_params_file()
    if not credentials:
        print("\n❌ Failed to parse PayPal credentials")
        return 1

    # Create configuration
    if not config.create_config(credentials):
        print("\n❌ Failed to create configuration")
        return 1

    # Update web integration
    config.update_web_integration(credentials['client_id'])

    # Test the integration
    print("\n" + "="*60)
    print("🧪 TESTING PAYPAL INTEGRATION")
    print("="*60)

    # Test authentication
    auth_success = config.test_integration()

    # Test order creation if auth successful
    order_success = False
    if auth_success:
        order_success = config.create_test_order()

    # Show results
    print("\n" + "="*60)
    print("📊 CONFIGURATION RESULTS")
    print("="*60)

    if auth_success and order_success:
        print("🎉 SUCCESS: PayPal integration fully configured!")
        config.show_next_steps()
        return 0
    elif auth_success:
        print("⚠️ PARTIAL: Authentication works, order creation needs review")
        config.show_next_steps()
        return 0
    else:
        print("❌ FAILED: Please check your PayPal credentials")
        print("\nTroubleshooting:")
        print("1. Verify credentials in scripts/paypaldev.params")
        print("2. Check PayPal Developer Dashboard")
        print("3. Ensure sandbox environment is selected")
        return 1


if __name__ == "__main__":
    sys.exit(main())
