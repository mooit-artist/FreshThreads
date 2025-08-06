#!/bin/bash

# Environment Protection Setup for GitHub Repository
# This script configures environment protection rules for secure PayPal integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-$(git config user.name)}"
REPO_NAME="${GITHUB_REPOSITORY_NAME:-$(basename "$(git rev-parse --show-toplevel)")}"
REPO_FULL_NAME="${REPO_OWNER}/${REPO_NAME}"

echo -e "${BLUE}🔐 Setting up Environment Protection for FreshThreads PayPal Integration${NC}"
echo "Repository: ${REPO_FULL_NAME}"
echo

# Check if GitHub CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Please install GitHub CLI: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI is not authenticated${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI is installed and authenticated${NC}"

# Function to create environment
create_environment() {
    local env_name=$1
    # Note: description parameter available for future use

    echo -e "${YELLOW}📝 Creating environment: ${env_name}${NC}"

    # Check if environment already exists
    if gh api "repos/${REPO_FULL_NAME}/environments/${env_name}" &> /dev/null; then
        echo -e "${YELLOW}⚠️  Environment '${env_name}' already exists${NC}"
        return 0
    fi

    # Create environment
    gh api --method PUT "repos/${REPO_FULL_NAME}/environments/${env_name}" \
        --field "prevent_self_review=false" \
        --field "wait_timer=0" || {
        echo -e "${RED}❌ Failed to create environment: ${env_name}${NC}"
        return 1
    }

    echo -e "${GREEN}✅ Created environment: ${env_name}${NC}"
}

# Function to add protection rule
add_protection_rule() {
    local env_name=$1
    local reviewers=$2
    local wait_timer=${3:-0}

    echo -e "${YELLOW}🛡️  Adding protection rules to: ${env_name}${NC}"

    # Get current user for reviewer if not specified
    if [ -z "$reviewers" ]; then
        reviewers="[{\"type\":\"User\",\"id\":$(gh api user --jq '.id')}]"
    fi

    gh api --method PUT "repos/${REPO_FULL_NAME}/environments/${env_name}" \
        --field "wait_timer=${wait_timer}" \
        --field "prevent_self_review=false" \
        --raw-field "reviewers=${reviewers}" || {
        echo -e "${RED}❌ Failed to add protection rules to: ${env_name}${NC}"
        return 1
    }

    echo -e "${GREEN}✅ Added protection rules to: ${env_name}${NC}"
}

# Function to set environment variables
set_environment_variables() {
    local env_name=$1

    echo -e "${YELLOW}🔑 Setting up environment variables for: ${env_name}${NC}"

    # Environment-specific variables
    case $env_name in
        "development")
            ENV_VARS=(
                "DEPLOYMENT_STAGE=development"
                "PAYPAL_ENVIRONMENT=sandbox"
                "DEBUG_MODE=true"
                "LOG_LEVEL=debug"
            )
            ;;
        "staging")
            ENV_VARS=(
                "DEPLOYMENT_STAGE=staging"
                "PAYPAL_ENVIRONMENT=sandbox"
                "DEBUG_MODE=false"
                "LOG_LEVEL=info"
            )
            ;;
        "production"|"github-pages")
            ENV_VARS=(
                "DEPLOYMENT_STAGE=production"
                "PAYPAL_ENVIRONMENT=live"
                "DEBUG_MODE=false"
                "LOG_LEVEL=warn"
            )
            ;;
    esac

    # Set environment variables
    for var in "${ENV_VARS[@]}"; do
        var_name=$(echo "$var" | cut -d'=' -f1)
        var_value=$(echo "$var" | cut -d'=' -f2)

        gh api --method PUT "repos/${REPO_FULL_NAME}/environments/${env_name}/variables/${var_name}" \
            --field "value=${var_value}" || {
            echo -e "${RED}❌ Failed to set variable: ${var_name}${NC}"
        }
    done

    echo -e "${GREEN}✅ Environment variables set for: ${env_name}${NC}"
}

