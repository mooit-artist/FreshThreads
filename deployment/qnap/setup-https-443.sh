#!/bin/bash

# 🔒 HTTPS Setup for QNAP - Alternative ports (avoiding QNAP's 443)
# Frontend: 8443, Backend: 9443

set -e

echo "🔒 Setting up HTTPS on alternative ports (8443/9443)..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Generate SSL certificates
log_info "Generating SSL certificates..."
chmod +x deployment/qnap/generate-ssl.sh
./deployment/qnap/generate-ssl.sh

# Update frontend API configuration
log_info "Updating frontend to use HTTPS API..."
cat > docs/config/production.js << 'EOF'
// Production configuration for HTTPS testing (alternative ports)
window.FRESH_THREADS_CONFIG = {
    API_BASE_URL: 'https://api.qnap.local:9443',
    FRONTEND_URL: 'https://freshthreads.qnap.local:8443',
    ENVIRONMENT: 'qnap-production',
    DEBUG: false,
    HTTPS_ENABLED: true
};
EOF

# Deploy with HTTPS configuration
log_info "Deploying with HTTPS configuration..."
docker-compose -f deployment/qnap/docker-compose.yml down 2>/dev/null || true
docker-compose -f deployment/qnap/docker-compose.yml up -d --build

# Wait for startup
sleep 15

echo ""
log_success "🎉 HTTPS setup complete!"
echo ""
echo "📋 Services accessible on alternative HTTPS ports:"
echo "Frontend: https://freshthreads.qnap.local:8443"
echo "Backend:  https://api.qnap.local:9443"
echo ""
echo "🔧 Required DNS Setup:"
echo "Add to /etc/hosts (replace with your QNAP IP):"
echo "192.168.1.xxx  freshthreads.qnap.local"
echo "192.168.1.xxx  api.qnap.local"
echo ""
log_warning "QNAP management remains on port 443"
log_warning "Accept the self-signed certificate warnings in your browser"
