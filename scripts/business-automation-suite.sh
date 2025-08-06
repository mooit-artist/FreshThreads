#!/bin/bash

# ===================================================
# FreshThreads LLC - Complete Business Automation Suite
# ===================================================
# Purpose: Automate all business setup tasks with documentation
# Author: Bryan Jorgensen
# Date: August 5, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Create automation log
LOG_FILE="automation-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log "=== FreshThreads Business Automation Suite Started ==="

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."

    # Check if PowerShell is available
    if ! command -v pwsh &> /dev/null; then
        warn "PowerShell not found. Some Microsoft 365 automation may not work."
    fi

    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        error "Python3 not found. Required for automation scripts."
        exit 1
    fi

    # Check if virtual environment exists
    if [ ! -d ".venv" ]; then
        log "Creating Python virtual environment..."
        python3 -m venv .venv
    fi

    log "✅ Prerequisites checked"
}

# Function to setup Microsoft 365 automation
setup_m365_automation() {
    log "Setting up Microsoft 365 automation..."

    # Create PowerShell script for email alias management
    cat > scripts/m365-alias-automation.ps1 << 'EOF'
# Microsoft 365 Email Alias Automation
# Connects to Exchange Online and manages email aliases

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "list",

    [Parameter(Mandatory=$false)]
    [string]$UserEmail = "bryan@freshthreadsllc.com",

    [Parameter(Mandatory=$false)]
    [string]$AliasToAdd = ""
)

Write-Host "=== Microsoft 365 Email Alias Automation ===" -ForegroundColor Green

try {
    # Connect to Exchange Online
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
    Connect-ExchangeOnline -ShowBanner:$false

    switch ($Action.ToLower()) {
        "list" {
            Write-Host "Listing all email aliases..." -ForegroundColor Blue
            Get-Mailbox | Select-Object DisplayName,UserPrincipalName,EmailAddresses | Format-Table -AutoSize
        }

        "check" {
            Write-Host "Checking user: $UserEmail" -ForegroundColor Blue
            $mailbox = Get-Mailbox -Identity $UserEmail -ErrorAction SilentlyContinue
            if ($mailbox) {
                Write-Host "✅ User found: $($mailbox.DisplayName)" -ForegroundColor Green
                Write-Host "Email addresses:" -ForegroundColor Yellow
                $mailbox.EmailAddresses | ForEach-Object { Write-Host "  - $_" }
            } else {
                Write-Host "❌ User not found: $UserEmail" -ForegroundColor Red
            }
        }

        "add" {
            if ($AliasToAdd -eq "") {
                Write-Host "❌ Please provide an alias to add" -ForegroundColor Red
                exit 1
            }
            Write-Host "Adding alias $AliasToAdd to $UserEmail..." -ForegroundColor Blue
            Set-Mailbox -Identity $UserEmail -EmailAddresses @{Add="$AliasToAdd"}
            Write-Host "✅ Alias added successfully" -ForegroundColor Green
        }

        default {
            Write-Host "Available actions: list, check, add" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
EOF

    log "✅ Microsoft 365 automation scripts created"
}

# Function to setup PayPal integration automation
setup_paypal_automation() {
    log "Setting up PayPal integration automation..."

    # Activate virtual environment and install required packages
    source .venv/bin/activate
    pip install requests python-dotenv

    # Create PayPal integration script
    cat > scripts/paypal-automation.py << 'EOF'
"""
PayPal Business Account Integration Automation
Handles PayPal API setup, webhook configuration, and payment processing
"""

import os
import json
import requests
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

class PayPalAutomation:
    def __init__(self):
        self.client_id = os.getenv('PAYPAL_CLIENT_ID', '')
        self.client_secret = os.getenv('PAYPAL_CLIENT_SECRET', '')
        self.sandbox = os.getenv('PAYPAL_SANDBOX', 'true').lower() == 'true'
        self.base_url = 'https://api-m.sandbox.paypal.com' if self.sandbox else 'https://api-m.paypal.com'
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
            'Accept': 'application/json',
            'Accept-Language': 'en_US',
        }
        data = 'grant_type=client_credentials'

        try:
            response = requests.post(url, headers=headers, data=data,
                                   auth=(self.client_id, self.client_secret))
            response.raise_for_status()

            token_data = response.json()
            self.access_token = token_data['access_token']
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
                {"name": "CHECKOUT.ORDER.COMPLETED"}
            ]
        }

        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {self.access_token}',
        }

        try:
            url = f"{self.base_url}/v1/notifications/webhooks"
            response = requests.post(url, headers=headers, json=webhook_data)
            response.raise_for_status()

            webhook_info = response.json()
            self.log(f"✅ PayPal webhook created: {webhook_info['id']}")

            # Save webhook ID to .env
            self.update_env_file('PAYPAL_WEBHOOK_ID', webhook_info['id'])
            return True

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Failed to create PayPal webhook: {e}")
            return False

    def update_env_file(self, key, value):
        """Update .env file with new values"""
        env_file = '.env'

        # Read existing content
        if os.path.exists(env_file):
            with open(env_file, 'r') as f:
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
        with open(env_file, 'w') as f:
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

        with open('docs/paypal-integration.html', 'w') as f:
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
EOF

    log "✅ PayPal automation scripts created"
}

