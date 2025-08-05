#!/bin/bash

# 📧 Fresh Threads LLC - Email Alias Automation Script
# This script sets up all business email aliases in Microsoft 365
# Author: Fresh Threads LLC
# Requirements: Microsoft Graph PowerShell module

echo "🚀 Fresh Threads LLC - Email Alias Setup Script"
echo "================================================"
echo "Setting up professional email aliases for freshthreadsllc.com"
echo ""

# Configuration
DOMAIN="freshthreadsllc.com"
PRIMARY_USER="bryan@freshthreadsllc.com"
USER_PRINCIPAL_NAME="bryan@freshthreadsllc.com"

# Check if running on macOS (for cross-platform compatibility)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ Detected macOS - proceeding with setup"
else
    echo "⚠️  Script optimized for macOS but should work on other platforms"
fi

echo ""
echo "📋 Phase 1: Essential Business Aliases"
echo "======================================"

# Phase 1: Essential aliases
PHASE1_ALIASES=(
    "info@${DOMAIN}:General inquiries, first contact"
    "support@${DOMAIN}:Customer service, order issues"
    "orders@${DOMAIN}:Order confirmations, shipping updates"
    "procurement@${DOMAIN}:Supplier communications, vendor management"
)

echo "Phase 1 aliases to create:"
for alias in "${PHASE1_ALIASES[@]}"; do
    email=$(echo $alias | cut -d':' -f1)
    description=$(echo $alias | cut -d':' -f2)
    echo "  • $email - $description"
done

echo ""
echo "📋 Phase 2: Business Growth Aliases"
echo "=================================="

# Phase 2: Business growth aliases
PHASE2_ALIASES=(
    "sales@${DOMAIN}:Sales inquiries, bulk orders"
    "marketing@${DOMAIN}:Partnerships, influencer outreach"
    "billing@${DOMAIN}:Payment issues, invoicing"
    "admin@${DOMAIN}:Administrative tasks, legal notices"
    "returns@${DOMAIN}:Return requests, exchanges"
    "accounting@${DOMAIN}:Financial records, tax documents"
)

echo "Phase 2 aliases to create:"
for alias in "${PHASE2_ALIASES[@]}"; do
    email=$(echo $alias | cut -d':' -f1)
    description=$(echo $alias | cut -d':' -f2)
    echo "  • $email - $description"
done

echo ""
echo "📋 Phase 3: Professional Polish Aliases"
echo "======================================="

# Phase 3: Professional polish aliases
PHASE3_ALIASES=(
    "press@${DOMAIN}:Media inquiries, PR opportunities"
    "partnerships@${DOMAIN}:Business collaborations"
    "legal@${DOMAIN}:Legal inquiries, DMCA notices"
    "privacy@${DOMAIN}:Privacy policy, GDPR requests"
    "security@${DOMAIN}:Security reports, data breaches"
    "design@${DOMAIN}:Design submissions, creative feedback"
    "creative@${DOMAIN}:Creative partnerships, artist collaborations"
    "submissions@${DOMAIN}:Design contest entries"
    "inventory@${DOMAIN}:Stock management, supplier updates"
    "shipping@${DOMAIN}:Fulfillment, logistics"
    "quality@${DOMAIN}:Quality control, product feedback"
    "affiliate@${DOMAIN}:Affiliate program inquiries"
)

echo "Phase 3 aliases to create:"
for alias in "${PHASE3_ALIASES[@]}"; do
    email=$(echo $alias | cut -d':' -f1)
    description=$(echo $alias | cut -d':' -f2)
    echo "  • $email - $description"
done

echo ""
echo "🔧 Setup Options:"
echo "1) Install Microsoft Graph PowerShell and create PowerShell script"
echo "2) Generate manual setup commands for Microsoft 365 Admin Center"
echo "3) Create CSV file for bulk import"
echo "4) Exit"
echo ""

read -p "Choose option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🔧 Creating PowerShell Script for Microsoft Graph..."
        ./m365tools/scripts/create-m365-powershell-script.sh
        ;;
    2)
        echo ""
        echo "📋 Generating Manual Setup Instructions..."
        ./m365tools/scripts/create-manual-setup-guide.sh
        ;;
    3)
        echo ""
        echo "📊 Creating CSV for Bulk Import..."
        ./m365tools/scripts/create-csv-import.sh
        ;;
    4)
        echo "👋 Exiting setup. Run script again when ready!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option. Please run script again and choose 1-4."
        exit 1
        ;;
esac

echo ""
echo "✅ Fresh Threads LLC Email Alias Setup Complete!"
echo "================================================"
echo ""
echo "📧 Next Steps:"
echo "1. Test sending/receiving from each alias"
echo "2. Set up professional signatures for each department"
echo "3. Configure Outlook rules for auto-organization"
echo "4. Update website contact forms with new aliases"
echo "5. Add aliases to business cards and marketing materials"
echo ""
echo "🏢 Your business now looks professional and organized!"
echo "Ready to impress customers, suppliers, and partners! 🚀"
