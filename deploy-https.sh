#!/bin/bash
# Fresh Threads LLC - HTTPS Deployment Script

set -e

echo "🚀 Deploying Fresh Threads with HTTPS support..."

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

# Create logs directories
mkdir -p logs/nginx logs/backend

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.ssl.yml down 2>/dev/null || true

# Build and start HTTPS containers
echo "🔨 Building and starting HTTPS containers..."
docker-compose -f docker-compose.ssl.yml up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Health checks
echo "🏥 Performing health checks..."

# Check backend HTTPS
if curl -f -k https://localhost:8443/health &>/dev/null; then
    echo "✅ Backend HTTPS is healthy"
else
    echo "❌ Backend HTTPS health check failed"
    docker-compose -f docker-compose.ssl.yml logs backend
fi

# Check frontend HTTPS
if curl -f -k https://localhost:443/health &>/dev/null; then
    echo "✅ Frontend HTTPS is healthy"
else
    echo "❌ Frontend HTTPS health check failed"
    docker-compose -f docker-compose.ssl.yml logs frontend
fi

# Check HTTP redirect
if curl -I http://localhost:80/ 2>/dev/null | grep -q "301"; then
    echo "✅ HTTP to HTTPS redirect is working"
else
    echo "⚠️  HTTP to HTTPS redirect may not be working"
fi

echo ""
echo "🎉 HTTPS Deployment Complete!"
echo "=========================="
echo "🔗 Frontend HTTPS: https://freshthreadsllc.com/"
echo "🔗 Backend HTTPS API: https://freshthreadsllc.com:8443/"
echo "🔗 Health Check: https://freshthreadsllc.com:8443/health"
echo ""
echo "📝 Notes:"
echo "- HTTP requests will automatically redirect to HTTPS"
echo "- Self-signed certificates are used (browser warnings expected)"
echo "- For production, replace with Let's Encrypt certificates"
echo ""
echo "🛠️  To monitor logs:"
echo "  docker-compose -f docker-compose.ssl.yml logs -f"
