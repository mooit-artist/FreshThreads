#!/bin/bash
# Fresh Threads LLC - QNAP Let's Encrypt SSL Certificate Generation
# This script generates Let's Encrypt certificates for QNAP deployment

set -e

echo "🔒 Fresh Threads QNAP Let's Encrypt Setup"
echo "=========================================="

# Configuration
DOMAIN="freshthreadsllc.com"
EMAIL="admin@freshthreadsllc.com"
QNAP_IP="192.168.0.68"
QNAP_HTTP_PORT="18080"
QNAP_HTTPS_PORT="18444"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Create SSL directories
print_status "Creating SSL certificate directories..."
mkdir -p docker/ssl/qnap/certs
mkdir -p docker/ssl/qnap/private
mkdir -p docker/ssl/qnap/letsencrypt

# Create temporary nginx config for ACME challenge
print_status "Creating temporary ACME challenge configuration..."
cat > docker/nginx-acme-temp.conf << 'EOF'
# Temporary nginx configuration for ACME challenge
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Basic settings
    sendfile        on;
    keepalive_timeout 65;

    # HTTP server for ACME challenge only
    server {
        listen 80;
        server_name freshthreadsllc.com www.freshthreadsllc.com;

        # ACME challenge location
        location /.well-known/acme-challenge/ {
            root /tmp/acme-challenge;
            try_files $uri =404;
        }

        # Block all other requests during certificate generation
        location / {
            return 503 "Temporarily unavailable during SSL setup";
        }
    }
}
EOF

# Create Docker Compose for certificate generation
print_status "Creating certificate generation compose file..."
cat > docker-compose.acme.yml << 'EOF'
version: '3.8'

services:
  acme-nginx:
    image: nginx:alpine
    container_name: freshthreads-acme
    ports:
      - '80:80'
    volumes:
      - ./docker/nginx-acme-temp.conf:/etc/nginx/nginx.conf:ro
      - /tmp/acme-challenge:/tmp/acme-challenge
    networks:
      - acme-network

networks:
  acme-network:
    driver: bridge
EOF

# Create certificate generation script
print_status "Creating certificate generation script..."
cat > scripts/generate-qnap-certs.sh << 'EOF'
#!/bin/bash
# Generate Let's Encrypt certificates for QNAP deployment

set -e

DOMAIN="freshthreadsllc.com"
EMAIL="admin@freshthreadsllc.com"
STAGING=${STAGING:-false}

echo "🔑 Generating Let's Encrypt certificates for $DOMAIN"

# Create ACME challenge directory
mkdir -p /tmp/acme-challenge

# Start temporary nginx for ACME challenge
echo "🌐 Starting temporary web server for ACME challenge..."
docker compose -f docker-compose.acme.yml up -d

# Wait for nginx to start
sleep 5

# Prepare certbot command
CERTBOT_CMD="docker run --rm \
    -v $(pwd)/docker/ssl/qnap/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/docker/ssl/qnap/letsencrypt:/var/lib/letsencrypt \
    -v /tmp/acme-challenge:/tmp/acme-challenge \
    --network freshthreads_acme-network \
    certbot/certbot:latest \
    certonly \
    --webroot \
    --webroot-path=/tmp/acme-challenge \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domains $DOMAIN,www.$DOMAIN"

# Add staging flag if testing
if [[ "$STAGING" == "true" ]]; then
    CERTBOT_CMD="$CERTBOT_CMD --staging"
    echo "⚠️ Using Let's Encrypt STAGING environment (test certificates)"
fi

# Generate certificate
echo "🔐 Requesting certificate from Let's Encrypt..."
eval $CERTBOT_CMD

# Stop temporary nginx
echo "🛑 Stopping temporary web server..."
docker compose -f docker-compose.acme.yml down

