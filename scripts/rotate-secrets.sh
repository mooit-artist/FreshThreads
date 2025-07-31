#!/bin/bash
# GitHub Secrets Rotation Helper Script
# Run this script quarterly to rotate secrets

set -e

echo "🔄 FreshThreads Secrets Rotation Helper"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
echo "Checking dependencies..."
if ! command_exists gh; then
    echo -e "${RED}❌ GitHub CLI (gh) is required but not installed.${NC}"
    echo "Install with: brew install gh"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${RED}❌ Docker is required but not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies check passed${NC}"
echo ""

# Authenticate with GitHub CLI
echo "Checking GitHub CLI authentication..."
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"
echo ""

# Function to rotate Docker Hub token
rotate_docker_secrets() {
    echo -e "${YELLOW}🐳 Docker Hub Token Rotation${NC}"
    echo "1. Go to https://hub.docker.com/settings/security"
    echo "2. Generate new Personal Access Token"
    echo "3. Copy the new token"
    echo ""

    read -p "Enter your Docker Hub username: " docker_username
    read -s -p "Enter your new Docker Hub token: " docker_token
    echo ""

    # Update GitHub secrets
    echo "Updating GitHub secrets..."
    echo "$docker_username" | gh secret set DOCKER_USERNAME
    echo "$docker_token" | gh secret set DOCKER_PASSWORD

    # Test Docker login
    echo "Testing Docker login..."
    if echo "$docker_token" | docker login --username "$docker_username" --password-stdin; then
        echo -e "${GREEN}✅ Docker secrets updated successfully${NC}"
    else
        echo -e "${RED}❌ Docker login test failed${NC}"
        return 1
    fi
}

# Function to rotate SonarQube token
rotate_sonarqube_secrets() {
    echo -e "${YELLOW}📊 SonarQube Token Rotation${NC}"
    echo "1. Go to http://localhost:9000"
    echo "2. Login and go to My Account → Security"
    echo "3. Revoke old token and generate new one"
    echo "4. Copy the new token"
    echo ""

    read -s -p "Enter your new SonarQube token: " sonar_token
    echo ""
    read -p "Enter SonarQube host URL [http://localhost:9000]: " sonar_host
    sonar_host=${sonar_host:-http://localhost:9000}

    # Update GitHub secrets
    echo "Updating GitHub secrets..."
    echo "$sonar_token" | gh secret set SONAR_TOKEN
    echo "$sonar_host" | gh secret set SONAR_HOST_URL

    # Test SonarQube connection
    echo "Testing SonarQube connection..."
    if curl -u "$sonar_token:" "$sonar_host/api/system/status" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SonarQube secrets updated successfully${NC}"
    else
        echo -e "${RED}❌ SonarQube connection test failed${NC}"
        return 1
    fi
}

# Function to rotate Slack webhook
rotate_slack_secrets() {
    echo -e "${YELLOW}💬 Slack Webhook Rotation${NC}"
    echo "1. Go to your Slack App management"
    echo "2. Regenerate webhook URL"
    echo "3. Copy the new webhook URL"
    echo ""

    read -p "Enter your new Slack webhook URL: " slack_webhook

    # Update GitHub secret
    echo "Updating GitHub secret..."
    echo "$slack_webhook" | gh secret set SLACK_WEBHOOK

    echo -e "${GREEN}✅ Slack webhook updated successfully${NC}"
}

# Function to backup current secret names
backup_secret_names() {
    echo -e "${YELLOW}📋 Backing up secret names${NC}"

    # Get list of secrets
    secrets_list=$(gh secret list --json name,updatedAt)

    # Save to backup file with timestamp
    backup_file="secrets-backup-$(date +%Y%m%d-%H%M%S).json"
    echo "$secrets_list" > "$backup_file"

    echo "Secret names backed up to: $backup_file"
    echo -e "${GREEN}✅ Secret names backup completed${NC}"
}

# Main menu
while true; do
    echo ""
    echo "Select rotation option:"
    echo "1) Rotate Docker Hub secrets"
    echo "2) Rotate SonarQube secrets"
    echo "3) Rotate Slack webhook"
    echo "4) Backup secret names"
    echo "5) Rotate all secrets"
    echo "6) Exit"
    echo ""

    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            rotate_docker_secrets
            ;;
        2)
            rotate_sonarqube_secrets
            ;;
        3)
            rotate_slack_secrets
            ;;
        4)
            backup_secret_names
            ;;
        5)
            echo "Rotating all secrets..."
            rotate_docker_secrets && \
            rotate_sonarqube_secrets && \
            rotate_slack_secrets && \
            backup_secret_names
            echo -e "${GREEN}✅ All secrets rotated successfully${NC}"
            ;;
        6)
            echo "Exiting..."
            break
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            ;;
    esac
done

echo ""
echo -e "${GREEN}🎉 Secrets rotation completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Update your password manager with new secret values"
echo "2. Test CI/CD pipeline to ensure secrets work"
echo "3. Schedule next rotation in 6 months"
echo "4. Update SECRETS-INVENTORY.md with rotation dates"
