#!/bin/bash

# FreshThreads Security Validation Script
# Validates complete security infrastructure setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo -e "${BLUE}🔒 FreshThreads Security Infrastructure Validation${NC}"
echo "=============================================="
echo ""

# Function to check command availability
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}$1 is installed${NC}"
        return 0
    else
        echo -e "❌ ${RED}$1 is not installed${NC}"
        return 1
    fi
}

# Function to check file existence
check_file() {
    if [ -f "$1" ]; then
        echo -e "✅ ${GREEN}$1 exists${NC}"
        return 0
    else
        echo -e "❌ ${RED}$1 not found${NC}"
        return 1
    fi
}

# Function to check directory existence
check_directory() {
    if [ -d "$1" ]; then
        echo -e "✅ ${GREEN}$1 exists${NC}"
        return 0
    else
        echo -e "❌ ${RED}$1 not found${NC}"
        return 1
    fi
}

echo "🔍 Checking Security Tools Installation..."
echo "----------------------------------------"

# Check essential tools
TOOLS_OK=true
check_command "snyk" || TOOLS_OK=false
check_command "docker" || TOOLS_OK=false
check_command "git" || TOOLS_OK=false
check_command "npm" || TOOLS_OK=false

if [ "$TOOLS_OK" = true ]; then
    echo -e "✅ ${GREEN}All essential tools are installed${NC}"
else
    echo -e "⚠️ ${YELLOW}Some tools are missing - please install them${NC}"
fi

echo ""
echo "📁 Checking Configuration Files..."
echo "--------------------------------"

# Check configuration files
CONFIG_OK=true
check_file ".snyk" || CONFIG_OK=false
check_file "package.json" || CONFIG_OK=false
check_file ".gitignore" || CONFIG_OK=false
check_file "Makefile" || CONFIG_OK=false
check_file ".env.example" || CONFIG_OK=false

if [ "$CONFIG_OK" = true ]; then
    echo -e "✅ ${GREEN}All configuration files are present${NC}"
else
    echo -e "⚠️ ${YELLOW}Some configuration files are missing${NC}"
fi

echo ""
echo "🐳 Checking Docker Infrastructure..."
echo "----------------------------------"

# Check Docker files
DOCKER_OK=true
check_file "docker-compose.security-onion.yml" || DOCKER_OK=false
check_file "docker-compose.sonarqube.yml" || DOCKER_OK=false
check_file "Dockerfile" || DOCKER_OK=false

if [ "$DOCKER_OK" = true ]; then
    echo -e "✅ ${GREEN}Docker infrastructure is configured${NC}"
else
    echo -e "⚠️ ${YELLOW}Some Docker files are missing${NC}"
fi

echo ""
echo "🔐 Checking Secrets Management..."
echo "-------------------------------"

# Check secrets infrastructure
SECRETS_OK=true
check_file "scripts/bitwarden-secrets-manager.sh" || SECRETS_OK=false
check_directory ".github" || SECRETS_OK=false

if [ "$SECRETS_OK" = true ]; then
    echo -e "✅ ${GREEN}Secrets management is configured${NC}"
else
    echo -e "⚠️ ${YELLOW}Secrets management needs attention${NC}"
fi

echo ""
echo "🤖 Checking CI/CD Workflows..."
echo "----------------------------"

# Check GitHub Actions
CICD_OK=true
check_directory ".github/workflows" || CICD_OK=false
check_file ".github/workflows/security-comprehensive.yml" || CICD_OK=false

if [ "$CICD_OK" = true ]; then
    echo -e "✅ ${GREEN}CI/CD workflows are configured${NC}"
else
    echo -e "⚠️ ${YELLOW}CI/CD workflows need attention${NC}"
fi

echo ""
echo "🔍 Testing Snyk Authentication..."
echo "-------------------------------"

# Test Snyk authentication
if snyk config get api >/dev/null 2>&1; then
    echo -e "✅ ${GREEN}Snyk is authenticated${NC}"
    SNYK_AUTH=true
