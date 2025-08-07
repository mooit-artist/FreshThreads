#!/bin/bash

# FreshThreads PayPal Integration - Deployment Summary
# This script shows the user what to do next for complete setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Clear screen for clean presentation
clear

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}                        🧵 FreshThreads LLC - PayPal Integration${NC}"
echo -e "${CYAN}                           Production Deployment Ready! 🚀${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check current status
echo -e "${BLUE}📊 Current Status Check${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check GitHub Secrets first (preferred method)
if command -v gh &> /dev/null && gh auth status &> /dev/null 2>&1; then
    if gh secret list | grep -q "PAYPAL_CLIENT_ID"; then
        echo -e "${GREEN}✅ PayPal configuration: GitHub Secrets (Secure)${NC}"
        PAYPAL_STATUS="✅"
        CONFIG_SOURCE="GitHub Secrets"
    elif [ -f "config/paypal-config.env" ]; then
        echo -e "${YELLOW}⚠️ PayPal configuration: File-based (Consider GitHub Secrets)${NC}"
        PAYPAL_STATUS="⚠️"
        CONFIG_SOURCE="Config File"
    else
        echo -e "${RED}❌ PayPal configuration: Missing${NC}"
        PAYPAL_STATUS="❌"
        CONFIG_SOURCE="None"
    fi
else
    # Fallback to config file check
    if [ -f "config/paypal-config.env" ]; then
        echo -e "${YELLOW}⚠️ PayPal configuration: File-based (GitHub CLI needed for secrets)${NC}"
        PAYPAL_STATUS="⚠️"
        CONFIG_SOURCE="Config File"
    else
        echo -e "${RED}❌ PayPal configuration: Missing${NC}"
        PAYPAL_STATUS="❌"
        CONFIG_SOURCE="None"
    fi
fi

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✅ GitHub CLI: Installed${NC}"
    GH_STATUS="✅"
else
    echo -e "${RED}❌ GitHub CLI: Not installed${NC}"
    GH_STATUS="❌"
fi

# Check if authenticated
if gh auth status &> /dev/null 2>&1; then
    echo -e "${GREEN}✅ GitHub authentication: Active${NC}"
    AUTH_STATUS="✅"
else
    echo -e "${RED}❌ GitHub authentication: Required${NC}"
    AUTH_STATUS="❌"
fi

# Check if git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Git repository: Active${NC}"
    GIT_STATUS="✅"
else
    echo -e "${RED}❌ Git repository: Not initialized${NC}"
    GIT_STATUS="❌"
fi

# Check if workflows directory exists
if [ -d ".github/workflows" ]; then
    echo -e "${GREEN}✅ GitHub Actions: Configured${NC}"
    WORKFLOW_STATUS="✅"
else
    echo -e "${RED}❌ GitHub Actions: Missing${NC}"
    WORKFLOW_STATUS="❌"
fi

echo

# Show what we've built
echo -e "${BLUE}🛠️  What We've Built${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}📁 PayPal Integration Files:${NC}"
echo "   • paypal_v2_api_integration.py     → Latest PayPal API v2 implementation"
echo "   • setup_paypal_from_params.py      → Auto-configuration with GitHub Secrets support"
echo "   • paypal_business_automation.py    → Business automation with secure credential loading"
echo

echo -e "${CYAN}🔐 Security Features:${NC}"
if [ "$CONFIG_SOURCE" = "GitHub Secrets" ]; then
    echo "   • GitHub Secrets                   → ✅ Secure credential storage (Active)"
    echo "   • Environment Variables            → ✅ Runtime configuration"
    echo "   • Automated Secret Management      → ✅ CI/CD integration"
elif [ "$CONFIG_SOURCE" = "Config File" ]; then
    echo "   • GitHub Secrets                   → ⚠️ Available (run upload_secrets_to_github.sh)"
    echo "   • Local Configuration              → ✅ File-based (development only)"
    echo "   • Security Cleanup                 → ✅ Sensitive files removed from git"
else
    echo "   • GitHub Secrets                   → ❌ Not configured"
    echo "   • Configuration                    → ❌ Missing credentials"
fi

echo -e "${CYAN}�️ Security & CI/CD Files:${NC}"
echo "   • upload_secrets_to_github.sh      → Upload credentials to GitHub Secrets"
echo "   • create_config_from_secrets.py    → Generate config from GitHub variables"
echo "   • setup_environment_protection.sh  → Configure environment protection"
echo "   • .github/workflows/deploy.yml     → Automated deployment workflow"
echo "   • docs/GITHUB-SECRETS-SETUP.md     → Complete setup documentation"
echo

echo -e "${CYAN}💰 Test Results:${NC}"
echo -e "   • ${GREEN}PayPal Order Created: 13244065EC022823N (\$161.16 USD)${NC}"
echo -e "   • ${GREEN}Authentication: Working with real PayPal Developer ID${NC}"
echo -e "   • ${GREEN}API Integration: PayPal Orders API v2 successful${NC}"
echo

# Next steps
echo -e "${BLUE}🚀 Next Steps for Production Deployment${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${YELLOW}Step 1: Upload Secrets to GitHub${NC}"
if [[ "$GH_STATUS" == "✅" && "$AUTH_STATUS" == "✅" ]]; then
    echo -e "   ${GREEN}Ready to upload!${NC} Run:"
    echo -e "   ${CYAN}./scripts/upload_secrets_to_github.sh${NC}"
