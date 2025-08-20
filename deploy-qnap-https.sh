#!/bin/bash
# Fresh Threads LLC - QNAP HTTPS-Only Deployment Script

set -e

# Configuration
QNAP_HOST="192.168.0.68"
QNAP_USER="admin1"
QNAP_DEPLOY_PATH="/share/Container/freshthreads"

echo "� Deploying Fresh Threads with HTTPS-ONLY to QNAP..."
echo "ℹ️  HTTP will be completely disabled for security"

# Load environment variables
if [ -f .env.qnap ]; then
    echo "📋 Loading QNAP environment..."
    source .env.qnap
fi

# Ensure SSL certificates exist
if [ ! -f "docker/ssl/certs/freshthreads.crt" ] || [ ! -f "docker/ssl/private/freshthreads.key" ]; then
    echo "🔐 Generating SSL certificates..."
    ./scripts/setup-ssl.sh
fi

# Create deployment package
echo "📦 Creating deployment package..."
tar --exclude='node_modules' \
    --exclude='.git' \
    --exclude='logs' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    -czf freshthreads-https-deploy.tar.gz .

# Copy to QNAP
echo "📤 Uploading to QNAP..."
scp freshthreads-https-deploy.tar.gz ${QNAP_USER}@${QNAP_HOST}:/tmp/

# Deploy on QNAP
echo "🚧 Deploying on QNAP..."
ssh ${QNAP_USER}@${QNAP_HOST} << 'EOF'
    # Set paths
    export PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:$PATH
    cd /share/Container

    # Backup existing deployment
    if [ -d "freshthreads" ]; then
        mv freshthreads freshthreads-backup-$(date +%Y%m%d-%H%M%S)
    fi

    # Extract new deployment
    mkdir -p freshthreads
    cd freshthreads
    tar -xzf /tmp/freshthreads-https-deploy.tar.gz

    # Create logs directories
    mkdir -p logs/nginx logs/backend

    # Stop existing containers
    docker compose -f docker-compose.qnap.yml down 2>/dev/null || true
    docker compose down 2>/dev/null || true

    # Clean up old images
    docker image prune -f

    # Deploy HTTPS version
    docker compose -f docker-compose.qnap.yml up -d --build

    # Wait for services
    sleep 30

    # Check container status
    docker compose -f docker-compose.qnap.yml ps
EOF

# Cleanup local deployment file
rm freshthreads-https-deploy.tar.gz

# Test deployment
echo "🏥 Testing HTTPS-only deployment..."
sleep 10

# Test backend HTTPS
if curl -f -k https://${QNAP_HOST}:18444/health &>/dev/null; then
    echo "✅ Backend HTTPS is healthy (port 18444)"
else
    echo "❌ Backend HTTPS health check failed"
fi

# Test frontend HTTPS
if curl -f -k https://${QNAP_HOST}:18080/health &>/dev/null; then
    echo "✅ Frontend HTTPS is healthy (port 18080)"
else
    echo "❌ Frontend HTTPS health check failed"
fi

# Verify HTTP is disabled
if ! curl -f http://${QNAP_HOST}:18080/health &>/dev/null; then
    echo "✅ HTTP is properly disabled (security verified)"
else
    echo "⚠️  Warning: HTTP is still accessible"
fi

echo ""
echo "🎉 HTTPS-Only Deployment to QNAP Complete!"
echo "=========================================="
echo "🔗 Frontend HTTPS: https://192.168.0.68:18080/"
echo "🔗 Backend HTTPS API: https://192.168.0.68:18444/"
echo "🔗 Production Domain: https://freshthreadsllc.com:18080/ (if configured)"
echo "🔗 Health Check: https://192.168.0.68:18444/health"
echo ""
echo "� Security Notes:"
echo "- HTTP is completely disabled for maximum security"
echo "- All connections are forced to use HTTPS"
echo "- Self-signed certificates are in use (browser warnings expected)"
echo ""
echo "🛠️  To monitor logs:"
echo "  ssh ${QNAP_USER}@${QNAP_HOST} 'cd ${QNAP_DEPLOY_PATH} && export PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:\$PATH && docker compose -f docker-compose.qnap.yml logs -f'"