else
    echo -e "❌ ${RED}Snyk is not authenticated${NC}"
    SNYK_AUTH=false
fi

echo ""
echo "🧪 Running Security Tests..."
echo "---------------------------"

if [ "$SNYK_AUTH" = true ]; then
    echo "Running Snyk vulnerability scan..."
    if snyk test --severity-threshold=medium >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}No vulnerabilities detected${NC}"
        SECURITY_TEST=true
    else
        echo -e "⚠️ ${YELLOW}Vulnerabilities detected - check reports${NC}"
        SECURITY_TEST=false
    fi

    echo "Checking monitoring status..."
    if snyk monitor --dry-run >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}Monitoring is configured${NC}"
        MONITORING=true
    else
        echo -e "⚠️ ${YELLOW}Monitoring needs setup${NC}"
        MONITORING=false
    fi
else
    echo -e "⚠️ ${YELLOW}Skipping security tests - authentication required${NC}"
    SECURITY_TEST=false
    MONITORING=false
fi

echo ""
echo "📊 Security Infrastructure Summary"
echo "================================="

# Calculate overall status
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Count checks
[ "$TOOLS_OK" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$CONFIG_OK" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$DOCKER_OK" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$SECRETS_OK" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$CICD_OK" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$SNYK_AUTH" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$SECURITY_TEST" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

[ "$MONITORING" = true ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "Security Infrastructure Score: $PASSED_CHECKS/$TOTAL_CHECKS ($SCORE%)"
echo ""

if [ $SCORE -ge 90 ]; then
    echo -e "🎉 ${GREEN}EXCELLENT: Security infrastructure is fully operational!${NC}"
    OVERALL_STATUS="EXCELLENT"
elif [ $SCORE -ge 75 ]; then
    echo -e "👍 ${GREEN}GOOD: Security infrastructure is mostly ready${NC}"
    OVERALL_STATUS="GOOD"
elif [ $SCORE -ge 50 ]; then
    echo -e "⚠️ ${YELLOW}FAIR: Security infrastructure needs attention${NC}"
    OVERALL_STATUS="FAIR"
else
    echo -e "🚨 ${RED}POOR: Security infrastructure requires immediate action${NC}"
    OVERALL_STATUS="POOR"
fi

echo ""
echo "📋 Detailed Status:"
echo "- Tools Installation: $([ "$TOOLS_OK" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- Configuration Files: $([ "$CONFIG_OK" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- Docker Infrastructure: $([ "$DOCKER_OK" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- Secrets Management: $([ "$SECRETS_OK" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- CI/CD Workflows: $([ "$CICD_OK" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- Snyk Authentication: $([ "$SNYK_AUTH" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- Security Testing: $([ "$SECURITY_TEST" = true ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "- Monitoring: $([ "$MONITORING" = true ] && echo "✅ PASS" || echo "❌ FAIL")"

echo ""
echo "🔗 Quick Actions:"
if [ "$SNYK_AUTH" = false ]; then
    echo "  Run: make security-auth"
fi
if [ "$MONITORING" = false ]; then
    echo "  Run: make security-monitor"
fi
if [ "$SECURITY_TEST" = false ]; then
    echo "  Run: make security-test"
fi

echo ""
echo "📖 Documentation:"
echo "  - Security Configuration: SNYK-CONFIGURATION.md"
echo "  - Security Onion Setup: SECURITY-ONION-SETUP.md"
echo "  - SonarQube Upgrade: SONARQUBE-UPGRADE-SUMMARY.md"
echo "  - Security Policy: SECURITY.md"

echo ""
echo "🌐 Dashboard Links:"
echo "  - Snyk Dashboard: https://app.snyk.io/org/mooit-artist"
echo "  - GitHub Security: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]//g' | sed 's/.git$//g')/security"

echo ""
echo -e "${BLUE}Security validation completed with status: ${OVERALL_STATUS}${NC}"

# Exit with appropriate code
if [ $SCORE -ge 75 ]; then
    exit 0
else
    exit 1
fi
