#!/bin/bash
# Shell wrapper for Office 365 App Password Generation
# Runs PowerShell scripts on macOS for O365 automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Office 365 App Password Generator${NC}"
echo "=================================="

# Check if PowerShell is installed
if ! command -v pwsh &> /dev/null; then
    echo -e "${RED}Error: PowerShell Core (pwsh) is not installed${NC}"
    echo -e "${YELLOW}Install with: brew install --cask powershell${NC}"
    exit 1
fi

# Get user email (default to procurement)
USER_EMAIL=${1:-"procurement@freshthreadsllc.com"}

echo -e "${YELLOW}Setting up app password for: $USER_EMAIL${NC}"
echo ""

# Step 1: Generate app password setup
echo -e "${BLUE}Step 1: Setting up SMTP authentication and MFA...${NC}"
pwsh -File "$(dirname "$0")/generate-app-password.ps1" -UserEmail "$USER_EMAIL" -EnableSMTP

echo ""
echo -e "${GREEN}Setup completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Follow the manual instructions above to create an app password"
echo "2. Run this command with your app password:"
echo -e "   ${GREEN}./scripts/update-smtp-config.sh YOUR_APP_PASSWORD${NC}"
echo ""
echo -e "${BLUE}Alternative: Update config manually${NC}"
echo "Edit config/o365-config.env and set:"
echo "O365_SMTP_PASSWORD=your_app_password_here"
