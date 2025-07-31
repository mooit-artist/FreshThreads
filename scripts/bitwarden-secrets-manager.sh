#!/bin/bash
# Enhanced GitHub Secrets Management with Bitwarden CLI
# Securely manage FreshThreads CI/CD secrets using Bitwarden vault

set -e

echo "🔐 FreshThreads Secrets Manager with Bitwarden"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Bitwarden organization/collection settings
BW_ORG_ID=""  # Set your organization ID if using Bitwarden Business
BW_COLLECTION_ID=""  # Set collection ID for team sharing

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
echo "Checking dependencies..."
if ! command_exists bw; then
    echo -e "${RED}❌ Bitwarden CLI (bw) is required but not installed.${NC}"
    echo "Install with: brew install bitwarden-cli"
    exit 1
fi

if ! command_exists gh; then
    echo -e "${RED}❌ GitHub CLI (gh) is required but not installed.${NC}"
    echo "Install with: brew install gh"
    exit 1
fi

if ! command_exists jq; then
    echo -e "${RED}❌ jq is required but not installed.${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies check passed${NC}"
echo ""

# Bitwarden authentication
authenticate_bitwarden() {
    echo -e "${BLUE}🔐 Bitwarden Authentication${NC}"

    # Check if already logged in
    if bw status | jq -r .status | grep -q "unlocked"; then
        echo -e "${GREEN}✅ Already authenticated with Bitwarden${NC}"
        return 0
    fi

    # Login if needed
    if bw status | jq -r .status | grep -q "unauthenticated"; then
        echo "Please login to Bitwarden:"
        bw login
    fi

    # Unlock vault
    echo "Unlocking Bitwarden vault..."
    BW_SESSION=$(bw unlock --raw)
    export BW_SESSION

    if [ -n "$BW_SESSION" ]; then
        echo -e "${GREEN}✅ Bitwarden vault unlocked${NC}"
    else
        echo -e "${RED}❌ Failed to unlock Bitwarden vault${NC}"
        exit 1
    fi
}

# GitHub CLI authentication
authenticate_github() {
    echo -e "${BLUE}🐙 GitHub Authentication${NC}"

    if ! gh auth status >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ Not authenticated with GitHub CLI${NC}"
        echo "Please run: gh auth login"
        exit 1
    fi

    echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"
}

# Store secret in Bitwarden
store_secret_in_bitwarden() {
    local name="$1"
    local value="$2"
    local notes="$3"

    # Create secure note template
    local template=$(cat << EOF
{
  "organizationId": "$BW_ORG_ID",
  "collectionIds": ["$BW_COLLECTION_ID"],
  "type": 2,
  "name": "FreshThreads-$name",
  "notes": "$notes",
  "secureNote": {
    "type": 0
  },
  "fields": [
    {
      "name": "Secret Value",
      "value": "$value",
      "type": 1
    },
    {
      "name": "Service",
      "value": "GitHub Actions",
      "type": 0
    },
    {
      "name": "Repository",
      "value": "mooit-artist/FreshThreads",
      "type": 0
    },
    {
      "name": "Last Updated",
      "value": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")",
      "type": 0
    }
  ]
}
EOF
    )

    # Store in Bitwarden
    echo "$template" | bw create item --session "$BW_SESSION" >/dev/null
    echo -e "${GREEN}✅ Secret '$name' stored in Bitwarden${NC}"
}

# Retrieve secret from Bitwarden
get_secret_from_bitwarden() {
    local name="$1"

    # Search for the item
    local item_id=$(bw list items --search "FreshThreads-$name" --session "$BW_SESSION" | jq -r '.[0].id // empty')

    if [ -z "$item_id" ]; then
        echo -e "${RED}❌ Secret '$name' not found in Bitwarden${NC}"
        return 1
    fi

    # Get the secret value
    local secret_value=$(bw get item "$item_id" --session "$BW_SESSION" | jq -r '.fields[] | select(.name=="Secret Value") | .value')
    echo "$secret_value"
}

