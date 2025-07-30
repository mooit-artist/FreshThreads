# GitHub Secrets Setup Guide for FreshThreads CI/CD

This guide will help you set up the required GitHub Secrets for the FreshThreads security infrastructure CI/CD pipeline.

## Required Secrets

### 1. Docker Hub Integration

- **DOCKER_USERNAME**: Your Docker Hub username
- **DOCKER_PASSWORD**: Your Docker Hub password or access token

### 2. SonarQube Integration

- **SONAR_TOKEN**: SonarQube authentication token
- **SONAR_HOST_URL**: SonarQube server URL (e.g., http://localhost:9000)

### 3. Slack Notifications (Optional)

- **SLACK_WEBHOOK**: Slack webhook URL for security alerts

## Setup Instructions

### Step 1: Docker Hub Setup

1. **Create Docker Hub Account** (if you don't have one):

   ```bash
   # Go to https://hub.docker.com/
   # Click "Sign Up" and create account
   ```

2. **Generate Access Token** (recommended over password):
   - Go to Docker Hub → Account Settings → Security
   - Click "New Access Token"
   - Name: "FreshThreads-CI"
   - Permissions: Read, Write, Delete
   - Copy the generated token

3. **Test Docker Login**:
   ```bash
   docker login -u YOUR_USERNAME
   # Enter your access token when prompted for password
   ```

### Step 2: SonarQube Token Setup

1. **Access SonarQube**:

   ```bash
   # Start SonarQube if not running
   docker-compose -f docker-compose.sonarqube.yml up -d

   # Access at http://localhost:9000
   # Default login: admin/admin
   ```

2. **Generate User Token**:
   - Login to SonarQube web interface
   - Go to My Account → Security
   - Generate Token:
     - Name: "FreshThreads-CI"
     - Type: "User Token"
     - Expiration: "No expiration" or 1 year
   - Copy the generated token

3. **Create Project** (if not exists):
   - Go to Projects → Create Project
   - Project Key: `freshthreads-security`
   - Display Name: `FreshThreads Security`

### Step 3: GitHub Secrets Configuration

1. **Access Repository Settings**:

   ```
   https://github.com/mooit-artist/FreshThreads/settings/secrets/actions
   ```

2. **Add Repository Secrets**:

   **Docker Hub Secrets:**

   ```
   Name: DOCKER_USERNAME
   Value: your-docker-username

   Name: DOCKER_PASSWORD
   Value: your-docker-access-token
   ```

   **SonarQube Secrets:**

   ```
   Name: SONAR_TOKEN
   Value: your-sonarqube-token

   Name: SONAR_HOST_URL
   Value: http://localhost:9000
   ```

   **Slack Webhook (Optional):**

   ```
   Name: SLACK_WEBHOOK
   Value: https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
   ```

### Step 4: Verify CI/CD Setup

1. **Test GitHub Actions**:

   ```bash
   # Push to trigger workflow
   git add .
   git commit -m "feat: setup CI/CD pipeline"
   git push origin feature/security-infrastructure-upgrade
   ```

2. **Monitor Workflow**:
   - Go to Actions tab in GitHub repository
   - Check "Security Infrastructure CI/CD" workflow
   - Verify all jobs complete successfully

3. **Check Artifacts**:
   - Security reports should be uploaded as artifacts
   - Docker images should be pushed to Docker Hub
   - SonarQube analysis should complete

### Step 5: Production Deployment

1. **Merge to Main Branch**:

   ```bash
   # Create pull request
   git checkout main
   git merge feature/security-infrastructure-upgrade
   git push origin main
   ```

2. **Verify Production Deployment**:
   - GitHub Pages should deploy automatically
   - Security monitoring should be active
   - Dashboard should be accessible

## Troubleshooting

### Common Issues

1. **Docker Login Failed**:

   ```bash
   # Check credentials
   docker logout
   docker login -u YOUR_USERNAME
   ```

2. **SonarQube Connection Failed**:

   ```bash
   # Verify SonarQube is running
   curl http://localhost:9000/api/system/status
   ```

3. **GitHub Actions Failed**:
   - Check Actions logs for specific errors
   - Verify all secrets are correctly set
   - Check Docker Hub rate limits

### Security Best Practices

1. **Use Access Tokens** instead of passwords
2. **Set Token Expiration** dates
3. **Regular Token Rotation** (quarterly)
4. **Monitor Token Usage** in Docker Hub/SonarQube
5. **Restrict Token Permissions** to minimum required

## Next Steps

Once secrets are configured:

1. ✅ CI/CD pipeline will automatically:
   - Run security analysis on code changes
   - Build and push Docker images
   - Deploy to GitHub Pages
   - Generate security reports

2. ✅ Monitoring will include:
   - SonarQube code quality analysis
   - Security Onion network monitoring
   - PCI DSS compliance checking
   - SSL certificate monitoring

3. ✅ Alerts will be sent for:
   - Security vulnerabilities
   - Failed deployments
   - Compliance violations
   - Certificate expiration

## Support

For issues with setup:

- Check GitHub Actions logs
- Review SonarQube logs: `docker-compose logs sonarqube`
- Verify Docker Hub access
- Test local deployment first
