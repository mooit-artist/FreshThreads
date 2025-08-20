# QNAP QTS API Integration Guide

# Using Official QNAP QTS Authentication API Documentation

## 📚 Overview

This guide shows how to deploy FreshThreads to your QNAP using the official QTS API, leveraging the documentation in `docs/API_QNAP_QTS_Authentication.pdf`.

## 🔧 Prerequisites

### 1. QNAP System Requirements

- QTS 4.4.0+ or QuTS hero h4.5.0+
- Container Station installed
- Web-based management access enabled
- SSH access enabled (optional, for fallback)

### 2. API Authentication Setup

Configure your QNAP credentials in `.env.qnap`:

```bash
# QTS API Authentication
QNAP_USERNAME=admin
QNAP_PASSWORD=your_qnap_admin_password
```

## 🚀 Deployment Methods

### Method 1: QTS API Deployment (Recommended)

Uses the official QNAP QTS API for automated deployment:

```bash
# Test QTS API connectivity
./qnap-api-deploy.sh test

# Full deployment via QTS API
./qnap-api-deploy.sh deploy

# Test authentication only
./qnap-api-deploy.sh auth
```

### Method 2: SSH Deployment (Fallback)

Traditional SSH-based deployment:

```bash
# Test SSH access
./test-qnap-access.sh

# Deploy via SSH
./deploy-to-qnap.sh
```

## 📋 QTS API Endpoints Used

Based on `docs/API_QNAP_QTS_Authentication.pdf`, our deployment uses:

### Authentication

- `POST /cgi-bin/authLogin.cgi` - Login to QTS
- `GET /cgi-bin/authLogout.cgi` - Logout from QTS

### System Information

- `GET /cgi-bin/management/manaRequest.cgi?subfunc=sysinfo` - System status

### Container Station

- `GET /cgi-bin/container-station/containerRequest.cgi?op=config_get` - Check Container Station
- `GET /cgi-bin/container-station/containerRequest.cgi?op=docker_info` - Docker info
- `POST /cgi-bin/container-station/containerRequest.cgi` - Container operations

### File Management

- `POST /cgi-bin/filemanager/utilRequest.cgi` - File operations

## 🔍 Step-by-Step API Deployment

### Step 1: API Authentication Test

```bash
./qnap-api-deploy.sh test
```

Expected output:

```
🧪 Testing QNAP QTS API connectivity...
✅ QTS API endpoint is accessible
✅ QTS API authentication successful
ℹ️ Model: TS-464C2
ℹ️ QTS Version: 5.1.0
✅ Container Station is enabled
✅ Docker is available
ℹ️ Docker Version: 20.10.14
```

### Step 2: Full Deployment

```bash
./qnap-api-deploy.sh deploy
```

This will:

1. Authenticate with QTS API
2. Check system status and Container Station
3. Create shared folders for the project
4. Upload docker-compose.yml
5. Create container project
6. Start containers
7. Verify deployment

### Step 3: Verify Deployment

Access your deployed application:

- **Frontend**: https://192.168.0.68:8080
- **Backend API**: https://192.168.0.68:8000
- **QTS Management**: https://192.168.0.68

## 🛠️ API Integration Features

### Automatic System Checks

- ✅ Network connectivity testing
- ✅ QTS version compatibility
- ✅ Container Station availability
- ✅ Docker daemon status

### Secure Authentication

- 🔐 HTTPS-only API communication
- 🔐 Session-based authentication
- 🔐 Automatic session cleanup

### Container Management

- 📦 Automatic project creation
- 📦 Docker Compose deployment
- 📦 Container health monitoring
- 📦 Shared folder management

## 🔧 Troubleshooting

### API Authentication Issues

```bash
# Error: QTS API authentication failed
# Solution: Check credentials in .env.qnap
echo "QNAP_USERNAME=admin" >> .env.qnap
echo "QNAP_PASSWORD=your_password" >> .env.qnap
```

### Container Station Not Available

```bash
# Error: Container Station may not be enabled
# Solution: Install via QTS Web Interface
```

1. Login to https://192.168.0.68
2. Go to App Center
3. Install "Container Station"

### SSL Certificate Issues

```bash
# Error: SSL certificate problems
# Our scripts use -k flag to ignore SSL certificate issues
# This is safe for local network deployment
```

### Port Conflicts

```bash
# Error: Port 8080 or 8000 already in use
# Solution: Modify ports in .env.qnap
FRONTEND_PORT=8081
BACKEND_PORT=8001
```

## 📊 API Response Examples

### Successful Authentication

```json
{
  "authPassed": true,
  "authSid": "session_id_here",
  "result": 0
}
```

### System Information

```json
{
  "result": 0,
  "model": "TS-464C2",
  "version": "5.1.0.1891",
  "uptime": "5 days, 2 hours"
}
```

### Container Status

```json
{
  "result": 0,
  "containers": [
    {
      "name": "freshthreads_backend_1",
      "state": "running"
    },
    {
      "name": "freshthreads_frontend_1",
      "state": "running"
    }
  ]
}
```

## 🔄 Maintenance Commands

### Check Container Status

```bash
./qnap-api-deploy.sh auth
```

### Restart Containers

```bash
# Via QTS Web Interface:
# Container Station > Containers > Select Project > Restart
```

### View Logs

```bash
# Via SSH (if enabled):
ssh admin@192.168.0.68 "cd /share/Container/FreshThreads && docker-compose logs -f"

# Via QTS Web Interface:
# Container Station > Containers > Select Container > Logs
```

### Update Deployment

```bash
# Pull latest changes and redeploy
git pull
./qnap-api-deploy.sh deploy
```

## 🔒 Security Notes

### API Security

- All API calls use HTTPS
- Session tokens are automatically managed
- Credentials are stored locally only
- Session cleanup on script completion

### Network Security

- API access limited to local network
- Container network isolation
- No external port exposure by default

### File Permissions

- Containers run with limited privileges
- Shared folders have restricted access
- Sensitive files excluded from deployment

## 📈 Monitoring

### Health Checks

```bash
# Test API connectivity
curl -k https://192.168.0.68:8000/health

# Test frontend
curl -k https://192.168.0.68:8080

# Check QTS status
./qnap-api-deploy.sh auth
```

### Container Monitoring

- Use QTS Container Station web interface
- Monitor resource usage in QTS dashboard
- Set up alerts for container failures

## 🆘 Support

### Documentation References

- `docs/API_QNAP_QTS_Authentication.pdf` - Official QNAP API docs
- `QNAP-DEPLOYMENT.md` - General deployment guide
- `QNAP-SETUP-GUIDE.md` - Initial setup instructions

### Log Files

- QTS API logs: Available in QTS System Logs
- Container logs: Container Station > Logs
- Deployment logs: Terminal output from scripts

### Getting Help

1. Check QTS system logs
2. Verify Container Station status
3. Test network connectivity
4. Review API authentication
5. Check container resource limits

This integration leverages the official QNAP QTS API documentation to provide a robust, automated deployment solution for your FreshThreads application.
