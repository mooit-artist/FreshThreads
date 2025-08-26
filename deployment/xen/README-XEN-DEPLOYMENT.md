# 🖥️ FreshThreads XEN VM Deployment Guide

## 📋 **VM Specifications**

### **Recommended Configuration:**

```
OS: Ubuntu 22.04 LTS Server
vCPUs: 2
RAM: 4 GB
Storage: 40 GB
Network: Bridged (gets own IP)
Hostname: freshthreads-vm
```

### **Network Setup:**

```
VM IP: 192.168.1.xxx (assigned by DHCP/static)
Frontend: https://freshthreads.local (port 443)
Backend: https://api.freshthreads.local (port 443)
SSH: Port 22 for management
```

## 🚀 **VM Creation Steps**

### **1. Create VM in XEN:**

- Download Ubuntu 22.04 Server ISO
- Create new VM with specs above
- Configure bridged networking
- Install Ubuntu with minimal packages

### **2. Initial VM Setup:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git docker.io docker-compose nginx certbot

# Enable Docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Reboot to apply changes
sudo reboot
```

### **3. Clone FreshThreads Repository:**

```bash
# Clone your repository
git clone https://github.com/mooit-artist/FreshThreads.git
cd FreshThreads

# Copy environment variables
cp .env.example .env
# Edit .env with your API keys
```

## 🔒 **SSL Certificate Setup**

### **Option 1: Self-Signed (Development)**

```bash
# Generate self-signed certificates
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/freshthreads.key \
  -out /etc/ssl/certs/freshthreads.crt \
  -subj "/CN=freshthreads.local"

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/api.key \
  -out /etc/ssl/certs/api.crt \
  -subj "/CN=api.freshthreads.local"
```

### **Option 2: Let's Encrypt (Production-like)**

```bash
# If you have real domains pointing to the VM
sudo certbot --nginx -d freshthreads.yourdomain.com -d api.freshthreads.yourdomain.com
```

## 🐳 **Docker Deployment**

### **Clean Docker Compose for VM:**

```yaml
version: '3.8'

services:
  # Frontend - Simulates GitHub Pages
  frontend:
    build:
      context: .
      dockerfile: deployment/xen/Dockerfile.frontend
    container_name: freshthreads-frontend
    restart: unless-stopped
    networks:
      - freshthreads

  # Backend - Simulates AWS App Runner
  backend:
    build:
      context: .
      dockerfile: deployment/xen/Dockerfile.backend
    container_name: freshthreads-backend
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
      POSTGRES_PASSWORD: ${DB_PASSWORD:-dev_password_123}
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
```

## 🌐 **Nginx Reverse Proxy**

### **Clean Nginx Configuration:**

```nginx
# Frontend (port 443)
server {
    listen 443 ssl http2;
    server_name freshthreads.local;

    ssl_certificate /etc/ssl/certs/freshthreads.crt;
    ssl_certificate_key /etc/ssl/private/freshthreads.key;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Backend API (port 443, different domain)
server {
    listen 443 ssl http2;
    server_name api.freshthreads.local;

    ssl_certificate /etc/ssl/certs/api.crt;
    ssl_certificate_key /etc/ssl/private/api.key;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name freshthreads.local api.freshthreads.local;
    return 301 https://$server_name$request_uri;
}
```

## 📱 **DNS Setup**

### **Local DNS (Add to your main machine's /etc/hosts):**

```
192.168.1.xxx  freshthreads.local
192.168.1.xxx  api.freshthreads.local
```

### **Or Router DNS (if supported):**

- Add DNS entries in your router's configuration
- All devices on network will resolve the domains

## 🎯 **Benefits of This Setup**

### **✅ Production-Like Environment:**

- Standard ports (80, 443)
- Real SSL certificates
- Proper domain names
- Isolated environment

### **✅ Development Advantages:**

- VM snapshots before changes
- Easy rollback/testing
- Complete environment isolation
- Multiple VMs for different stages

### **✅ Testing Capabilities:**

- Test real HTTPS behavior
- Simulate production networking
- Test with real domains
- Performance testing in isolation

## 🔧 **Management Commands**

### **VM Operations:**

```bash
# SSH into VM
ssh user@192.168.1.xxx

# Check services
sudo systemctl status nginx docker
docker-compose ps

# View logs
docker-compose logs -f
sudo nginx -t && sudo systemctl reload nginx

# Update deployment
git pull
docker-compose down && docker-compose up -d --build
```

### **Snapshot Management:**

```bash
# Create snapshot (from XEN host)
xl save freshthreads-vm freshthreads-snapshot-$(date +%Y%m%d)

# Restore snapshot
xl restore freshthreads-snapshot-YYYYMMDD
```

## 📊 **Testing Workflow**

1. **Development**: Work on your main machine
2. **Deploy**: Push to VM for testing
3. **Test**: Full production-like environment
4. **Snapshot**: Save working state
5. **Deploy to Cloud**: When ready for production

This gives you a **true production simulation** without any port conflicts or compromises!