# Function to setup Stripe automation
setup_stripe_automation() {
    log "Setting up Stripe automation..."

    # Install Stripe CLI if not present
    if ! command -v stripe &> /dev/null; then
        warn "Stripe CLI not found. Installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install stripe/stripe-cli/stripe
        else
            warn "Please install Stripe CLI manually for your OS"
        fi
    fi

    # Create Stripe automation script
    cat > scripts/stripe-automation.py << 'EOF'
"""
Stripe Payment Processing Automation
Handles Stripe API setup, webhook configuration, and payment processing
"""

import os
import json
import requests
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

class StripeAutomation:
    def __init__(self):
        self.secret_key = os.getenv('STRIPE_SECRET_KEY', '')
        self.publishable_key = os.getenv('STRIPE_PUBLISHABLE_KEY', '')
        self.webhook_secret = os.getenv('STRIPE_WEBHOOK_SECRET', '')
        self.base_url = 'https://api.stripe.com/v1'

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def test_connection(self):
        """Test Stripe API connection"""
        if not self.secret_key:
            self.log("❌ Stripe secret key not found in .env file")
            return False

        headers = {
            'Authorization': f'Bearer {self.secret_key}',
            'Content-Type': 'application/x-www-form-urlencoded'
        }

        try:
            response = requests.get(f"{self.base_url}/account", headers=headers)
            response.raise_for_status()

            account_info = response.json()
            self.log(f"✅ Stripe connection successful. Account: {account_info.get('display_name', 'Unknown')}")
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
            'Authorization': f'Bearer {self.secret_key}',
            'Content-Type': 'application/x-www-form-urlencoded'
        }

        # Create product
        product_data = {
            'name': name,
            'description': description,
            'type': 'good'
        }

        try:
            response = requests.post(f"{self.base_url}/products",
                                   headers=headers, data=product_data)
            response.raise_for_status()
            product = response.json()

            # Create price for the product
            price_data = {
                'product': product['id'],
                'unit_amount': price_cents,
                'currency': 'usd'
            }

            response = requests.post(f"{self.base_url}/prices",
                                   headers=headers, data=price_data)
            response.raise_for_status()
            price = response.json()

            self.log(f"✅ Created product: {name} (${price_cents/100:.2f})")
            return {'product': product, 'price': price}

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
            'url': webhook_url,
            'enabled_events[]': [
                'payment_intent.succeeded',
                'payment_intent.payment_failed',
                'checkout.session.completed'
            ]
        }

        headers = {
            'Authorization': f'Bearer {self.secret_key}',
            'Content-Type': 'application/x-www-form-urlencoded'
        }

        try:
            response = requests.post(f"{self.base_url}/webhook_endpoints",
                                   headers=headers, data=webhook_data)
            response.raise_for_status()

            webhook = response.json()
            self.log(f"✅ Stripe webhook created: {webhook['id']}")

            # Update .env file
            self.update_env_file('STRIPE_WEBHOOK_SECRET', webhook['secret'])
            return True

        except requests.exceptions.RequestException as e:
            self.log(f"❌ Failed to create webhook: {e}")
            return False

    def update_env_file(self, key, value):
        """Update .env file with new values"""
        env_file = '.env'

        if os.path.exists(env_file):
            with open(env_file, 'r') as f:
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

        with open(env_file, 'w') as f:
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

        with open('docs/stripe-integration.html', 'w') as f:
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
            stripe.create_product("FreshThreads T-Shirt", 2999, "Premium custom t-shirt")
            print("✅ Full Stripe setup completed!")
    else:
        print("Invalid option")

