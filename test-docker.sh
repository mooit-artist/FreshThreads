#!/bin/bash

# Local Docker Test Script for FreshThreads
# Test the Docker setup before deploying to QNAP

echo "🧪 Testing FreshThreads Docker Setup Locally"
echo "============================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "📋 Creating .env file from example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your actual credentials"
    echo "nano .env"
    echo ""
    echo "Required variables:"
    echo "- PRINTIFY_API_KEY"
    echo "- STRIPE_SECRET_KEY"
    echo "- STRIPE_PUBLISHABLE_KEY"
    exit 1
fi

# Build and start containers
echo "🔨 Building and starting containers..."
docker-compose down --remove-orphans
docker-compose up -d --build

# Wait for containers to start
echo "⏳ Waiting for containers to start..."
sleep 15

# Check container status
echo "📊 Container Status:"
docker-compose ps

# Test backend health
echo ""
echo "🔍 Testing Backend Health..."
BACKEND_PORT=$(grep BACKEND_PORT .env | cut -d'=' -f2 || echo "8000")
if curl -f "http://localhost:${BACKEND_PORT}/health" 2>/dev/null; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed"
    echo "Backend logs:"
    docker-compose logs backend --tail=20
fi

# Test frontend
echo ""
echo "🌐 Testing Frontend..."
FRONTEND_PORT=$(grep FRONTEND_PORT .env | cut -d'=' -f2 || echo "8080")
if curl -f "http://localhost:${FRONTEND_PORT}/" 2>/dev/null > /dev/null; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend accessibility check failed"
    echo "Frontend logs:"
    docker-compose logs frontend --tail=20
fi

# Display access URLs
echo ""
echo "🎉 Test Results:"
echo "=================="
echo "Frontend: http://localhost:${FRONTEND_PORT}"
echo "Backend:  http://localhost:${BACKEND_PORT}"
echo "Health:   http://localhost:${BACKEND_PORT}/health"
echo ""
echo "📝 Useful commands:"
echo "View logs:    docker-compose logs -f"
echo "Stop:         docker-compose down"
echo "Restart:      docker-compose restart"
echo ""
echo "🚀 If tests pass, you can deploy to QNAP using:"
echo "./deploy-qnap.sh"
