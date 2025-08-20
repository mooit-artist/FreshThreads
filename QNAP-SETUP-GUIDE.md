# QNAP API Access Setup Guide

# For jorgnas71d098.server.lan (192.168.0.68)

## 📋 Current Status

- ✅ QNAP is network accessible at 192.168.0.68
- ✅ Web interface available on port 8080
- ⚠️ SSH access needs setup (port 22 currently refused)
- ❌ Container Station needs installation
- ℹ️ FreshThreads not yet deployed

## 🚀 Setup Steps

### Step 1: Enable SSH Access on QNAP

1. **Access QNAP Web Interface:**

   ```
   http://jorgnas71d098.server.lan:8080
   or
   http://192.168.0.68:8080
   ```

2. **Enable SSH Service:**
   - Login with your admin credentials
   - Go to: **Control Panel** → **Telnet/SSH**
   - Check "Allow SSH connection"
   - Set SSH port to 22 (default)
   - Apply settings

3. **Test SSH Connection:**
   ```bash
   ssh admin@192.168.0.68
   # You'll be prompted for password
   ```

### Step 2: Install Container Station

1. **Open App Center:**
   - In QNAP web interface
   - Go to **App Center**

2. **Install Container Station:**
   - Search for "Container Station"
   - Click Install
   - Wait for installation to complete

3. **Verify Installation:**
   ```bash
   # After SSH is enabled
   ssh admin@192.168.0.68 "docker --version"
   ```

### Step 3: Setup SSH Key Authentication (Optional but Recommended)

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy key to QNAP
ssh-copy-id admin@192.168.0.68

# Test keyless access
ssh admin@192.168.0.68 "echo 'SSH key authentication working'"
```

### Step 4: Deploy FreshThreads

Once SSH and Container Station are ready:

```bash
# Test QNAP access again
./test-qnap-access.sh

# Deploy to QNAP
./deploy-to-qnap.sh
```

## 🔧 Manual Deployment (Alternative)

If the automated script doesn't work, here's the manual process:

### 1. Create Project Directory on QNAP

```bash
# SSH into QNAP
ssh admin@192.168.0.68

# Create directories
mkdir -p /share/Container/FreshThreads
mkdir -p /share/Container/backups/FreshThreads
cd /share/Container/FreshThreads
```

### 2. Upload Project Files

From your local machine:

```bash
# Create deployment package
tar --exclude='.git' --exclude='node_modules' --exclude='.venv' -czf freshthreads.tar.gz .

# Upload to QNAP
scp freshthreads.tar.gz admin@192.168.0.68:/share/Container/FreshThreads/

# SSH in and extract
ssh admin@192.168.0.68
cd /share/Container/FreshThreads
tar -xzf freshthreads.tar.gz
rm freshthreads.tar.gz
```

### 3. Configure Environment

```bash
# On QNAP, create .env file
cat > .env << 'EOF'
PRINTIFY_API_KEY=your_printify_key_here
STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_public_key_here

# Port Configuration
FRONTEND_PORT=8080
BACKEND_PORT=8000

# Production Settings
NODE_ENV=production
FLASK_ENV=production
EOF
```

### 4. Deploy with Docker Compose

```bash
# Build and start containers
docker-compose up -d --build

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## 📊 Access URLs After Deployment

- **Frontend Website:** http://192.168.0.68:8080
- **Backend API:** http://192.168.0.68:8000
- **API Health Check:** http://192.168.0.68:8000/health
- **Printify Products:** http://192.168.0.68:8000/api/printify/shops/6563836/products.json

## 🔍 Monitoring Commands

```bash
# Check container status
ssh admin@192.168.0.68 "cd /share/Container/FreshThreads && docker-compose ps"

# View logs
ssh admin@192.168.0.68 "cd /share/Container/FreshThreads && docker-compose logs -f backend"

# Restart services
ssh admin@192.168.0.68 "cd /share/Container/FreshThreads && docker-compose restart"

# Stop services
ssh admin@192.168.0.68 "cd /share/Container/FreshThreads && docker-compose down"
```

## 🚨 Troubleshooting

### SSH Connection Refused

- Enable SSH in QNAP Control Panel → Telnet/SSH
- Check if port 22 is blocked by firewall
- Try default QNAP SSH port (usually 22)

### Container Station Not Found

- Install from App Center
- Ensure QTS version supports Container Station
- Check available storage space

### Docker Compose Fails

- Verify .env file has correct API keys
- Check port conflicts (8000, 8080)
- Ensure sufficient system resources

### API Not Responding

- Check container logs: `docker-compose logs backend`
- Verify environment variables are loaded
- Test local API: `curl http://localhost:8000/health`

## 📱 Next Steps

1. Complete the setup steps above
2. Run `./test-qnap-access.sh` to verify
3. Deploy with `./deploy-to-qnap.sh`
4. Access your site at http://192.168.0.68:8080

## 🔐 Security Notes

- Use SSH keys instead of passwords
- Consider changing default SSH port
- Set up QNAP firewall rules
- Use HTTPS with SSL certificates in production
- Keep QNAP firmware updated