if __name__ == "__main__":
    main()
EOF

    log "✅ Stripe automation scripts created"
}

# Function to create business documentation automation
setup_documentation_automation() {
    log "Setting up documentation automation..."

    cat > scripts/business-docs-automation.py << 'EOF'
"""
Business Documentation Automation
Generates and updates business documents, reports, and status files
"""

import os
import json
from datetime import datetime, timedelta
from pathlib import Path

class BusinessDocsAutomation:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.docs_dir = self.project_root / "project-management"

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def update_business_status(self):
        """Update business setup status based on completed tasks"""
        status = {
            "last_updated": datetime.now().isoformat(),
            "business_setup": {
                "banking": self.check_banking_status(),
                "email": self.check_email_status(),
                "payments": self.check_payment_status(),
                "website": self.check_website_status(),
                "products": self.check_product_status()
            },
            "next_actions": self.get_next_actions(),
            "completion_percentage": 0
        }

        # Calculate completion percentage
        completed_items = sum(1 for item in status["business_setup"].values() if item["status"] == "complete")
        total_items = len(status["business_setup"])
        status["completion_percentage"] = round((completed_items / total_items) * 100, 1)

        # Write status to file
        status_file = self.docs_dir / "CURRENT_STATUS.json"
        with open(status_file, 'w') as f:
            json.dump(status, f, indent=2)

        self.log(f"✅ Business status updated: {status['completion_percentage']}% complete")
        return status

    def check_banking_status(self):
        """Check if banking is set up"""
        # Check for banking-related environment variables or files
        env_file = self.project_root / ".env"
        if env_file.exists():
            with open(env_file, 'r') as f:
                content = f.read()
                if "BANK_" in content or "AMEX_" in content:
                    return {"status": "in_progress", "notes": "Banking application submitted"}

        return {"status": "pending", "notes": "Waiting for Amex business account approval"}

    def check_email_status(self):
        """Check if email system is configured"""
        m365_dir = self.docs_dir / "m365tools"
        if m365_dir.exists() and len(list(m365_dir.glob("*.ps1"))) > 0:
            return {"status": "complete", "notes": "M365 and email aliases configured"}
        return {"status": "pending", "notes": "Email system needs setup"}

    def check_payment_status(self):
        """Check if payment processing is configured"""
        env_file = self.project_root / ".env"
        payment_configured = False

        if env_file.exists():
            with open(env_file, 'r') as f:
                content = f.read()
                if any(key in content for key in ["STRIPE_", "PAYPAL_"]):
                    payment_configured = True

        if payment_configured:
            return {"status": "in_progress", "notes": "Payment keys configured, testing needed"}
        return {"status": "pending", "notes": "Payment processing not configured"}

    def check_website_status(self):
        """Check if website is ready"""
        docs_dir = self.project_root / "docs"
        if docs_dir.exists() and (docs_dir / "index.html").exists():
            return {"status": "complete", "notes": "Website deployed and running"}
        return {"status": "pending", "notes": "Website needs completion"}

    def check_product_status(self):
        """Check if products are ready"""
        designs_dir = self.project_root / "docs" / "assets" / "designs"
        if designs_dir.exists() and len(list(designs_dir.glob("*.png"))) > 0:
            return {"status": "in_progress", "notes": "Some designs available, need automation"}
        return {"status": "pending", "notes": "Product designs and automation needed"}

    def get_next_actions(self):
        """Generate list of next actions based on current status"""
        actions = []

        # Check what's pending and suggest actions
        if not self.check_payment_status()["status"] == "complete":
            actions.append("Complete PayPal and Stripe setup")

        if not self.check_product_status()["status"] == "complete":
            actions.append("Set up product design automation")

        if not self.check_banking_status()["status"] == "complete":
            actions.append("Follow up on Amex business account")

        return actions

    def generate_daily_report(self):
        """Generate daily business progress report"""
        status = self.update_business_status()

        report = f"""# FreshThreads Daily Business Report
Date: {datetime.now().strftime('%Y-%m-%d')}
Overall Progress: {status['completion_percentage']}%

## Status Overview
"""

        for category, info in status["business_setup"].items():
            emoji = "✅" if info["status"] == "complete" else "🔄" if info["status"] == "in_progress" else "⏳"
            report += f"- {emoji} **{category.title()}**: {info['status']} - {info['notes']}\n"

        report += f"\n## Next Actions\n"
        for action in status["next_actions"]:
            report += f"- [ ] {action}\n"

        report += f"\n## Quick Wins Available\n"
        report += "- Set up PayPal Business account\n"
        report += "- Configure Stripe payment processing\n"
        report += "- Test website payment integration\n"

        # Write report to file
        report_file = self.docs_dir / f"daily-report-{datetime.now().strftime('%Y%m%d')}.md"
        with open(report_file, 'w') as f:
            f.write(report)

        self.log(f"✅ Daily report generated: {report_file}")
        return report

def main():
    docs = BusinessDocsAutomation()

    print("=== Business Documentation Automation ===")
    print("1. Update business status")
    print("2. Generate daily report")
    print("3. Full documentation update")

    choice = input("Select option (1-3): ").strip()

    if choice == "1":
        docs.update_business_status()
    elif choice == "2":
        docs.generate_daily_report()
    elif choice == "3":
        docs.update_business_status()
        docs.generate_daily_report()
        print("✅ Full documentation update completed!")
    else:
        print("Invalid option")

if __name__ == "__main__":
    main()
EOF

    log "✅ Documentation automation scripts created"
}

