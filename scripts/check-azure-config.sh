#!/bin/bash
# Quick Azure App Registration Checker
# Checks current config and suggests next steps

echo "=== Azure App Registration Checker ==="
echo "Date: $(date)"
echo ""

# Check current configuration
echo "Current O365 Configuration:"
echo "=========================="
if [ -f "config/o365-config.env" ]; then
    echo "📄 Config file found: config/o365-config.env"
    echo ""

    # Show current values (masked)
    CLIENT_ID=$(grep "O365_CLIENT_ID=" config/o365-config.env | cut -d'=' -f2)
    TENANT_ID=$(grep "O365_TENANT_ID=" config/o365-config.env | cut -d'=' -f2)
    CLIENT_SECRET=$(grep "O365_CLIENT_SECRET=" config/o365-config.env | cut -d'=' -f2)

    echo "Client ID: ${CLIENT_ID:0:8}...${CLIENT_ID: -4}" 2>/dev/null || echo "Client ID: [Not set]"
    echo "Tenant ID: ${TENANT_ID:0:8}...${TENANT_ID: -4}" 2>/dev/null || echo "Tenant ID: [Not set]"
    echo "Client Secret: ${CLIENT_SECRET:0:4}..." 2>/dev/null || echo "Client Secret: [Not set]"
    echo ""
else
    echo "❌ Config file not found: config/o365-config.env"
    echo ""
fi

# Test current configuration
echo "Testing Current Configuration:"
echo "============================"
echo "🔍 Testing O365 email handler..."

# Activate virtual environment and test
if [ -d ".venv" ]; then
    source .venv/bin/activate
    python scripts/o365_email_handler.py test 2>&1 | while read line; do
        if [[ $line == *"✓"* ]]; then
            echo "✅ $line"
        elif [[ $line == *"✗"* ]] || [[ $line == *"ERROR"* ]]; then
            echo "❌ $line"
        else
            echo "ℹ️  $line"
        fi
    done
else
    echo "❌ Virtual environment not found"
fi

echo ""
echo "Next Steps:"
echo "==========="
echo "1. 🔍 Run PowerShell script to find your Azure app registrations:"
echo "   pwsh scripts/find-azure-apps.ps1"
echo ""
echo "2. 🔧 If no apps found, create a new one:"
echo "   - Go to: https://portal.azure.com"
echo "   - Navigate: Azure Active Directory > App registrations"
echo "   - Click: New registration"
echo ""
echo "3. 📝 Update config with correct credentials:"
echo "   vim config/o365-config.env"
echo ""
echo "4. 🧪 Test the updated configuration:"
echo "   python scripts/o365_email_handler.py test"
echo "   python scripts/o365_email_handler.py send"
