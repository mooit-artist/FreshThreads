#!/bin/bash
# Fresh Threads LLC - QNAP HTTPS Deployment Script

set -e

# Configuration
QNAP_HOST="192.168.0.68"
QNAP_USER="admin1"
QNAP_DEPLOY_PATH="/share/Container/freshthreads"

echo "🚀 Deploying Fresh Threads with HTTPS to QNAP..."

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
    docker compose -f docker-compose.ssl.yml down 2>/dev/null || true
    docker compose down 2>/dev/null || true

    # Clean up old images
    docker image prune -f

    # Deploy HTTPS version
    docker compose -f docker-compose.ssl.yml up -d --build

    # Wait for services
    sleep 30

    # Check container status
    docker compose -f docker-compose.ssl.yml ps
EOF

# Cleanup local deployment file
rm freshthreads-https-deploy.tar.gz

# Test deployment
echo "🏥 Testing HTTPS deployment..."
sleep 10

# Test backend HTTPS
if curl -f -k https://${QNAP_HOST}:8443/health &>/dev/null; then
    echo "✅ Backend HTTPS is healthy"
else
    echo "❌ Backend HTTPS health check failed"
fi

# Test frontend HTTPS
if curl -f -k https://${QNAP_HOST}:443/health &>/dev/null; then
    echo "✅ Frontend HTTPS is healthy"
else
    echo "❌ Frontend HTTPS health check failed"
fi

# Test HTTP redirect
if curl -I http://${QNAP_HOST}:80/ 2>/dev/null | grep -q "301"; then
    echo "✅ HTTP to HTTPS redirect is working"
else
    echo "⚠️  HTTP to HTTPS redirect may not be working"
fi

echo ""
echo "🎉 HTTPS Deployment to QNAP Complete!"
echo "======================================="
echo "🔗 Frontend HTTPS: https://freshthreadsllc.com/"
echo "🔗 Backend HTTPS API: https://freshthreadsllc.com:8443/"
echo "🔗 Health Check: https://freshthreadsllc.com:8443/health"
echo ""
echo "📝 Notes:"
echo "- Your domain now properly supports HTTPS"
echo "- All HTTP requests redirect to HTTPS automatically"
echo "- Self-signed certificates are in use (browser warnings expected)"
echo ""
echo "🛠️  To monitor logs:"
echo "  ssh ${QNAP_USER}@${QNAP_HOST} 'cd ${QNAP_DEPLOY_PATH} && export PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:\$PATH && docker compose -f docker-compose.ssl.yml logs -f'"