# Function to create master automation controller
create_master_controller() {
    log "Creating master automation controller..."

    cat > scripts/master-automation.py << 'EOF'
"""
Master Business Automation Controller
Central hub for all FreshThreads business automation tasks
"""

import subprocess
import sys
import os
from datetime import datetime

class MasterAutomation:
    def __init__(self):
        self.scripts_dir = os.path.dirname(os.path.abspath(__file__))

    def log(self, message):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

    def run_script(self, script_name, description):
        """Run a Python script and handle errors"""
        self.log(f"Starting: {description}")
        try:
            result = subprocess.run([sys.executable, script_name],
                                  cwd=self.scripts_dir,
                                  capture_output=True,
                                  text=True)

            if result.returncode == 0:
                self.log(f"✅ Completed: {description}")
                if result.stdout:
                    print(result.stdout)
                return True
            else:
                self.log(f"❌ Failed: {description}")
                if result.stderr:
                    print(result.stderr)
                return False

        except Exception as e:
            self.log(f"❌ Error running {script_name}: {e}")
            return False

    def full_business_setup(self):
        """Run complete business setup automation"""
        self.log("=== Starting Full Business Setup Automation ===")

        tasks = [
            ("business-docs-automation.py", "Business documentation update"),
            ("paypal-automation.py", "PayPal setup"),
            ("stripe-automation.py", "Stripe setup"),
        ]

        completed = 0
        for script, description in tasks:
            if self.run_script(script, description):
                completed += 1

        self.log(f"=== Business Setup Complete: {completed}/{len(tasks)} tasks successful ===")

        if completed == len(tasks):
            self.log("🎉 All automation tasks completed successfully!")
        else:
            self.log(f"⚠️  {len(tasks) - completed} tasks failed - check logs above")

    def quick_status_check(self):
        """Quick business status check"""
        self.log("=== Quick Business Status Check ===")
        self.run_script("business-docs-automation.py", "Status update")

    def payment_setup_only(self):
        """Set up only payment processing"""
        self.log("=== Payment Processing Setup ===")
        self.run_script("paypal-automation.py", "PayPal setup")
        self.run_script("stripe-automation.py", "Stripe setup")

def main():
    automation = MasterAutomation()

    print("=== FreshThreads Master Business Automation ===")
    print("1. Full business setup (all automation)")
    print("2. Quick status check")
    print("3. Payment setup only")
    print("4. Documentation update only")

    choice = input("Select option (1-4): ").strip()

    if choice == "1":
        automation.full_business_setup()
    elif choice == "2":
        automation.quick_status_check()
    elif choice == "3":
        automation.payment_setup_only()
    elif choice == "4":
        automation.run_script("business-docs-automation.py", "Documentation update")
    else:
        print("Invalid option")

if __name__ == "__main__":
    main()
EOF

    chmod +x scripts/master-automation.py
    log "✅ Master automation controller created"
}

