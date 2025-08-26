#!/bin/bash
# AWS App Runner Deployment Script for FreshThreads
# Run this script to deploy your backend to AWS

set -e

echo "🚀 FreshThreads AWS Deployment Script"
echo "=====================================\n"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first:${NC}"
    echo "   brew install awscli"
    echo "   aws configure"
    exit 1
fi

# Check if user is logged in to AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not configured. Please run:${NC}"
    echo "   aws configure"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI configured${NC}"

# Set variables
SERVICE_NAME="freshthreads-api"
REPOSITORY_URL="https://github.com/mooit-artist/FreshThreads"
REGION="us-east-1"

echo -e "${YELLOW}📝 Creating App Runner service...${NC}"

# Create the service
aws apprunner create-service \
  --service-name $SERVICE_NAME \
  --region $REGION \
  --source-configuration '{
    "GitRepository": {
      "RepositoryUrl": "'$REPOSITORY_URL'",
      "SourceCodeVersion": {
        "Type": "BRANCH",
        "Value": "main"
      },
      "CodeConfiguration": {
        "ConfigurationSource": "CONFIGURATION_FILE"
      }
    },
    "AutoDeploymentsEnabled": true
  }' \
  --instance-configuration '{
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }' \
  --health-check-configuration '{
    "Protocol": "HTTP",
    "Path": "/health",
    "Interval": 20,
    "Timeout": 10,
    "HealthyThreshold": 3,
    "UnhealthyThreshold": 3
  }'

echo -e "${GREEN}✅ App Runner service created successfully!${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Wait 5-10 minutes for the service to deploy"
echo "2. Check AWS Console for the service URL"
echo "3. Set up environment variables in AWS Secrets Manager"
echo "4. Configure custom domain (api.freshthreadsllc.com)"

echo -e "\n${GREEN}🎉 Deployment initiated! Check AWS Console for status.${NC}"
