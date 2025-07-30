# Bitwarden CLI Setup Guide for FreshThreads

This guide shows you how to use Bitwarden CLI to securely manage GitHub Secrets for your FreshThreads CI/CD pipeline.

## 🚀 **Quick Start**

### 1. Install and Setup

```bash
# Install Bitwarden CLI
brew install bitwarden-cli

# Verify installation
bw --version

# Set server (if using self-hosted)
bw config server https://vault.bitwarden.com

# Login to your Bitwarden account
bw login your-email@example.com
```

### 2. Use the FreshThreads Secrets Manager

```bash
# Run the interactive secrets manager
./scripts/bitwarden-secrets-manager.sh

# Follow the prompts to:
# - Authenticate with Bitwarden
# - Store secrets securely
# - Sync to GitHub Actions
```

## 🔧 **Manual CLI Usage**

### Basic Commands

```bash
# Login and get session token
BW_SESSION=$(bw unlock --raw)
export BW_SESSION

# List all items
bw list items --session $BW_SESSION

# Search for FreshThreads secrets
bw list items --search "FreshThreads-" --session $BW_SESSION

# Get specific secret
bw get item "FreshThreads-DOCKER_USERNAME" --session $BW_SESSION

# Create new secret
bw create item '{
  "type": 2,
  "name": "FreshThreads-NEW_SECRET",
  "secureNote": {"type": 0},
  "fields": [{"name": "value", "value": "secret-value", "type": 1}]
}' --session $BW_SESSION

# Lock vault when done
bw lock --session $BW_SESSION
```

### Store GitHub Secrets

```bash
# Example: Store Docker Hub credentials
bw create item '{
  "type": 2,
  "name": "FreshThreads-DOCKER_USERNAME",
  "notes": "Docker Hub username for CI/CD",
  "secureNote": {"type": 0},
  "fields": [
    {"name": "Secret Value", "value": "your-username", "type": 1},
    {"name": "Service", "value": "Docker Hub", "type": 0},
    {"name": "Updated", "value": "'$(date)'", "type": 0}
  ]
}' --session $BW_SESSION
```

### Retrieve and Set GitHub Secrets

```bash
# Get secret from Bitwarden and set in GitHub
SECRET_VALUE=$(bw get item "FreshThreads-DOCKER_USERNAME" --session $BW_SESSION | \
               jq -r '.fields[] | select(.name=="Secret Value") | .value')

# Set in GitHub repository
echo "$SECRET_VALUE" | gh secret set DOCKER_USERNAME
```

## 🔐 **Security Best Practices**

### 1. **Use API Keys for CI/CD**

For automated workflows, use Bitwarden API keys instead of passwords:

```bash
# Generate API key at https://vault.bitwarden.com/#/settings/security/security-keys
# Set as GitHub secrets:
# BW_CLIENTID: your-client-id
# BW_CLIENTSECRET: your-client-secret

# Login in CI/CD
bw config server https://vault.bitwarden.com
BW_SESSION=$(bw login --apikey --raw)
```

### 2. **Session Management**

```bash
# Always export session for security
BW_SESSION=$(bw unlock --raw)
export BW_SESSION

# Use session in all commands
bw list items --session $BW_SESSION

# Lock when done
bw lock --session $BW_SESSION
```

### 3. **Organization Setup**

For team collaboration:

```bash
# List organizations
bw list organizations --session $BW_SESSION

# Create item in organization collection
bw create item '{
  "organizationId": "your-org-id",
  "collectionIds": ["collection-id"],
  "type": 2,
  "name": "FreshThreads-SECRET"
}' --session $BW_SESSION
```

## 📋 **FreshThreads Secrets Structure**

### Required Secrets in Bitwarden:

1. **FreshThreads-DOCKER_USERNAME**
   - Type: Secure Note
   - Fields: Secret Value (Docker Hub username)

2. **FreshThreads-DOCKER_PASSWORD**
   - Type: Secure Note
   - Fields: Secret Value (Docker Hub Personal Access Token)

3. **FreshThreads-SONAR_TOKEN**
   - Type: Secure Note
   - Fields: Secret Value (SonarQube User Token)

4. **FreshThreads-SONAR_HOST_URL**
   - Type: Secure Note
   - Fields: Secret Value (http://localhost:9000)

5. **FreshThreads-SLACK_WEBHOOK** (Optional)
   - Type: Secure Note
   - Fields: Secret Value (Slack webhook URL)

## 🔄 **Secret Rotation Workflow**

### Automated Rotation (Monthly)

The GitHub Actions workflow automatically:

1. Checks secret age in Bitwarden
2. Creates issues for secrets > 6 months old
3. Sends Slack notifications
4. Backs up secret inventory

### Manual Rotation

```bash
# Run the rotation script
./scripts/bitwarden-secrets-manager.sh

# Select option 7 (Rotate secrets)
# Follow prompts to update each secret
```

### Rotation Steps per Secret:

**Docker Hub Token:**

1. Go to https://hub.docker.com/settings/security
2. Revoke old Personal Access Token
3. Generate new token with same permissions
4. Update in Bitwarden using the script

**SonarQube Token:**

1. Access http://localhost:9000
2. My Account → Security
3. Revoke old token, generate new
4. Update in Bitwarden using the script

## 🚨 **Troubleshooting**

### Common Issues:

**"Vault is locked" error:**

```bash
# Unlock vault
BW_SESSION=$(bw unlock --raw)
export BW_SESSION
```

**"Invalid master password" error:**

```bash
# Re-login
bw logout
bw login your-email@example.com
```

**"Item not found" error:**

```bash
# Sync vault
bw sync --session $BW_SESSION

# Search for items
bw list items --search "FreshThreads" --session $BW_SESSION
```

**GitHub CLI authentication:**

```bash
# Re-authenticate
gh auth logout
gh auth login
```

### Debug Commands:

```bash
# Check Bitwarden status
bw status

# Test GitHub CLI
gh auth status

# List all secrets in repository
gh secret list

# Test secret retrieval
bw get item "item-id" --session $BW_SESSION | jq .
```

## 📚 **Additional Resources**

- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/)
- [GitHub CLI Secrets Documentation](https://cli.github.com/manual/gh_secret)
- [Bitwarden Business Setup](https://bitwarden.com/help/getting-started-business/)

## 🔗 **Integration with FreshThreads**

The secrets manager integrates with:

- ✅ Docker Hub (container registry)
- ✅ SonarQube (code quality analysis)
- ✅ Slack (security notifications)
- ✅ GitHub Actions (CI/CD pipeline)
- ✅ Security Onion (network monitoring)

All secrets are centrally managed in Bitwarden with automatic rotation reminders and secure synchronization to GitHub Actions.
