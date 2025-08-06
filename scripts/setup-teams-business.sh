#!/bin/bash

# Quick Teams Business Setup Launcher
# FreshThreads LLC

echo "🚀 Microsoft Teams Business Setup for FreshThreads LLC"
echo "=================================================="

# Check if PowerShell is available
if ! command -v pwsh &> /dev/null; then
    echo "❌ PowerShell not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Installing PowerShell via Homebrew..."
        brew install --cask powershell
    else
        echo "Please install PowerShell manually for your OS"
        exit 1
    fi
fi

echo "✅ PowerShell found"
echo ""
echo "Starting Teams business setup..."
echo "This will:"
echo "  1. Connect to your Microsoft 365 tenant"
echo "  2. Configure your business user (bryan@freshthreadsllc.com)"
echo "  3. Set up Teams calling and phone features"
echo "  4. Configure business-appropriate policies"
echo "  5. Generate a configuration report"
echo ""

read -p "Continue with Teams setup? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Running Teams business setup..."
    pwsh scripts/teams-business-setup.ps1 -Action setup -BusinessEmail "bryan@freshthreadsllc.com"

    echo ""
    echo "✅ Teams setup completed!"
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Download Teams desktop app: https://teams.microsoft.com/downloads"
    echo "  2. Sign in with bryan@freshthreadsllc.com"
    echo "  3. Test calling features"
    echo "  4. Configure your business auto-attendant"
    echo ""
    echo "📊 Check the generated report in project-management/ folder"
else
    echo "Setup cancelled."
fi