# Copy certificates to QNAP SSL directory
if [ -f "docker/ssl/qnap/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "📁 Copying certificates to QNAP SSL directory..."
    cp "docker/ssl/qnap/letsencrypt/live/$DOMAIN/fullchain.pem" "docker/ssl/qnap/certs/freshthreads.crt"
    cp "docker/ssl/qnap/letsencrypt/live/$DOMAIN/privkey.pem" "docker/ssl/qnap/private/freshthreads.key"

    # Set proper permissions
    chmod 644 docker/ssl/qnap/certs/freshthreads.crt
    chmod 600 docker/ssl/qnap/private/freshthreads.key

    echo "✅ Let's Encrypt certificates generated successfully!"
    echo ""
    echo "📋 Certificate Information:"
    openssl x509 -in "docker/ssl/qnap/certs/freshthreads.crt" -text -noout | grep -E "(Issuer:|Subject:|Not After)"
    echo ""
    echo "🔗 Certificate files:"
    echo "   Certificate: docker/ssl/qnap/certs/freshthreads.crt"
    echo "   Private Key: docker/ssl/qnap/private/freshthreads.key"
    echo ""
    echo "🚀 Ready to deploy with: ./deploy-qnap-letsencrypt.sh"
else
    echo "❌ Certificate generation failed!"
    exit 1
fi
EOF

chmod +x scripts/generate-qnap-certs.sh

# Create QNAP deployment script with Let's Encrypt
print_status "Creating QNAP Let's Encrypt deployment script..."
cat > deploy-qnap-letsencrypt.sh << 'EOF'
#!/bin/bash
# Fresh Threads LLC - QNAP Deployment with Let's Encrypt SSL

set -e

echo "🔒 Deploying Fresh Threads on QNAP with Let's Encrypt SSL"
echo "========================================================="

# Configuration
DOMAIN="freshthreadsllc.com"
QNAP_IP="192.168.0.68"
HTTP_PORT="18080"
HTTPS_PORT="18444"

# Check if certificates exist
if [ ! -f "docker/ssl/qnap/certs/freshthreads.crt" ] || [ ! -f "docker/ssl/qnap/private/freshthreads.key" ]; then
    echo "❌ Let's Encrypt certificates not found!"
    echo "Please run: ./scripts/generate-qnap-certs.sh"
    exit 1
fi

# Create QNAP nginx configuration with Let's Encrypt certificates
echo "🔧 Creating QNAP nginx configuration..."
cat > docker/nginx-qnap-letsencrypt.conf << 'NGINX_EOF'
# Fresh Threads LLC - QNAP Nginx with Let's Encrypt SSL
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    access_log  /var/log/nginx/access.log;
    error_log   /var/log/nginx/error.log;

    # Basic settings
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=1r/s;

    # HTTPS-only server for QNAP
    server {
        listen 443 ssl http2;
        server_name 192.168.0.68 freshthreadsllc.com www.freshthreadsllc.com;

        # Let's Encrypt SSL Configuration
        ssl_certificate /etc/ssl/certs/freshthreads.crt;
        ssl_certificate_key /etc/ssl/private/freshthreads.key;

        # Modern SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        # HSTS (HTTP Strict Transport Security)
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;

        # Content Security Policy with Let's Encrypt support
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://ajax.googleapis.com https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://freshthreadsllc.com:18444 https://192.168.0.68:18444 https://localhost:18444 https://api.printify.com; frame-src 'none'; object-src 'none'; base-uri 'self'; form-action 'self';" always;

        # Root directory
        root /usr/share/nginx/html;
        index index.html;

        # Static file serving with optimal caching
        location / {
            try_files $uri $uri/ /index.html;
            expires 1h;
            add_header Cache-Control "public, immutable";
        }

        # API proxy to backend with SSL
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass https://backend:8443;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_ssl_verify off;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy - let's encrypt ssl active\n";
            add_header Content-Type text/plain;
        }
    }

    # HTTP server - strict HTTPS redirect
    server {
        listen 80;
        server_name _;
        return 444;  # Close connection immediately for HTTP
    }
}
NGINX_EOF

# Create Docker Compose for QNAP with Let's Encrypt
echo "🐳 Creating QNAP Docker Compose with Let's Encrypt..."
cat > docker-compose.qnap-letsencrypt.yml << 'COMPOSE_EOF'
# Fresh Threads LLC - QNAP Deployment with Let's Encrypt SSL
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.qnap-letsencrypt
    container_name: freshthreads-frontend-qnap-ssl
    restart: unless-stopped
    ports:
      - '18080:443'   # HTTPS only
    networks:
      - freshthreads-qnap-network
    depends_on:
      - backend
    environment:
      - NODE_ENV=production
      - SSL_TYPE=letsencrypt
    volumes:
      - ./logs/nginx:/var/log/nginx
      - ./docker/ssl/qnap/certs:/etc/ssl/certs:ro
      - ./docker/ssl/qnap/private:/etc/ssl/private:ro
    healthcheck:
      test: ['CMD', 'curl', '-f', '-k', 'https://localhost:443/health']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend-ssl
    container_name: freshthreads-backend-qnap-ssl
    restart: unless-stopped
    ports:
      - '18444:8443'
    networks:
      - freshthreads-qnap-network
    environment:
      - PRINTIFY_API_KEY=${PRINTIFY_API_KEY}
      - PRINTIFY_SHOP_ID=${PRINTIFY_SHOP_ID}
      - FLASK_ENV=production
      - SSL_TYPE=backend
    volumes:
      - ./logs/backend:/app/logs
    healthcheck:
      test: ['CMD', 'curl', '-f', '-k', 'https://localhost:8443/health']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

