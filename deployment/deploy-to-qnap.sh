#!/bin/bash

# FreshThreads QNAP Deployment Script for jorgnas71d098.server.lan
# Customized deployment for your specific QNAP NAS

set -e

# Load QNAP configuration
source .env.qnap

# QNAP-specific paths
PROJECT_PATH="/share/Container/freshthreads"
BACKUP_PATH="/share/Container/freshthreads-backup"
DOCKER_PATH="/share/CACHEDEV1_DATA/.qpkg/container-station/bin"

echo "🚀 Deploying FreshThreads to QNAP: $QNAP_HOSTNAME"
echo "=============================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Test QNAP connectivity
test_qnap_connection() {
    log_info "Testing connection to QNAP..."
    if ping -c 1 "$QNAP_IP" > /dev/null 2>&1; then
        log_success "QNAP is reachable at $QNAP_IP"
    else
        log_error "Cannot reach QNAP at $QNAP_IP"
        exit 1
    fi
}

# Check SSH access
test_ssh_access() {
    log_info "Testing SSH access..."
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$QNAP_SSH_USER"@"$QNAP_IP" "echo 'SSH connection successful'" 2>/dev/null; then
        log_success "SSH access confirmed"
    else
        log_warning "SSH access not configured. You'll need to set up SSH keys or enter password manually."
        log_info "To set up SSH keys, run: ssh-copy-id $QNAP_SSH_USER@$QNAP_IP"
    fi
}

# Create project directory on QNAP
setup_qnap_directories() {
    log_info "Setting up directories on QNAP..."

    ssh "$QNAP_SSH_USER"@"$QNAP_IP" "
        # Create main project directory
        mkdir -p $PROJECT_PATH
        mkdir -p $BACKUP_PATH
        mkdir -p $PROJECT_PATH/logs

        # Set permissions
        chmod 755 $PROJECT_PATH
        chmod 755 $BACKUP_PATH

        echo 'Directories created successfully'
    "

    log_success "QNAP directories created"
}

# Upload project files
upload_project() {
    log_info "Uploading project files to QNAP..."

    # Create a temporary archive excluding unnecessary files
    tar --exclude='.git' \
        --exclude='node_modules' \
        --exclude='__pycache__' \
        --exclude='.venv' \
        --exclude='*.log' \
        --exclude='.DS_Store' \
        -czf freshthreads-deploy.tar.gz .

    # Upload to QNAP
    scp freshthreads-deploy.tar.gz "$QNAP_SSH_USER"@"$QNAP_IP":"$PROJECT_PATH"/

    # Extract on QNAP
    ssh "$QNAP_SSH_USER"@"$QNAP_IP" "
        cd $PROJECT_PATH
        tar -xzf freshthreads-deploy.tar.gz
        rm freshthreads-deploy.tar.gz

        # Set proper permissions
        chmod +x deploy-qnap.sh
        chmod +x scripts/*.sh 2>/dev/null || true
    "

    # Clean up local archive
    rm freshthreads-deploy.tar.gz

    log_success "Project files uploaded"
}

# Setup environment on QNAP
setup_environment() {
    log_info "Setting up environment on QNAP..."

    # Copy environment configuration
    scp .env.qnap "$QNAP_SSH_USER"@"$QNAP_IP":"$PROJECT_PATH"/.env.qnap

    if [ -f .env ]; then
        scp .env "$QNAP_SSH_USER"@"$QNAP_IP":"$PROJECT_PATH"/.env
        log_success "Environment file uploaded"
    else
        log_warning "No .env file found locally. You'll need to create one on QNAP."
        ssh "$QNAP_SSH_USER"@"$QNAP_IP" "
            cd $PROJECT_PATH
            if [ ! -f .env ]; then
                cat > .env << 'EOF'
# FreshThreads Environment Configuration
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
                echo 'Template .env file created. Please edit with your actual API keys.'
            fi
        "
    fi
}

# Deploy with Docker Compose
deploy_containers() {
    log_info "Deploying containers on QNAP..."

    ssh "$QNAP_SSH_USER"@"$QNAP_IP" "
        cd $PROJECT_PATH

        # Set Docker path for QNAP Container Station
        export PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:\$PATH

        # Stop existing containers if running
        docker compose down 2>/dev/null || true

        # Build and start containers
        docker compose up -d --build

        # Wait for containers to start
        sleep 10

        # Check container status
        docker compose ps
    "

    log_success "Containers deployed"
}

# Test deployment
test_deployment() {
    log_info "Testing deployment..."

    # Test backend health
    if curl -s http://"$QNAP_IP":"$BACKEND_PORT"/health > /dev/null; then
        log_success "Backend API is responding"
    else
        log_warning "Backend API not responding yet"
    fi

    # Test frontend
    if curl -s http://"$QNAP_IP":"$FRONTEND_PORT" > /dev/null; then
        log_success "Frontend is responding"
    else
        log_warning "Frontend not responding yet"
    fi

    echo ""
    echo "🎉 Deployment Complete!"
    echo "========================"
    echo "Frontend: http://$QNAP_IP:$FRONTEND_PORT"
    echo "Backend API: http://$QNAP_IP:$BACKEND_PORT"
    echo "Health Check: http://$QNAP_IP:$BACKEND_PORT/health"
    echo ""
    echo "To monitor logs:"
    echo "  ssh $QNAP_SSH_USER@$QNAP_IP 'cd $PROJECT_PATH && export PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:\$PATH && docker compose logs -f'"
}

# Main deployment process
main() {
    echo "Starting deployment to QNAP: $QNAP_HOSTNAME ($QNAP_IP)"
    echo ""

    test_qnap_connection
    test_ssh_access
    setup_qnap_directories
    upload_project
    setup_environment
    deploy_containers
    test_deployment

    log_success "FreshThreads successfully deployed to QNAP!"
}

# Run deployment
main "$@"
