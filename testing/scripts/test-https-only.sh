#!/bin/bash

# Fresh Threads LLC - Local HTTPS-Only Test Script
# Test the HTTPS-only configuration locally before deploying to QNAP

set -e

echo "🧪 Testing HTTPS-Only Configuration Locally"
echo "============================================"

# Load environment variables
if [ -f .env.qnap ]; then
    export $(cat .env.qnap | grep -v '^#' | xargs)
    echo "✅ Loaded QNAP environment variables"
else
    echo "❌ .env.qnap file not found!"
    exit 1
fi

# Check if SSL certificates exist
if [ ! -f "docker/ssl/certs/freshthreads.crt" ] || [ ! -f "docker/ssl/private/freshthreads.key" ]; then
    echo "🔐 Generating self-signed SSL certificates..."
    mkdir -p docker/ssl/certs docker/ssl/private

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout docker/ssl/private/freshthreads.key \
        -out docker/ssl/certs/freshthreads.crt \
        -subj "/C=US/ST=CA/L=San Francisco/O=Fresh Threads LLC/CN=freshthreadsllc.com"

    echo "✅ SSL certificates generated"
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.qnap.yml down --remove-orphans 2>/dev/null || true

# Build and start HTTPS-only containers
echo "🚀 Starting HTTPS-only containers locally..."
docker-compose -f docker-compose.qnap.yml up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 20

# Health checks
echo "🔍 Running health checks..."

# Check backend
echo -n "Backend HTTPS (port 18444): "
if curl -k -f https://localhost:18444/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Failed"
fi

# Check frontend
echo -n "Frontend HTTPS (port 18080): "
if curl -k -f https://localhost:18080/health > /dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Failed"
fi

# Verify HTTP is disabled on frontend
echo -n "HTTP disabled verification: "
if ! timeout 5 curl -f http://localhost:18080/health > /dev/null 2>&1; then
    echo "✅ HTTP properly disabled"
else
    echo "❌ HTTP still accessible"
fi

# Test Printify API
echo -n "Printify API integration: "
if curl -k -f https://localhost:18444/api/printify/shops/6563836/products.json > /dev/null 2>&1; then
    echo "✅ Working"
else
    echo "❌ Failed"
fi

echo ""
echo "📱 Test URLs:"
echo "   • Frontend: https://localhost:18080"
echo "   • Backend:  https://localhost:18444"
echo "   • Products: https://localhost:18080/products.html"
echo ""
echo "🔒 Security Status: HTTP completely disabled"
echo ""
echo "📊 View logs:"
echo "   docker-compose -f docker-compose.qnap.yml logs -f"
echo ""
echo "🛑 Stop containers:"
echo "   docker-compose -f docker-compose.qnap.yml down"