# Setup Docker Hub secrets
setup_docker_secrets() {
    echo -e "${YELLOW}🐳 Docker Hub Secrets Setup${NC}"

    # Check if secrets exist in Bitwarden
    docker_username=$(get_secret_from_bitwarden "DOCKER_USERNAME" 2>/dev/null || true)
    docker_password=$(get_secret_from_bitwarden "DOCKER_PASSWORD" 2>/dev/null || true)

    if [ -z "$docker_username" ]; then
        echo "Enter Docker Hub credentials:"
        read -p "Docker Hub Username: " docker_username
        store_secret_in_bitwarden "DOCKER_USERNAME" "$docker_username" "Docker Hub username for FreshThreads CI/CD"
    fi

    if [ -z "$docker_password" ]; then
        echo "Generate a Personal Access Token at: https://hub.docker.com/settings/security"
        read -s -p "Docker Hub Token: " docker_password
        echo ""
        store_secret_in_bitwarden "DOCKER_PASSWORD" "$docker_password" "Docker Hub Personal Access Token for FreshThreads CI/CD"
    fi

    # Update GitHub secrets
    echo "Updating GitHub secrets..."
    echo "$docker_username" | gh secret set DOCKER_USERNAME
    echo "$docker_password" | gh secret set DOCKER_PASSWORD

    echo -e "${GREEN}✅ Docker Hub secrets configured${NC}"
}

# Setup SonarQube secrets
setup_sonarqube_secrets() {
    echo -e "${YELLOW}📊 SonarQube Secrets Setup${NC}"

    # Check if secrets exist in Bitwarden
    sonar_token=$(get_secret_from_bitwarden "SONAR_TOKEN" 2>/dev/null || true)
    sonar_host=$(get_secret_from_bitwarden "SONAR_HOST_URL" 2>/dev/null || true)

    if [ -z "$sonar_token" ]; then
        echo "Generate a User Token at: http://localhost:9000"
        echo "Go to: My Account → Security → Generate Token"
        read -s -p "SonarQube Token: " sonar_token
        echo ""
        store_secret_in_bitwarden "SONAR_TOKEN" "$sonar_token" "SonarQube User Token for FreshThreads CI/CD"
    fi

    if [ -z "$sonar_host" ]; then
        read -p "SonarQube Host URL [http://localhost:9000]: " sonar_host
        sonar_host=${sonar_host:-http://localhost:9000}
        store_secret_in_bitwarden "SONAR_HOST_URL" "$sonar_host" "SonarQube server URL for FreshThreads CI/CD"
    fi

    # Update GitHub secrets
    echo "Updating GitHub secrets..."
    echo "$sonar_token" | gh secret set SONAR_TOKEN
    echo "$sonar_host" | gh secret set SONAR_HOST_URL

    echo -e "${GREEN}✅ SonarQube secrets configured${NC}"
}

# Setup Slack webhook
setup_slack_secrets() {
    echo -e "${YELLOW}💬 Slack Webhook Setup${NC}"

    # Check if secret exists in Bitwarden
    slack_webhook=$(get_secret_from_bitwarden "SLACK_WEBHOOK" 2>/dev/null || true)

    if [ -z "$slack_webhook" ]; then
        echo "Create a Slack App and get webhook URL:"
        echo "https://api.slack.com/apps → Your App → Incoming Webhooks"
        read -p "Slack Webhook URL: " slack_webhook
        store_secret_in_bitwarden "SLACK_WEBHOOK" "$slack_webhook" "Slack webhook URL for FreshThreads security alerts"
    fi

    # Update GitHub secret
    echo "Updating GitHub secret..."
    echo "$slack_webhook" | gh secret set SLACK_WEBHOOK

    echo -e "${GREEN}✅ Slack webhook configured${NC}"
}

# Sync all secrets from Bitwarden to GitHub
sync_secrets() {
    echo -e "${YELLOW}🔄 Syncing secrets from Bitwarden to GitHub${NC}"

    # Sync Bitwarden vault
    bw sync --session "$BW_SESSION"

    # Get all FreshThreads secrets
    local secrets=(
        "DOCKER_USERNAME"
        "DOCKER_PASSWORD"
        "SONAR_TOKEN"
        "SONAR_HOST_URL"
        "SLACK_WEBHOOK"
    )

    for secret in "${secrets[@]}"; do
        local value=$(get_secret_from_bitwarden "$secret" 2>/dev/null || true)
        if [ -n "$value" ]; then
            echo "$value" | gh secret set "$secret"
            echo -e "${GREEN}✅ Synced $secret${NC}"
        else
            echo -e "${YELLOW}⚠️ $secret not found in Bitwarden${NC}"
        fi
    done

    echo -e "${GREEN}🎉 All secrets synced successfully${NC}"
}

# List secrets from Bitwarden
list_secrets() {
    echo -e "${BLUE}📋 FreshThreads Secrets in Bitwarden${NC}"
    echo "======================================"

    bw list items --search "FreshThreads-" --session "$BW_SESSION" | jq -r '.[] | "\(.name) (Updated: \(.revisionDate[:10]))"'
}

# Rotate secrets
rotate_secrets() {
    echo -e "${YELLOW}🔄 Rotating Secrets${NC}"

    # Get current secrets
    local secrets_to_rotate=(
        "DOCKER_PASSWORD"
        "SONAR_TOKEN"
        "SLACK_WEBHOOK"
    )

    for secret in "${secrets_to_rotate[@]}"; do
        echo ""
        echo -e "${BLUE}Rotating $secret...${NC}"

        case $secret in
            "DOCKER_PASSWORD")
                echo "1. Go to https://hub.docker.com/settings/security"
                echo "2. Revoke old token and generate new one"
                read -s -p "Enter new Docker Hub token: " new_value
                ;;
            "SONAR_TOKEN")
                echo "1. Go to http://localhost:9000"
                echo "2. My Account → Security → Revoke old token → Generate new"
                read -s -p "Enter new SonarQube token: " new_value
                ;;
            "SLACK_WEBHOOK")
                echo "1. Go to your Slack App → Incoming Webhooks"
                echo "2. Regenerate webhook URL"
                read -p "Enter new Slack webhook URL: " new_value
                ;;
        esac

        echo ""

        # Update in Bitwarden
        local item_id=$(bw list items --search "FreshThreads-$secret" --session "$BW_SESSION" | jq -r '.[0].id // empty')
        if [ -n "$item_id" ]; then
            # Get current item
            local current_item=$(bw get item "$item_id" --session "$BW_SESSION")

            # Update the secret value field
            local updated_item=$(echo "$current_item" | jq --arg value "$new_value" '.fields[] |= if .name == "Secret Value" then .value = $value else . end')

            # Save updated item
            echo "$updated_item" | bw edit item "$item_id" --session "$BW_SESSION" >/dev/null
        fi

        # Update in GitHub
        echo "$new_value" | gh secret set "$secret"

        echo -e "${GREEN}✅ $secret rotated successfully${NC}"
    done
}

