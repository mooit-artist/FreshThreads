# FreshThreads QNAP Docker Deployment

This guide will help you deploy FreshThreads to your QNAP NAS using Container Station.

## Quick Start

1. **Test locally first:**

   ```bash
   ./test-docker.sh
   ```

2. **Deploy to QNAP:**
   ```bash
   # Upload project to QNAP and run:
   ./deploy-qnap.sh
   ```

## What's Included

- **Frontend**: Nginx serving the static website
- **Backend**: Flask API proxy for Printify and payment processing
- **Environment Configuration**: Secure credential management
- **Health Monitoring**: Built-in health checks for Container Station
- **QNAP Optimization**: Configured specifically for QNAP Container Station

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │
│   (Nginx)       │    │   (Flask)       │
│   Port: 8080    │────│   Port: 8000    │
│                 │    │                 │
│ • Static Files  │    │ • Printify API  │
│ • Product Pages │    │ • Stripe API    │
│ • Checkout      │    │ • CORS Proxy    │
└─────────────────┘    └─────────────────┘
```

## Features

✅ **CORS Resolution**: Backend proxy eliminates CORS issues
✅ **Environment Detection**: Automatically adapts to local vs QNAP
✅ **Secure Credentials**: Environment-based secret management
✅ **Health Monitoring**: Container Station integration
✅ **Easy Deployment**: One-command QNAP deployment
✅ **Production Ready**: Optimized for QNAP performance

## Prerequisites

- QNAP NAS with Container Station installed
- 2GB+ RAM available for containers
- 5GB+ free storage space
- Network ports 8000 and 8080 available

## Configuration

### Environment Variables (.env)

```bash
# Printify Configuration
PRINTIFY_API_KEY=your_printify_jwt_token
PRINTIFY_SHOP_ID=your_shop_id

# Stripe Configuration
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...

# Port Configuration (optional)
FRONTEND_PORT=8080
BACKEND_PORT=8000
```

### API Key Setup

1. **Printify**: Generate JWT token in Printify dashboard
2. **Stripe**: Get live keys from Stripe dashboard
3. **Shop ID**: Found in Printify store settings

## Deployment Process

### Local Testing

```bash
# 1. Configure environment
cp .env.example .env
nano .env

# 2. Test locally
./test-docker.sh

# 3. Verify functionality
open http://localhost:8080
```

### QNAP Deployment

```bash
# 1. Upload to QNAP
scp -r . admin@QNAP_IP:/share/Container/FreshThreads/

# 2. SSH into QNAP
ssh admin@QNAP_IP
cd /share/Container/FreshThreads

# 3. Deploy
./deploy-qnap.sh
```

## Accessing Your Deployment

After successful deployment:

- **Website**: `http://YOUR_QNAP_IP:8080`
- **API Health**: `http://YOUR_QNAP_IP:8000/health`
- **Container Logs**: Container Station > Applications > FreshThreads

## Monitoring

### Container Station GUI

1. Open Container Station
2. Go to Applications
3. Click on FreshThreads
4. Monitor resource usage and logs

### Command Line

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Check resources
docker stats
```

## Troubleshooting

### Common Issues

**Port Conflicts**

```bash
# Change ports in .env
FRONTEND_PORT=8081
BACKEND_PORT=8001
```

**Permission Issues**

```bash
# Fix container permissions
sudo chown -R admin:administrators /share/Container/FreshThreads
```

**API Errors**

```bash
# Check environment variables
docker-compose exec backend env | grep PRINTIFY
```

**Container Won't Start**

```bash
# Check detailed logs
docker-compose logs backend
docker-compose logs frontend
```

### Debug Commands

```bash
# Enter backend container
docker-compose exec backend /bin/bash

# Test API directly
curl http://localhost:8000/health

# Check frontend files
docker-compose exec frontend ls -la /usr/share/nginx/html
```

## Updating

```bash
# Pull latest changes
git pull

# Redeploy
docker-compose down
docker-compose up -d --build
```

## Backup

```bash
# Backup configuration and logs
tar -czf freshthreads-backup-$(date +%Y%m%d).tar.gz .env logs/
```

## Security

- All containers run as non-root users
- Environment variables stored securely
- HTTPS termination available via QNAP reverse proxy
- Regular security updates recommended

## Support

For issues:

1. Check Container Station logs
2. Review troubleshooting section
3. Test with `./test-docker.sh` locally
4. Check QNAP system resources

## Next Steps

After deployment:

1. Set up QNAP reverse proxy for HTTPS
2. Configure automated backups
3. Set up monitoring alerts
4. Consider QNAP SSD cache for performance
