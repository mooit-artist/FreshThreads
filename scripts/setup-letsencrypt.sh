#!/bin/bash
# Fresh Threads LLC - Let's Encrypt SSL Certificate Setup
# This script sets up automatic SSL certificate generation and renewal

set -e

echo "🔒 Fresh Threads Let's Encrypt SSL Setup"
echo "========================================"

# Configuration
DOMAIN="freshthreadsllc.com"
EMAIL="admin@freshthreadsllc.com"  # Change this to your actual email
STAGING=${STAGING:-false}  # Set to true for testing

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   exit 1
fi

# Check if domain is accessible
print_status "Checking domain accessibility..."
if ! curl -s --connect-timeout 5 "http://$DOMAIN" > /dev/null 2>&1; then
    print_warning "Domain $DOMAIN may not be accessible from the internet"
    print_warning "Make sure your domain points to this server's public IP"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create necessary directories
print_status "Creating SSL directories..."
mkdir -p docker/ssl/letsencrypt
mkdir -p docker/ssl/certs
mkdir -p docker/ssl/private
mkdir -p scripts/ssl

# Create certbot configuration
print_status "Creating Certbot configuration..."
cat > docker/ssl/letsencrypt/cli.ini << EOF
# Let's Encrypt CLI configuration for Fresh Threads LLC
email = $EMAIL
text = True
agree-tos = True
non-interactive = True
expand = True
EOF

if [[ "$STAGING" == "true" ]]; then
    echo "server = https://acme-staging-v02.api.letsencrypt.org/directory" >> docker/ssl/letsencrypt/cli.ini
    print_warning "Using Let's Encrypt STAGING environment (test certificates)"
fi

# Create certificate generation script
print_status "Creating certificate generation script..."
cat > scripts/ssl/generate-certs.sh << 'EOF'
#!/bin/bash
# Certificate generation script for Fresh Threads

set -e

DOMAIN=${1:-freshthreadsllc.com}
EMAIL=${2:-admin@freshthreadsllc.com}
WEBROOT=${3:-/tmp/acme-challenge}

echo "🔒 Generating Let's Encrypt certificate for $DOMAIN"

# Create webroot directory
mkdir -p "$WEBROOT"

# Generate certificate using certbot
docker run --rm \
    -v "$(pwd)/docker/ssl/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/docker/ssl/letsencrypt:/var/lib/letsencrypt" \
    -v "$WEBROOT:/tmp/acme-challenge" \
    -p 80:80 \
    certbot/certbot:latest \
    certonly \
    --standalone \
    --preferred-challenges http \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --domains "$DOMAIN,www.$DOMAIN"