# Main menu
main_menu() {
    while true; do
        echo ""
        echo -e "${BLUE}🔐 FreshThreads Secrets Manager${NC}"
        echo "=============================="
        echo "1) Setup Docker Hub secrets"
        echo "2) Setup SonarQube secrets"
        echo "3) Setup Slack webhook"
        echo "4) Setup all secrets"
        echo "5) Sync secrets from Bitwarden to GitHub"
        echo "6) List secrets in Bitwarden"
        echo "7) Rotate secrets"
        echo "8) Exit"
        echo ""

        read -p "Select option (1-8): " choice

        case $choice in
            1) setup_docker_secrets ;;
            2) setup_sonarqube_secrets ;;
            3) setup_slack_secrets ;;
            4)
                setup_docker_secrets
                setup_sonarqube_secrets
                setup_slack_secrets
                ;;
            5) sync_secrets ;;
            6) list_secrets ;;
            7) rotate_secrets ;;
            8)
                echo "Exiting..."
                bw lock --session "$BW_SESSION" 2>/dev/null || true
                exit 0
                ;;
            *) echo -e "${RED}❌ Invalid option${NC}" ;;
        esac
    done
}

# Main execution
echo "Initializing Bitwarden Secrets Manager..."
authenticate_bitwarden
authenticate_github
main_menu