# Function to create environment template
create_env_template() {
    log "Creating environment configuration template..."

    cat > .env.template << 'EOF'
# FreshThreads LLC - Environment Configuration Template
# Copy this to .env and fill in your actual values

# === Aikido Security (Already configured) ===
AIKIDO_TOKEN=your_existing_token
AIKIDO_BLOCK=true
AIKIDO_DEBUG=false
AIKIDO_CONFIG_PATH=./aikido.json
REPO_ID=891693

# === Banking & Finance ===
AMEX_ACCOUNT_NUMBER=
BANK_ROUTING_NUMBER=
BUSINESS_EIN=

# === Payment Processing ===
# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# PayPal
PAYPAL_CLIENT_ID=
PAYPAL_CLIENT_SECRET=
PAYPAL_WEBHOOK_ID=
PAYPAL_SANDBOX=true

# === Business Information ===
BUSINESS_NAME=FreshThreads LLC
BUSINESS_EMAIL=bryan@freshthreadsllc.com
BUSINESS_PHONE=
BUSINESS_ADDRESS=

# === Microsoft 365 ===
M365_TENANT_ID=
M365_CLIENT_ID=
M365_CLIENT_SECRET=

# === Website & Analytics ===
WEBSITE_URL=https://freshthreads.xyz
GOOGLE_ANALYTICS_ID=
FACEBOOK_PIXEL_ID=

# === Product & Inventory ===
PRINTIFY_API_KEY=
SHOPIFY_API_KEY=
SHOPIFY_API_SECRET=

# === Development ===
NODE_ENV=development
DEBUG=true
LOG_LEVEL=info
EOF

    log "✅ Environment template created"
}

# Main execution
main() {
    log "Starting FreshThreads Business Automation Suite..."

    check_prerequisites
    setup_m365_automation
    setup_paypal_automation
    setup_stripe_automation
    setup_documentation_automation
    create_master_controller
    create_env_template

    log "=== Automation Suite Setup Complete! ==="
    log ""
    log "🚀 Quick Start Commands:"
    log "  1. Run master automation:    python3 scripts/master-automation.py"
    log "  2. Check business status:    python3 scripts/business-docs-automation.py"
    log "  3. Setup PayPal:            python3 scripts/paypal-automation.py"
    log "  4. Setup Stripe:            python3 scripts/stripe-automation.py"
    log "  5. M365 email automation:   pwsh scripts/m365-alias-automation.ps1"
    log ""
    log "📋 Next Steps:"
    log "  1. Copy .env.template to .env and fill in your API keys"
    log "  2. Run: python3 scripts/master-automation.py"
    log "  3. Follow the prompts to complete your business setup"
    log ""
    log "📊 All activities are logged and documented automatically!"
}

# Run main function
main
