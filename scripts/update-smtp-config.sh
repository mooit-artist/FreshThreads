#!/bin/bash
# Update SMTP Configuration with App Password
# Shell wrapper for updating the O365 config

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: App password is required${NC}"
    echo -e "${YELLOW}Usage: $0 <app_password>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 abcd-efgh-ijkl-mnop"
    exit 1
fi

APP_PASSWORD="$1"

echo -e "${BLUE}Updating SMTP Configuration${NC}"
echo "============================"

# Check if PowerShell is available
if command -v pwsh &> /dev/null; then
    echo -e "${YELLOW}Using PowerShell to update config...${NC}"
    pwsh -File "$(dirname "$0")/update-smtp-password.ps1" -Password "$APP_PASSWORD" -TestConnection
else
    echo -e "${YELLOW}PowerShell not available, updating config manually...${NC}"

    CONFIG_FILE="$(dirname "$0")/../config/o365-config.env"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: Config file not found: $CONFIG_FILE${NC}"
        exit 1
    fi

    # Update the password in the config file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/O365_SMTP_PASSWORD=.*/O365_SMTP_PASSWORD=$APP_PASSWORD/" "$CONFIG_FILE"
    else
        # Linux
        sed -i "s/O365_SMTP_PASSWORD=.*/O365_SMTP_PASSWORD=$APP_PASSWORD/" "$CONFIG_FILE"
    fi

    echo -e "${GREEN}✓ Configuration updated successfully${NC}"
fi

echo ""
echo -e "${GREEN}Configuration updated!${NC}"
echo ""
echo -e "${YELLOW}Test the email integration:${NC}"
echo "  python scripts/o365_email_handler.py test"
echo "  python scripts/o365_email_handler.py send"
echo ""
echo -e "${YELLOW}Start the contact API:${NC}"
echo "  python contact_api.py"
