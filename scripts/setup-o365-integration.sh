#!/bin/bash
# Office 365 Email Integration Setup Script
# Automates the installation and configuration of O365 email integration for FreshThreads

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="/Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads"

echo -e "${BLUE}FreshThreads O365 Email Integration Setup${NC}"
echo "============================================"

# Check if we're in the right directory
if [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
    echo -e "${RED}Error: Please run this script from the FreshThreads project root${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"

# Step 1: Create necessary directories
echo -e "${YELLOW}Step 1: Creating directories...${NC}"
mkdir -p logs
mkdir -p config
touch logs/o365_email.log
touch logs/contact_api.log
touch logs/contact_submissions.log
echo -e "${GREEN}✓ Directories created${NC}"

# Step 2: Check Python installation
echo -e "${YELLOW}Step 2: Checking Python installation...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is required but not installed${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"

# Step 3: Set up virtual environment (optional but recommended)
echo -e "${YELLOW}Step 3: Setting up Python virtual environment...${NC}"
if [[ ! -d ".venv" ]]; then
    python3 -m venv .venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi

# Activate virtual environment
source .venv/bin/activate
echo -e "${GREEN}✓ Virtual environment activated${NC}"

# Step 4: Install Python dependencies
echo -e "${YELLOW}Step 4: Installing Python dependencies...${NC}"
if [[ -f "config/requirements-o365.txt" ]]; then
    pip install -r config/requirements-o365.txt
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}Error: requirements-o365.txt not found${NC}"
    exit 1
fi

# Step 5: Copy configuration template
echo -e "${YELLOW}Step 5: Setting up configuration...${NC}"
if [[ -f "config/o365-config.env.template" ]]; then
    if [[ ! -f "config/o365-config.env" ]]; then
        cp config/o365-config.env.template config/o365-config.env
        echo -e "${GREEN}✓ Configuration template copied to config/o365-config.env${NC}"
        echo -e "${YELLOW}  Please edit this file with your O365 credentials${NC}"
    else
        echo -e "${GREEN}✓ Configuration file already exists${NC}"
    fi
else
    echo -e "${RED}Error: Configuration template not found${NC}"
    exit 1
fi

# Step 6: Test the installation
echo -e "${YELLOW}Step 6: Testing installation...${NC}"
if python3 scripts/o365_email_handler.py test > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Email handler script is working${NC}"
else
    echo -e "${YELLOW}⚠ Email handler test failed (this is expected if credentials aren't configured yet)${NC}"
fi

if python3 -c "import flask, flask_cors, msal, requests" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ All required Python packages are installed${NC}"
else
    echo -e "${RED}✗ Some Python packages are missing${NC}"
fi

# Step 7: Display next steps
echo ""
echo -e "${BLUE}Installation Complete!${NC}"
echo "======================"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Configure your O365 credentials in: config/o365-config.env"
echo "2. Follow the Azure setup guide in: docs/O365-INTEGRATION-GUIDE.md"
echo "3. Test your configuration with: python3 scripts/o365_email_handler.py test"
echo "4. Start the API server with: python3 contact_api.py"
echo ""
echo -e "${YELLOW}VS Code Tasks Available:${NC}"
echo "- Start O365 Contact API"
echo "- Test O365 Email Configuration"
echo "- Send Test Email"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo "# Activate virtual environment:"
echo "source .venv/bin/activate"
echo ""
echo "# Edit configuration:"
echo "nano config/o365-config.env"
echo ""
echo "# Test configuration:"
echo "python3 scripts/o365_email_handler.py test"
echo ""
echo "# Start API server:"
echo "python3 contact_api.py"
echo ""
echo -e "${GREEN}Setup complete! Check the integration guide for detailed configuration instructions.${NC}"