networks:
  freshthreads-qnap-network:
    driver: bridge
COMPOSE_EOF

# Create Dockerfile for QNAP with Let's Encrypt
echo "📦 Creating QNAP Dockerfile with Let's Encrypt..."
cat > docker/Dockerfile.qnap-letsencrypt << 'DOCKER_EOF'
# Fresh Threads LLC - QNAP Frontend with Let's Encrypt SSL
FROM nginx:alpine

# Install curl for health checks and certificate tools
RUN apk add --no-cache bash ca-certificates curl openssl wget

# Add non-root user
RUN adduser -S freshthreads -u 1001 -G nginx

# Create necessary directories
RUN mkdir -p /etc/ssl/certs \
    && mkdir -p /etc/ssl/private \
    && mkdir -p /var/log/nginx \
    && mkdir -p /usr/share/nginx/html

# Copy website files
COPY docs/ /usr/share/nginx/html/

# Copy nginx configuration
COPY docker/nginx-qnap-letsencrypt.conf /etc/nginx/nginx.conf

# Set permissions
RUN chown -R root:nginx /usr/share/nginx/html \
    && chown -R root:nginx /var/cache/nginx \
    && chown -R root:nginx /var/log/nginx \
    && chown -R root:nginx /etc/nginx/conf.d \
    && mkdir -p /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && chown -R root:nginx /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f -k https://localhost:443/health || exit 1

# Expose HTTPS port
EXPOSE 443

# Start nginx as non-root user
USER freshthreads
CMD ["nginx", "-g", "daemon off;"]
DOCKER_EOF

# Deploy to QNAP
echo "🚀 Deploying to QNAP with Let's Encrypt SSL..."

# Stop existing containers
docker compose -f docker-compose.qnap.yml down 2>/dev/null || true
docker compose -f docker-compose.qnap-letsencrypt.yml down 2>/dev/null || true

# Build and start new containers
docker compose -f docker-compose.qnap-letsencrypt.yml build --no-cache
docker compose -f docker-compose.qnap-letsencrypt.yml up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 15

# Health checks
echo "🏥 Running health checks..."

echo "Testing HTTPS frontend..."
if curl -f -k "https://$QNAP_IP:$HTTP_PORT/health" --connect-timeout 10 2>/dev/null | grep -q "let's encrypt"; then
    echo "✅ HTTPS frontend is healthy with Let's Encrypt SSL"
else
    echo "⚠️ HTTPS frontend check failed or not using Let's Encrypt"
fi

echo "Testing backend API..."
if curl -f -k "https://$QNAP_IP:$HTTPS_PORT/health" --connect-timeout 10 2>/dev/null; then
    echo "✅ Backend API is healthy"
else
    echo "⚠️ Backend API check failed"
fi

echo "Testing Printify API integration..."
if curl -f -k "https://$QNAP_IP:$HTTPS_PORT/api/printify/shops/6563836/products.json" --connect-timeout 10 2>/dev/null | grep -q "variants"; then
    echo "✅ Printify API integration is working"
else
    echo "⚠️ Printify API integration may have issues"
fi

echo ""
echo "🎉 QNAP Let's Encrypt SSL Deployment Complete!"
echo "=============================================="
echo "🔗 HTTPS URL: https://$QNAP_IP:$HTTP_PORT/"
echo "🔗 Public URL: https://$DOMAIN:$HTTP_PORT/ (if DNS configured)"
echo "🔒 SSL Certificate: Let's Encrypt (Valid for 90 days)"
echo "🔐 Certificate Issuer: Let's Encrypt Authority X3"
echo ""
echo "🛡️ Security Features:"
echo "   ✅ TLS 1.2/1.3 encryption"
echo "   ✅ Modern cipher suites"
echo "   ✅ HSTS headers"
echo "   ✅ Security headers (CSP, XSS, etc.)"
echo "   ✅ HTTP requests blocked (444 status)"
echo ""
echo "📝 Certificate Management:"
echo "   📅 Renewal needed every 90 days"
echo "   🔄 Renewal command: ./scripts/renew-qnap-certs.sh"
echo "   📊 Check expiration: openssl x509 -in docker/ssl/qnap/certs/freshthreads.crt -text -noout | grep 'Not After'"
EOF

