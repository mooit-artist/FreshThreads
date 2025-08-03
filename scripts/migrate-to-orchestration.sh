#!/bin/bash

# FreshThreads Repository Cleanup - Move Infrastructure to Orchestration Repo
# This script moves non-business files to a separate orchestration repository

echo "🧹 Starting FreshThreads Repository Cleanup..."

# Check if orchestration repo path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-orchestration-repo>"
    echo "Example: $0 ../website-orchestration"
    exit 1
fi

ORCHESTRATION_REPO="$1"

# Create orchestration directory structure if it doesn't exist
mkdir -p "$ORCHESTRATION_REPO"/{security,docker,docs,reports,config}

echo "📦 Moving infrastructure files to orchestration repo..."

# Move security infrastructure
echo "  🔒 Moving security files..."
[ -d "security-onion" ] && mv security-onion/ "$ORCHESTRATION_REPO/security/"
[ -d "sonarqube-config" ] && mv sonarqube-config/ "$ORCHESTRATION_REPO/config/"

# Move Docker files
echo "  🐳 Moving Docker infrastructure..."
[ -f "docker-compose.security-onion.yml" ] && mv docker-compose.security-onion.yml "$ORCHESTRATION_REPO/docker/"
[ -f "docker-compose.sonarqube.yml" ] && mv docker-compose.sonarqube.yml "$ORCHESTRATION_REPO/docker/"
[ -f "Dockerfile.sonarqube" ] && mv Dockerfile.sonarqube "$ORCHESTRATION_REPO/docker/"

# Move documentation
echo "  📚 Moving infrastructure documentation..."
[ -f "SECURITY-ONION-SETUP.md" ] && mv SECURITY-ONION-SETUP.md "$ORCHESTRATION_REPO/docs/"
[ -f "SECURITY-INFRASTRUCTURE-SUMMARY.md" ] && mv SECURITY-INFRASTRUCTURE-SUMMARY.md "$ORCHESTRATION_REPO/docs/"
[ -f "AIKIDO-CONFIGURATION.md" ] && mv AIKIDO-CONFIGURATION.md "$ORCHESTRATION_REPO/docs/"
[ -f "AIKIDO-INTEGRATION-SUMMARY.md" ] && mv AIKIDO-INTEGRATION-SUMMARY.md "$ORCHESTRATION_REPO/docs/"
[ -f "SNYK-CONFIGURATION.md" ] && mv SNYK-CONFIGURATION.md "$ORCHESTRATION_REPO/docs/"
[ -f "SONARQUBE-UPGRADE-SUMMARY.md" ] && mv SONARQUBE-UPGRADE-SUMMARY.md "$ORCHESTRATION_REPO/docs/"
[ -f "DOCKER.md" ] && mv DOCKER.md "$ORCHESTRATION_REPO/docs/"
[ -f "DEPLOYMENT-COMPLETE.md" ] && mv DEPLOYMENT-COMPLETE.md "$ORCHESTRATION_REPO/docs/"

# Move reports
echo "  📊 Moving report directories..."
[ -d "security-reports" ] && mv security-reports/ "$ORCHESTRATION_REPO/reports/"
[ -d "sonar-reports" ] && mv sonar-reports/ "$ORCHESTRATION_REPO/reports/"
[ -d "test-reports" ] && mv test-reports/ "$ORCHESTRATION_REPO/reports/"

# Move config files
echo "  ⚙️  Moving configuration files..."
[ -f ".eslintrc.json" ] && mv .eslintrc.json "$ORCHESTRATION_REPO/config/"
[ -f ".stylelintrc.json" ] && mv .stylelintrc.json "$ORCHESTRATION_REPO/config/"
[ -f ".yamllint" ] && mv .yamllint "$ORCHESTRATION_REPO/config/"
[ -f ".markdownlintrc" ] && mv .markdownlintrc "$ORCHESTRATION_REPO/config/"
[ -f "sonar-project.properties" ] && mv sonar-project.properties "$ORCHESTRATION_REPO/config/"
[ -f "sonar-quality-profile.properties" ] && mv sonar-quality-profile.properties "$ORCHESTRATION_REPO/config/"
[ -f "aikido.json" ] && mv aikido.json "$ORCHESTRATION_REPO/config/"

# Move report files
echo "  📋 Moving report files..."
[ -f "accessibility-report.json" ] && mv accessibility-report.json "$ORCHESTRATION_REPO/reports/"
[ -f "csp-report.json" ] && mv csp-report.json "$ORCHESTRATION_REPO/reports/"
[ -f "license-report.json" ] && mv license-report.json "$ORCHESTRATION_REPO/reports/"
[ -f "security-report.json" ] && mv security-report.json "$ORCHESTRATION_REPO/reports/"
[ -f "security-report.sarif" ] && mv security-report.sarif "$ORCHESTRATION_REPO/reports/"

echo "✅ Migration complete!"
echo ""
echo "📁 FreshThreads now contains only:"
echo "   - docs/ (your website)"
echo "   - Business setup files"
echo "   - Core package.json"
echo "   - README.md"
echo ""
echo "📁 Orchestration repo now contains:"
echo "   - security/ (Security Onion, monitoring)"
echo "   - docker/ (Infrastructure as Code)"
echo "   - config/ (Development tooling)"
echo "   - reports/ (Analysis reports)"
echo "   - docs/ (Infrastructure documentation)"
echo ""
echo "🎯 FreshThreads is now focused purely on the T-shirt business!"
