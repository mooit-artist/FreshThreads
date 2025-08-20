#!/bin/bash
# SSL Certificate Setup for Fresh Threads LLC

set -e

echo "🔐 Setting up SSL certificates for Fresh Threads LLC..."

# Create SSL directories
mkdir -p docker/ssl/certs
mkdir -p docker/ssl/private

# Generate self-signed certificate for development
echo "📜 Generating self-signed SSL certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout docker/ssl/private/freshthreads.key \
    -out docker/ssl/certs/freshthreads.crt \
    -subj "/C=US/ST=State/L=City/O=Fresh Threads LLC/OU=IT Department/CN=freshthreadsllc.com/emailAddress=admin@freshthreadsllc.com" \
    -addext "subjectAltName=DNS:freshthreadsllc.com,DNS:www.freshthreadsllc.com"

# Set proper permissions
chmod 600 docker/ssl/private/freshthreads.key
chmod 644 docker/ssl/certs/freshthreads.crt

echo "✅ SSL certificates generated successfully!"
echo "📁 Certificate: docker/ssl/certs/freshthreads.crt"
echo "🔑 Private Key: docker/ssl/private/freshthreads.key"
echo ""
echo "⚠️  Note: This is a self-signed certificate for development."
echo "    For production, use Let's Encrypt or a commercial CA."
echo ""
echo "🚀 You can now run: docker-compose up -d"
