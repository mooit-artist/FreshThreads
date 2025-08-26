#!/bin/bash

# 🖥️ XEN VM Setup Script for FreshThreads
# Run this script inside your Ubuntu VM after creation

set -e

echo "🚀 Setting up FreshThreads in XEN VM..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Get VM IP address
VM_IP=$(hostname -I | awk '{print $1}')

log_info "VM IP Address: $VM_IP"

# Update system
log_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
log_info "Installing Docker, Nginx, and utilities..."
sudo apt install -y \
    curl \
    wget \
    git \
    docker.io \
    docker-compose \
    nginx \
    certbot \
    python3-certbot-nginx \
    htop \
    unzip \
    jq

# Configure Docker
log_info "Configuring Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"

# Create directories
log_info "Creating application directories..."
mkdir -p /home/"$USER"/freshthreads
cd /home/"$USER"/freshthreads

# Generate SSL certificates
log_info "Generating SSL certificates..."
sudo mkdir -p /etc/ssl/freshthreads

# Frontend certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/freshthreads/frontend.key \
    -out /etc/ssl/freshthreads/frontend.crt \
    -subj "/C=US/ST=Local/L=Local/O=FreshThreads/CN=freshthreads.local"

# Backend certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/freshthreads/backend.key \
    -out /etc/ssl/freshthreads/backend.crt \
    -subj "/C=US/ST=Local/L=Local/O=FreshThreads/CN=api.freshthreads.local"

# Set permissions
sudo chmod 600 /etc/ssl/freshthreads/*.key
sudo chmod 644 /etc/ssl/freshthreads/*.crt

# Configure Nginx
log_info "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/freshthreads > /dev/null << 'EOF'
# Frontend - Simulates GitHub Pages
server {
    listen 443 ssl http2;
    server_name freshthreads.local;

    ssl_certificate /etc/ssl/freshthreads/frontend.crt;
    ssl_certificate_key /etc/ssl/freshthreads/frontend.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Backend API - Simulates AWS App Runner
server {
    listen 443 ssl http2;
    server_name api.freshthreads.local;

    ssl_certificate /etc/ssl/freshthreads/backend.crt;
    ssl_certificate_key /etc/ssl/freshthreads/backend.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS headers
        add_header Access-Control-Allow-Origin "https://freshthreads.local" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Accept, Authorization, Content-Type" always;
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name freshthreads.local api.freshthreads.local;
    return 301 https://$server_name$request_uri;
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/freshthreads /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t && sudo systemctl reload nginx
sudo systemctl enable nginx

# Create Docker Compose configuration
log_info "Creating Docker Compose configuration..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Frontend - Simulates GitHub Pages
  frontend:
    image: nginx:alpine
    container_name: freshthreads-frontend
    ports:
      - "3000:80"
    volumes:
      - ./docs:/usr/share/nginx/html:ro
      - ./deployment/xen/frontend-nginx.conf:/etc/nginx/conf.d/default.conf
    restart: unless-stopped
    networks:
      - freshthreads

  # Backend - Simulates AWS App Runner
  backend:
    build:
      context: .
      dockerfile: deployment/xen/Dockerfile.backend
    container_name: freshthreads-backend
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - PORT=8000
    env_file:
      - .env
    restart: unless-stopped
    networks:
      - freshthreads

  # Database - Simulates AWS RDS
  database:
    image: postgres:15-alpine
    container_name: freshthreads-db
    environment:
      POSTGRES_DB: freshthreads
      POSTGRES_USER: freshthreads
      POSTGRES_PASSWORD: dev_password_123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    networks:
      - freshthreads

networks:
  freshthreads:
    driver: bridge

volumes:
  postgres_data:
EOF

# Create deployment script
log_info "Creating deployment script..."
cat > deploy.sh << 'EOF'
#!/bin/bash

echo "🚀 Deploying FreshThreads..."

# Pull latest changes
git pull

# Rebuild and restart containers
docker-compose down
docker-compose up -d --build

# Wait for services
sleep 10

# Test services
echo "Testing services..."
curl -k -s https://freshthreads.local/health || echo "Frontend not ready"
curl -k -s https://api.freshthreads.local/health || echo "Backend not ready"

echo "✅ Deployment complete!"
echo "Frontend: https://freshthreads.local"
echo "Backend: https://api.freshthreads.local"
EOF

chmod +x deploy.sh

# Create health check script
cat > health-check.sh << 'EOF'
#!/bin/bash

echo "🏥 FreshThreads Health Check"
echo "============================"

# Check Nginx
if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx: Running"
else
    echo "❌ Nginx: Not running"
fi

# Check Docker containers
echo ""
echo "Docker Containers:"
docker-compose ps

# Check URLs
echo ""
echo "Service Health:"
curl -k -s https://freshthreads.local/health > /dev/null && echo "✅ Frontend: Healthy" || echo "❌ Frontend: Not responding"
curl -k -s https://api.freshthreads.local/health > /dev/null && echo "✅ Backend: Healthy" || echo "❌ Backend: Not responding"

# System resources
echo ""
echo "System Resources:"
free -h | head -2
df -h / | tail -1
EOF

chmod +x health-check.sh

echo ""
log_success "🎉 XEN VM setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Clone FreshThreads repository: git clone https://github.com/mooit-artist/FreshThreads.git ."
echo "2. Copy your .env file with API keys"
echo "3. Run: ./deploy.sh"
echo ""
echo "📱 Add to your main machine's /etc/hosts:"
echo "$VM_IP  freshthreads.local"
echo "$VM_IP  api.freshthreads.local"
echo ""
echo "🌐 Access URLs:"
echo "Frontend: https://freshthreads.local"
echo "Backend: https://api.freshthreads.local"
echo ""
log_warning "Remember to reboot to complete Docker setup: sudo reboot"