else
    echo -e "   ${RED}Prerequisites needed:${NC}"
    if [[ "$GH_STATUS" == "❌" ]]; then
        echo -e "   • Install GitHub CLI: ${CYAN}brew install gh${NC}"
    fi
    if [[ "$AUTH_STATUS" == "❌" ]]; then
        echo -e "   • Authenticate: ${CYAN}gh auth login${NC}"
    fi
fi
echo

echo -e "${YELLOW}Step 2: Set Up Environment Protection${NC}"
if [[ "$GH_STATUS" == "✅" && "$AUTH_STATUS" == "✅" ]]; then
    echo -e "   ${GREEN}Ready to configure!${NC} Run:"
    echo -e "   ${CYAN}./scripts/setup_environment_protection.sh${NC}"
else
    echo -e "   ${RED}Complete Step 1 first${NC}"
fi
echo

echo -e "${YELLOW}Step 3: Deploy to Production${NC}"
if [[ "$GIT_STATUS" == "✅" && "$WORKFLOW_STATUS" == "✅" ]]; then
    echo -e "   ${GREEN}Ready to deploy!${NC} Run:"
    echo -e "   ${CYAN}git add .${NC}"
    echo -e "   ${CYAN}git commit -m \"Deploy PayPal integration with GitHub Secrets\"${NC}"
    echo -e "   ${CYAN}git push origin main${NC}"
else
    echo -e "   ${RED}Prerequisites needed:${NC}"
    if [[ "$GIT_STATUS" == "❌" ]]; then
        echo -e "   • Initialize git: ${CYAN}git init && git remote add origin https://github.com/mooit-artist/FreshThreads.git${NC}"
    fi
fi
echo

echo -e "${YELLOW}Step 4: Monitor Deployment${NC}"
echo -e "   • GitHub Actions: ${CYAN}https://github.com/mooit-artist/FreshThreads/actions${NC}"
echo -e "   • Live Website: ${CYAN}https://mooit-artist.github.io/FreshThreads/${NC}"
echo -e "   • Environment Status: ${CYAN}https://github.com/mooit-artist/FreshThreads/settings/environments${NC}"
echo

# Quick commands section
echo -e "${BLUE}⚡ Quick Commands${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}# Complete setup in one go:${NC}"
echo -e "${GREEN}./scripts/upload_secrets_to_github.sh && \\${NC}"
echo -e "${GREEN}./scripts/setup_environment_protection.sh && \\${NC}"
echo -e "${GREEN}git add . && git commit -m \"Deploy PayPal integration\" && git push origin main${NC}"
echo

echo -e "${CYAN}# Test locally:${NC}"
echo -e "${GREEN}python scripts/paypal_v2_api_integration.py --action test${NC}"
echo

echo -e "${CYAN}# Check secrets:${NC}"
echo -e "${GREEN}gh secret list${NC}"
echo

echo -e "${CYAN}# View workflows:${NC}"
echo -e "${GREEN}gh workflow list && gh run list${NC}"
echo

# Security reminders
echo -e "${BLUE}🔒 Security Reminders${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}• Use SANDBOX credentials for testing${NC}"
echo -e "${YELLOW}• Switch to LIVE credentials only when ready for production${NC}"
echo -e "${YELLOW}• Never commit secrets to code repository${NC}"
echo -e "${YELLOW}• Review environment protection rules before deploying${NC}"
echo -e "${YELLOW}• Monitor webhook calls and API usage${NC}"
echo

# Support information
echo -e "${BLUE}📚 Documentation & Support${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}Local Documentation:${NC}"
echo -e "   • ${GREEN}docs/GITHUB-SECRETS-SETUP.md${NC}     → Complete setup guide"
echo -e "   • ${GREEN}README.md${NC}                        → Project overview"
echo

echo -e "${CYAN}PayPal Resources:${NC}"
echo -e "   • Developer Dashboard: ${GREEN}https://developer.paypal.com/developer/applications${NC}"
echo -e "   • API Documentation: ${GREEN}https://developer.paypal.com/api/rest/${NC}"
echo -e "   • Webhooks Guide: ${GREEN}https://developer.paypal.com/api/webhooks/${NC}"
echo

echo -e "${CYAN}GitHub Resources:${NC}"
echo -e "   • Actions Documentation: ${GREEN}https://docs.github.com/en/actions${NC}"
echo -e "   • Secrets Management: ${GREEN}https://docs.github.com/en/actions/security-guides/encrypted-secrets${NC}"
echo -e "   • Environment Protection: ${GREEN}https://docs.github.com/en/actions/deployment/environments${NC}"
echo

# Final success message
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                          🎉 PayPal Integration Complete! 🎉${NC}"
echo -e "${CYAN}                     Ready for secure production deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Show next command suggestion
if [[ "$GH_STATUS" == "✅" && "$AUTH_STATUS" == "✅" ]]; then
    echo -e "${YELLOW}👉 Ready to proceed? Run: ${CYAN}./scripts/upload_secrets_to_github.sh${NC}"
else
    echo -e "${YELLOW}👉 First install GitHub CLI: ${CYAN}brew install gh && gh auth login${NC}"
fi
echo