# Main setup function
main() {
    echo -e "${BLUE}🚀 Starting environment protection setup...${NC}"
    echo

    # Create environments
    echo -e "${BLUE}📁 Creating environments...${NC}"
    create_environment "development" "Development environment for testing PayPal integration"
    create_environment "staging" "Staging environment for pre-production testing"
    create_environment "github-pages" "Production environment for GitHub Pages deployment"
    echo

    # Set up protection rules
    echo -e "${BLUE}🛡️  Setting up protection rules...${NC}"

    # Development: No protection (for rapid testing)
    echo -e "${YELLOW}📝 Development: No protection rules (rapid testing)${NC}"

    # Staging: Optional review
    echo -e "${YELLOW}📝 Staging: Optional review${NC}"
    add_protection_rule "staging" "" 0

    # Production: Required review + wait timer
    echo -e "${YELLOW}📝 Production: Required review + 5 minute wait timer${NC}"
    CURRENT_USER_ID=$(gh api user --jq '.id')
    REVIEWERS="[{\"type\":\"User\",\"id\":${CURRENT_USER_ID}}]"
    add_protection_rule "github-pages" "$REVIEWERS" 300  # 5 minute wait
    echo

    # Set environment variables
    echo -e "${BLUE}🔧 Setting environment variables...${NC}"
    set_environment_variables "development"
    set_environment_variables "staging"
    set_environment_variables "github-pages"
    echo

    # Create branch protection rules
    echo -e "${BLUE}🌿 Setting up branch protection...${NC}"
    gh api --method PUT "repos/${REPO_FULL_NAME}/branches/main/protection" \
        --field "required_status_checks={\"strict\":true,\"checks\":[{\"context\":\"test\",\"app_id\":null},{\"context\":\"build\",\"app_id\":null}]}" \
        --field "enforce_admins=false" \
        --field "required_pull_request_reviews={\"required_approving_review_count\":1,\"dismiss_stale_reviews\":true}" \
        --field "restrictions=null" \
        --field "allow_force_pushes=false" \
        --field "allow_deletions=false" || {
        echo -e "${YELLOW}⚠️  Could not set branch protection (may require admin permissions)${NC}"
    }

    # Summary
    echo -e "${GREEN}✅ Environment protection setup completed!${NC}"
    echo
    echo -e "${BLUE}📋 Summary:${NC}"
    echo "• Development environment: No protection (rapid testing)"
    echo "• Staging environment: Optional review"
    echo "• Production (github-pages): Required review + 5min wait"
    echo "• Branch protection: Required PR reviews + status checks"
    echo
    echo -e "${BLUE}🔗 Next steps:${NC}"
    echo "1. Upload secrets: ./scripts/upload_secrets_to_github.sh"
    echo "2. Test workflow: Push to main branch"
    echo "3. Review deployment: https://github.com/${REPO_FULL_NAME}/actions"
    echo
    echo -e "${BLUE}🌐 Access environments:${NC}"
    echo "• GitHub: https://github.com/${REPO_FULL_NAME}/settings/environments"
    echo "• Actions: https://github.com/${REPO_FULL_NAME}/actions"
    echo "• Pages: https://github.com/${REPO_FULL_NAME}/settings/pages"
    echo
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Environment Protection Setup Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "This script sets up GitHub environment protection rules for secure PayPal integration."
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --repo REPO    Specify repository (format: owner/repo)"
    echo
    echo "Requirements:"
    echo "  - GitHub CLI (gh) installed and authenticated"
    echo "  - Repository admin permissions"
    echo "  - Git repository initialized"
    echo
    echo "Environments created:"
    echo "  - development: No protection (for rapid testing)"
    echo "  - staging: Optional review"
    echo "  - github-pages: Required review + wait timer"
    echo
    exit 0
fi

# Override repository if specified
if [[ "$1" == "--repo" && -n "$2" ]]; then
    REPO_FULL_NAME="$2"
    echo "Using repository: $REPO_FULL_NAME"
fi

# Run main function
main

echo -e "${GREEN}🎉 Environment protection setup completed successfully!${NC}"
