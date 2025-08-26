#!/bin/bash

# 🔒 SSL Certificate Generator for QNAP Testing
# Creates self-signed certificates for local HTTPS testing

set -e

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

# Create SSL directory
SSL_DIR="deployment/qnap/ssl"
mkdir -p "$SSL_DIR"

log_info "Generating SSL certificates for local testing..."

# Frontend certificate (freshthreads.qnap.local)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/freshthreads.key" \
    -out "$SSL_DIR/freshthreads.crt" \
    -subj "/C=US/ST=Local/L=Local/O=FreshThreads/CN=freshthreads.qnap.local"

# Backend certificate (api.qnap.local)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/api.key" \
    -out "$SSL_DIR/api.crt" \
    -subj "/C=US/ST=Local/L=Local/O=FreshThreads/CN=api.qnap.local"

# Set permissions
chmod 600 "$SSL_DIR"/*.key
chmod 644 "$SSL_DIR"/*.crt

log_success "SSL certificates generated!"

echo ""
log_warning "Add these entries to your /etc/hosts file (or QNAP DNS):"
echo "192.168.x.x  freshthreads.qnap.local"
echo "192.168.x.x  api.qnap.local"
echo ""
log_warning "Replace 192.168.x.x with your QNAP's IP address"

echo ""
log_info "Certificate files created:"
echo "├── $SSL_DIR/freshthreads.crt"
echo "├── $SSL_DIR/freshthreads.key"
echo "├── $SSL_DIR/api.crt"
echo "└── $SSL_DIR/api.key"
