# FreshThreads QNAP Deployment Guide

## Prerequisites

1. **QNAP NAS with Container Station installed**
   - Minimum QTS 4.4.0 or QuTS hero h4.5.0
   - Container Station 2.0 or later
   - At least 2GB RAM available for containers
   - 5GB free storage space

2. **Network Configuration**
   - Static IP or DDNS configured for your QNAP
   - Ports 8000 and 8080 available (or configure different ports in .env)

## Deployment Steps

### Step 1: Upload Project to QNAP

1. Enable SSH on your QNAP (Control Panel > Telnet/SSH)
2. Upload this project to your QNAP shared folder:
   ```bash
   # From your local machine
   scp -r . admin@YOUR_QNAP_IP:/share/Container/FreshThreads/
   ```

### Step 2: Configure Environment

1. SSH into your QNAP:

   ```bash
   ssh admin@YOUR_QNAP_IP
   cd /share/Container/FreshThreads
   ```

2. Copy and configure environment file:
   ```bash
   cp .env.example .env
   nano .env  # Edit with your actual values
   ```

### Step 3: Deploy with Container Station

#### Option A: Using Container Station GUI

1. Open Container Station in QTS
2. Go to "Create" > "Create Application"
3. Select "Upload" and choose the `docker-compose.yml` file
4. Configure port mappings if needed
5. Click "Create"

#### Option B: Using Command Line

1. SSH into QNAP and navigate to project directory:

   ```bash
   cd /share/Container/FreshThreads
   ```

2. Build and start containers:
   ```bash
   docker-compose up -d
   ```

### Step 4: Verify Deployment

1. Check container status:

   ```bash
   docker-compose ps
   ```

2. View logs:

   ```bash
   docker-compose logs -f backend
   docker-compose logs -f frontend
   ```

3. Test services:
   - Frontend: http://YOUR_QNAP_IP:8080
   - Backend API: http://YOUR_QNAP_IP:8000/health

## Port Configuration

Default ports (configurable in .env):

- Frontend (Nginx): 8080 → 80 (container)
- Backend (Flask): 8000 → 8000 (container)

## Monitoring and Maintenance

### Check Container Health

```bash
docker-compose exec backend curl http://localhost:8000/health
docker-compose exec frontend curl http://localhost/
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Update Deployment

```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

### Backup Configuration

```bash
# Backup environment and logs
tar -czf freshthreads-backup-$(date +%Y%m%d).tar.gz .env logs/
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Modify ports in .env file
2. **Permission denied**: Ensure QNAP user has access to Container folder
3. **Build failures**: Check QNAP has internet access for downloading dependencies
4. **API errors**: Verify environment variables are set correctly

### Debug Commands

```bash
# Check container resource usage
docker stats

# Inspect container configuration
docker-compose config

# Enter container for debugging
docker-compose exec backend /bin/bash
docker-compose exec frontend /bin/sh
```

## QNAP-Specific Optimizations

- Containers use specific subnet (172.20.0.0/16) to avoid conflicts
- Health checks configured for Container Station monitoring
- Restart policies set to `unless-stopped` for reliability
- Logging configured for QNAP log collection
- Resource limits can be set in Container Station GUI

## Security Considerations

- All containers run as non-root users
- Environment variables contain sensitive data - ensure .env is secure
- Consider using QNAP's built-in reverse proxy for SSL termination
- Regular updates recommended for security patches

## Performance Tips

- Consider using QNAP SSD cache for container storage
- Monitor resource usage in Container Station
- Use QNAP's built-in backup solutions for data protection
