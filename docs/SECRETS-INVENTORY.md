# FreshThreads Secrets Inventory

# Keep this file secure and separate from the repository

## Production Secrets Inventory

### Docker Hub Secrets

- **Secret Name**: DOCKER_USERNAME
- **Source**: Docker Hub account username
- **Backup Location**: Password manager (1Password/Bitwarden)
- **Rotation Schedule**: N/A (username doesn't change)
- **Last Updated**: 2025-07-30

- **Secret Name**: DOCKER_PASSWORD
- **Source**: Docker Hub Personal Access Token
- **Backup Location**: Password manager with token value
- **Rotation Schedule**: Every 6 months
- **Last Updated**: 2025-07-30
- **Expiration**: 2026-01-30

### SonarQube Secrets

- **Secret Name**: SONAR_TOKEN
- **Source**: SonarQube User Token (My Account → Security)
- **Backup Location**: Password manager
- **Rotation Schedule**: Every 6 months
- **Last Updated**: 2025-07-30
- **Expiration**: No expiration set

- **Secret Name**: SONAR_HOST_URL
- **Source**: SonarQube server URL
- **Backup Location**: This inventory (not sensitive)
- **Value**: http://localhost:9000
- **Rotation Schedule**: N/A

### Slack Integration (Optional)

- **Secret Name**: SLACK_WEBHOOK
- **Source**: Slack App Webhook URL
- **Backup Location**: Password manager
- **Rotation Schedule**: When webhook is regenerated
- **Last Updated**: Not set yet

## Recovery Procedures

### Docker Hub Token Recovery

1. Login to Docker Hub
2. Go to Account Settings → Security
3. Generate new Personal Access Token
4. Update DOCKER_PASSWORD secret in GitHub

### SonarQube Token Recovery

1. Login to SonarQube (localhost:9000)
2. Go to My Account → Security
3. Revoke old token, generate new one
4. Update SONAR_TOKEN secret in GitHub

### Slack Webhook Recovery

1. Go to Slack App management
2. Regenerate webhook URL
3. Update SLACK_WEBHOOK secret in GitHub

## Security Notes

- Never store actual secret values in this file
- Keep this inventory in secure password manager
- Regular audit of active secrets
- Monitor token usage in respective services