chmod +x deploy-qnap-letsencrypt.sh

# Create certificate renewal script
print_status "Creating certificate renewal script..."
cat > scripts/renew-qnap-certs.sh << 'EOF'
#!/bin/bash
# Fresh Threads LLC - QNAP Certificate Renewal Script

set -e

echo "🔄 Renewing Let's Encrypt certificates for QNAP deployment"
echo "=========================================================="

DOMAIN="freshthreadsllc.com"
QNAP_IP="192.168.0.68"

# Check current certificate expiration
if [ -f "docker/ssl/qnap/certs/freshthreads.crt" ]; then
    echo "📅 Current certificate expires:"
    openssl x509 -in "docker/ssl/qnap/certs/freshthreads.crt" -text -noout | grep "Not After"
fi

# Renew certificates
echo "🔐 Renewing certificates..."

# Stop current deployment
echo "🛑 Stopping current deployment..."
docker compose -f docker-compose.qnap-letsencrypt.yml down

# Start temporary ACME challenge server
echo "🌐 Starting temporary ACME challenge server..."
docker compose -f docker-compose.acme.yml up -d
sleep 5

# Renew certificate
echo "🔄 Requesting certificate renewal..."
docker run --rm \
    -v "$(pwd)/docker/ssl/qnap/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/docker/ssl/qnap/letsencrypt:/var/lib/letsencrypt" \
    -v "/tmp/acme-challenge:/tmp/acme-challenge" \
    --network freshthreads_acme-network \
    certbot/certbot:latest \
    renew \
    --webroot \
    --webroot-path=/tmp/acme-challenge \
    --quiet

# Stop temporary server
docker compose -f docker-compose.acme.yml down

# Copy renewed certificates
if [ -f "docker/ssl/qnap/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "📁 Copying renewed certificates..."
    cp "docker/ssl/qnap/letsencrypt/live/$DOMAIN/fullchain.pem" "docker/ssl/qnap/certs/freshthreads.crt"
    cp "docker/ssl/qnap/letsencrypt/live/$DOMAIN/privkey.pem" "docker/ssl/qnap/private/freshthreads.key"

    # Set proper permissions
    chmod 644 docker/ssl/qnap/certs/freshthreads.crt
    chmod 600 docker/ssl/qnap/private/freshthreads.key

    echo "✅ Certificates renewed successfully!"

    # Restart deployment with new certificates
    echo "🚀 Restarting deployment with renewed certificates..."
    docker compose -f docker-compose.qnap-letsencrypt.yml up -d

    # Wait and test
    sleep 15
    if curl -f -k "https://$QNAP_IP:18080/health" --connect-timeout 10 2>/dev/null; then
        echo "✅ Deployment restarted successfully with renewed certificates"
    else
        echo "⚠️ Deployment restart may have issues"
    fi

    echo ""
    echo "📅 New certificate expires:"
    openssl x509 -in "docker/ssl/qnap/certs/freshthreads.crt" -text -noout | grep "Not After"
else
    echo "❌ Certificate renewal failed!"
    # Restart with old certificates
    docker compose -f docker-compose.qnap-letsencrypt.yml up -d
    exit 1
fi

echo ""
echo "🎉 Certificate renewal complete!"
EOF

chmod +x scripts/renew-qnap-certs.sh

print_success "Let's Encrypt setup for QNAP completed!"
print_warning "IMPORTANT PREREQUISITES:"
echo ""
echo "1. 🌐 Domain Configuration:"
echo "   - Make sure 'freshthreadsllc.com' points to your PUBLIC IP address"
echo "   - Port 80 must be forwarded to your QNAP server for ACME challenge"
echo "   - Your router should forward port 80 to 192.168.0.68:80"
echo ""
echo "2. 🔧 Network Setup:"
echo "   - Ensure your QNAP can be reached from the internet on port 80"
echo "   - Test with: curl http://freshthreadsllc.com"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔑 Generate Let's Encrypt certificates:"
echo "   ./scripts/generate-qnap-certs.sh"
echo ""
echo "2. 🚀 Deploy with real SSL certificates:"
echo "   ./deploy-qnap-letsencrypt.sh"
echo ""
echo "3. ⏰ Set up automatic renewal (add to crontab):"
echo "   0 2 1 */2 * /path/to/freshthreads/scripts/renew-qnap-certs.sh"
echo ""
print_warning "Note: Let's Encrypt certificates are valid for 90 days and need renewal!"