# Copy certificates to docker ssl directory
if [ -f "docker/ssl/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    cp "docker/ssl/letsencrypt/live/$DOMAIN/fullchain.pem" "docker/ssl/certs/freshthreads.crt"
    cp "docker/ssl/letsencrypt/live/$DOMAIN/privkey.pem" "docker/ssl/private/freshthreads.key"

    # Set proper permissions
    chmod 644 docker/ssl/certs/freshthreads.crt
    chmod 600 docker/ssl/private/freshthreads.key

    echo "✅ Certificates generated and installed successfully!"
    echo "📋 Certificate details:"
    openssl x509 -in "docker/ssl/certs/freshthreads.crt" -text -noout | grep -E "(Subject:|Issuer:|Not After)"
else
    echo "❌ Certificate generation failed!"
    exit 1
fi
EOF

chmod +x scripts/ssl/generate-certs.sh

# Create certificate renewal script
print_status "Creating certificate renewal script..."
cat > scripts/ssl/renew-certs.sh << 'EOF'
#!/bin/bash
# Certificate renewal script for Fresh Threads

set -e

DOMAIN=${1:-freshthreadsllc.com}

echo "🔄 Renewing Let's Encrypt certificates for $DOMAIN"

# Renew certificates
docker run --rm \
    -v "$(pwd)/docker/ssl/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/docker/ssl/letsencrypt:/var/lib/letsencrypt" \
    certbot/certbot:latest \
    renew \
    --quiet

# Copy renewed certificates
if [ -f "docker/ssl/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    cp "docker/ssl/letsencrypt/live/$DOMAIN/fullchain.pem" "docker/ssl/certs/freshthreads.crt"
    cp "docker/ssl/letsencrypt/live/$DOMAIN/privkey.pem" "docker/ssl/private/freshthreads.key"

    # Set proper permissions
    chmod 644 docker/ssl/certs/freshthreads.crt
    chmod 600 docker/ssl/private/freshthreads.key

    echo "✅ Certificates renewed successfully!"

    # Restart containers to use new certificates
    if [ -f "docker-compose.qnap.yml" ]; then
        echo "🔄 Restarting containers to use new certificates..."
        docker compose -f docker-compose.qnap.yml restart
    fi
else
    echo "⚠️ No certificates found to renew"
fi
EOF

chmod +x scripts/ssl/renew-certs.sh

# Create ACME challenge nginx configuration
print_status "Creating ACME challenge configuration..."
cat > docker/nginx-letsencrypt.conf << 'EOF'
# Fresh Threads LLC - Nginx Configuration with Let's Encrypt Support
# This configuration supports ACME challenge for certificate generation

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

    # HTTP server for ACME challenge and redirects
    server {
        listen 80;
        server_name freshthreadsllc.com www.freshthreadsllc.com;

        # ACME challenge location
        location /.well-known/acme-challenge/ {
            root /tmp/acme-challenge;
            try_files $uri =404;
        }

        # Redirect all other HTTP requests to HTTPS
        location / {
            return 301 https://$server_name$request_uri;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name freshthreadsllc.com www.freshthreadsllc.com;

        # SSL Configuration
        ssl_certificate /etc/ssl/certs/freshthreads.crt;
        ssl_certificate_key /etc/ssl/private/freshthreads.key;

        # Modern SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        # HSTS (HTTP Strict Transport Security)
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;

        # Content Security Policy
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com https://ajax.googleapis.com https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self' https://freshthreadsllc.com:18444 https://192.168.0.68:18444 https://localhost:18444 https://api.printify.com https://fonts.googleapis.com; frame-src 'none'; object-src 'none'; base-uri 'self'; form-action 'self';" always;

        # Root directory
        root /usr/share/nginx/html;
        index index.html;

        # Static file serving
        location / {
            try_files $uri $uri/ /index.html;
            expires 1h;
            add_header Cache-Control "public, immutable";
        }

        # API proxy to backend
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
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Create Docker Compose file with Let's Encrypt support
print_status "Creating Docker Compose configuration for Let's Encrypt..."
cat > docker-compose.letsencrypt.yml << 'EOF'
# Fresh Threads LLC - Docker Compose with Let's Encrypt SSL
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.letsencrypt
    container_name: freshthreads-frontend-ssl
    restart: unless-stopped
    ports:
      - '80:80'     # HTTP for ACME challenge
      - '443:443'   # HTTPS
    networks:
      - freshthreads-network
    depends_on:
      - backend
    environment:
      - NODE_ENV=production
    volumes:
      - ./logs/nginx:/var/log/nginx
      - ./docker/ssl/certs:/etc/ssl/certs:ro
      - ./docker/ssl/private:/etc/ssl/private:ro
      - /tmp/acme-challenge:/tmp/acme-challenge
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
    container_name: freshthreads-backend-ssl
    restart: unless-stopped
    ports:
      - '18444:8443'
    networks:
      - freshthreads-network
    environment:
      - PRINTIFY_API_KEY=${PRINTIFY_API_KEY}
      - PRINTIFY_SHOP_ID=${PRINTIFY_SHOP_ID}
      - FLASK_ENV=production
    volumes:
      - ./logs/backend:/app/logs
    healthcheck:
      test: ['CMD', 'curl', '-f', '-k', 'https://localhost:8443/health']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

networks:
  freshthreads-network:
    driver: bridge
EOF

# Create Dockerfile for Let's Encrypt frontend
print_status "Creating Dockerfile with Let's Encrypt support..."
cat > docker/Dockerfile.letsencrypt << 'EOF'
# Fresh Threads LLC - Frontend with Let's Encrypt SSL Support
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache bash ca-certificates curl openssl wget

# Add non-root user
RUN adduser -S freshthreads -u 1001 -G nginx

# Create necessary directories
RUN mkdir -p /etc/ssl/certs \
    && mkdir -p /etc/ssl/private \
    && mkdir -p /var/log/nano_agent \
    && mkdir -p /tmp/acme-challenge

# Copy website files
COPY docs/ /usr/share/nginx/html/

# Copy nginx configuration
COPY docker/nginx-letsencrypt.conf /etc/nginx/nginx.conf

# Copy startup script
COPY docker/start-nginx-letsencrypt.sh /usr/local/bin/start-nginx.sh

# Set permissions
RUN chown -R root:nginx /usr/share/nginx/html \
    && chown -R root:nginx /var/cache/nginx \
    && chown -R root:nginx /var/log/nginx \
    && chown -R root:nginx /etc/nginx/conf.d \
    && chmod +x /usr/local/bin/start-nginx.sh \
    && mkdir -p /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && chown -R root:nginx /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && chown -R root:nginx /tmp/acme-challenge

# Switch to non-root user
USER freshthreads

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f -k https://localhost:443/health || exit 1

# Expose ports
EXPOSE 80 443

# Start nginx
CMD ["/usr/local/bin/start-nginx.sh"]
EOF

# Create startup script for Let's Encrypt nginx
print_status "Creating nginx startup script..."
cat > docker/start-nginx-letsencrypt.sh << 'EOF'
#!/bin/bash
set -e

echo "🌐 Starting Fresh Threads Frontend with Let's Encrypt SSL..."

# Check if SSL certificates exist
if [ ! -f "/etc/ssl/certs/freshthreads.crt" ] || [ ! -f "/etc/ssl/private/freshthreads.key" ]; then
    echo "⚠️ SSL certificates not found, using self-signed certificates temporarily"

    # Generate temporary self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /tmp/temp.key \
        -out /tmp/temp.crt \
        -subj "/C=US/ST=State/L=City/O=Fresh Threads LLC/OU=IT/CN=freshthreadsllc.com"

    # Copy to expected locations (if writable)
    if [ -w "/etc/ssl/private" ] && [ -w "/etc/ssl/certs" ]; then
        cp /tmp/temp.key /etc/ssl/private/freshthreads.key
        cp /tmp/temp.crt /etc/ssl/certs/freshthreads.crt
        chmod 600 /etc/ssl/private/freshthreads.key
        chmod 644 /etc/ssl/certs/freshthreads.crt
    fi
fi

# Test nginx configuration
echo "🔧 Testing nginx configuration..."
nginx -t

# Start nginx
echo "🚀 Starting nginx..."
exec nginx -g "daemon off;"
EOF

chmod +x docker/start-nginx-letsencrypt.sh

# Create deployment script
print_status "Creating Let's Encrypt deployment script..."
cat > deploy-letsencrypt.sh << 'EOF'
#!/bin/bash
# Fresh Threads LLC - Let's Encrypt Deployment Script

set -e

echo "🔒 Deploying Fresh Threads with Let's Encrypt SSL"
echo "================================================"

DOMAIN=${1:-freshthreadsllc.com}
EMAIL=${2:-admin@freshthreadsllc.com}

# Step 1: Generate certificates
echo "📋 Step 1: Generating Let's Encrypt certificates..."
if [ ! -f "docker/ssl/certs/freshthreads.crt" ]; then
    echo "🔑 Obtaining SSL certificates from Let's Encrypt..."
    ./scripts/ssl/generate-certs.sh "$DOMAIN" "$EMAIL"
else
    echo "✅ SSL certificates already exist"
fi

# Step 2: Build and deploy
echo "📋 Step 2: Building and deploying application..."
docker compose -f docker-compose.letsencrypt.yml down || true
docker compose -f docker-compose.letsencrypt.yml build --no-cache
docker compose -f docker-compose.letsencrypt.yml up -d

# Step 3: Health checks
echo "📋 Step 3: Running health checks..."
sleep 10

echo "🏥 Testing HTTPS endpoint..."
if curl -f -k "https://localhost:443/health" > /dev/null 2>&1; then
    echo "✅ HTTPS endpoint is healthy"
else
    echo "❌ HTTPS endpoint check failed"
fi

echo "🏥 Testing backend API..."
if curl -f -k "https://localhost:18444/health" > /dev/null 2>&1; then
    echo "✅ Backend API is healthy"
else
    echo "❌ Backend API check failed"
fi

echo ""
echo "🎉 Let's Encrypt SSL Deployment Complete!"
echo "========================================"
echo "🔗 Your site: https://$DOMAIN/"
echo "🔒 SSL Certificate: Let's Encrypt (Valid for 90 days)"
echo ""
echo "📝 Next Steps:"
echo "1. Set up automatic renewal: crontab -e"
echo "   Add: 0 12 * * * /path/to/freshthreads/scripts/ssl/renew-certs.sh"
echo "2. Test your SSL rating: https://www.ssllabs.com/ssltest/"
echo "3. Monitor certificate expiration"
EOF

chmod +x deploy-letsencrypt.sh

print_success "Let's Encrypt SSL setup created successfully!"
print_status "Next steps:"
echo ""
echo "1. 🌐 Make sure your domain points to this server:"
echo "   freshthreadsllc.com -> YOUR_PUBLIC_IP"
echo ""
echo "2. 🔑 Generate SSL certificates:"
echo "   ./scripts/ssl/generate-certs.sh freshthreadsllc.com your-email@example.com"
echo ""
echo "3. 🚀 Deploy with Let's Encrypt:"
echo "   ./deploy-letsencrypt.sh freshthreadsllc.com your-email@example.com"
echo ""
echo "4. ⏰ Set up automatic renewal (add to crontab):"
echo "   0 12 * * * /path/to/freshthreads/scripts/ssl/renew-certs.sh"
echo ""
print_warning "Important: Make sure port 80 is accessible from the internet for ACME challenge!"
