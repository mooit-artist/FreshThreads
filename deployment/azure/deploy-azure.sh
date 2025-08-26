#!/bin/bash

# ☁️ FreshThreads Azure Deployment Script
# Usage: ./deploy-azure.sh

set -e

echo "🚀 Starting FreshThreads Azure Deployment..."

# Configuration
RESOURCE_GROUP="freshthreads-rg"
LOCATION="eastus"
APP_NAME="freshthreads-api"
ACR_NAME="freshthreads"
KEY_VAULT_NAME="freshthreads-kv"
DB_SERVER_NAME="freshthreads-db"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prereqs() {
    log_info "Checking prerequisites..."

    if ! command -v az &> /dev/null; then
        log_error "Azure CLI not found. Install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi

    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Install: https://docs.docker.com/get-docker/"
        exit 1
    fi

    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log_warning "Not logged in to Azure. Running 'az login'..."
        az login
    fi

    log_success "Prerequisites check passed"
}

# Create resource group
create_resource_group() {
    log_info "Creating resource group: $RESOURCE_GROUP"

    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION \
        --output table

    log_success "Resource group created"
}

# Create container registry
create_container_registry() {
    log_info "Creating Azure Container Registry: $ACR_NAME"

    az acr create \
        --resource-group $RESOURCE_GROUP \
        --name $ACR_NAME \
        --sku Basic \
        --admin-enabled true \
        --output table

    log_success "Container registry created"
}

# Build and push Docker image
build_and_push_image() {
    log_info "Building and pushing Docker image..."

    # Login to ACR
    az acr login --name $ACR_NAME

    # Build image
    docker build -t $ACR_NAME.azurecr.io/backend:latest .

    # Push image
    docker push $ACR_NAME.azurecr.io/backend:latest

    log_success "Docker image pushed to registry"
}

# Create Key Vault
create_key_vault() {
    log_info "Creating Azure Key Vault: $KEY_VAULT_NAME"

    az keyvault create \
        --resource-group $RESOURCE_GROUP \
        --name $KEY_VAULT_NAME \
        --location $LOCATION \
        --output table

    log_success "Key Vault created"
}

# Store secrets in Key Vault
store_secrets() {
    log_info "Storing secrets in Key Vault..."

    if [ -f .env ]; then
        # Read secrets from .env file
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ $key == \#* ]] || [[ -z $key ]]; then
                continue
            fi

            # Store secret in Key Vault
            az keyvault secret set \
                --vault-name $KEY_VAULT_NAME \
                --name "$key" \
                --value "$value" \
                --output none

            log_info "Stored secret: $key"
        done < .env

        log_success "All secrets stored in Key Vault"
    else
        log_warning ".env file not found. You'll need to manually add secrets to Key Vault"
    fi
}

# Create PostgreSQL database
create_database() {
    log_info "Creating Azure Database for PostgreSQL..."

    az postgres flexible-server create \
        --resource-group $RESOURCE_GROUP \
        --name $DB_SERVER_NAME \
        --location $LOCATION \
        --admin-user freshthreads \
        --admin-password "$(openssl rand -base64 32)" \
        --sku-name Standard_B1ms \
        --tier Burstable \
        --storage-size 32 \
        --output table

    log_success "PostgreSQL database created"
}

# Create Container Apps environment
create_container_apps_env() {
    log_info "Creating Container Apps environment..."

    az containerapp env create \
        --resource-group $RESOURCE_GROUP \
        --name freshthreads-env \
        --location $LOCATION \
        --output table

    log_success "Container Apps environment created"
}

# Deploy Container App
deploy_container_app() {
    log_info "Deploying Container App..."

    # Update the YAML with actual subscription ID
    SUBSCRIPTION_ID=$(az account show --query id --output tsv)
    sed -i.bak "s/{subscription-id}/$SUBSCRIPTION_ID/g" deployment/azure/container-app.yml

    # Deploy using YAML configuration
    az containerapp create \
        --resource-group $RESOURCE_GROUP \
        --yaml deployment/azure/container-app.yml

    log_success "Container App deployed"
}

# Set up Azure AD B2C (placeholder)
setup_azure_ad() {
    log_info "Azure AD B2C setup required..."
    log_warning "Manual step: Configure Azure AD B2C tenant"
    log_warning "Guide: https://docs.microsoft.com/en-us/azure/active-directory-b2c/"
}

# Get deployment information
get_deployment_info() {
    log_info "Getting deployment information..."

    # Get app URL
    APP_URL=$(az containerapp show \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --query properties.configuration.ingress.fqdn \
        --output tsv)

    echo ""
    log_success "🎉 Deployment Complete!"
    echo "----------------------------------------"
    echo "📱 App URL: https://$APP_URL"
    echo "🔐 Key Vault: $KEY_VAULT_NAME"
    echo "🗄️  Database: $DB_SERVER_NAME"
    echo "📦 Registry: $ACR_NAME.azurecr.io"
    echo "----------------------------------------"

    log_info "Next Steps:"
    echo "1. Configure custom domain: api.freshthreadsllc.com"
    echo "2. Set up Azure AD B2C for authentication"
    echo "3. Test API endpoints"
    echo "4. Update frontend to use new backend URL"
}

# Main deployment flow
main() {
    echo "☁️ FreshThreads Azure Deployment"
    echo "================================="

    check_prereqs
    create_resource_group
    create_container_registry
    create_key_vault
    store_secrets
    create_database
    create_container_apps_env
    build_and_push_image
    deploy_container_app
    setup_azure_ad
    get_deployment_info

    log_success "🚀 Azure deployment completed successfully!"
}

# Run main function
main "$@"
