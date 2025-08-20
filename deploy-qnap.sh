#!/bin/bash

# FreshThreads QNAP Deployment Script
# This script automates the deployment process on QNAP Container Station

set -e

echo "🚀 FreshThreads QNAP Deployment Script"
echo "========================================"

# Configuration
PROJECT_NAME="freshthreads"
CONTAINER_PATH="/share/Container/FreshThreads"
BACKUP_PATH="/share/Container/backups"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on QNAP
check_qnap() {
    if [ ! -d "/share" ]; then
        log_error "This script is designed to run on QNAP systems"
        exit 1
    fi
    log_success "QNAP system detected"
}

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please install Container Station"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose not found. Please install Container Station"
        exit 1
    fi

    log_success "Docker and Docker Compose found"
}

# Setup directories
setup_directories() {
    log_info "Setting up directories..."

    mkdir -p "$BACKUP_PATH"
    mkdir -p "$CONTAINER_PATH/logs"

    log_success "Directories created"
}

# Check environment file
check_environment() {
    log_info "Checking environment configuration..."

    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            log_warning "No .env file found. Copying from .env.example"
            cp .env.example .env
            log_warning "Please edit .env file with your actual values before deployment"
            echo "nano .env"
            exit 1
        else
            log_error "No environment file found"
            exit 1
        fi
    fi

    # Check required variables
    source .env

    if [ -z "$PRINTIFY_API_KEY" ] || [ "$PRINTIFY_API_KEY" = "YOUR_PRINTIFY_API_KEY" ]; then
        log_error "PRINTIFY_API_KEY not configured in .env"
        exit 1
    fi

    if [ -z "$STRIPE_SECRET_KEY" ] || [ "$STRIPE_SECRET_KEY" = "YOUR_STRIPE_SECRET_KEY" ]; then
        log_error "STRIPE_SECRET_KEY not configured in .env"
        exit 1
    fi

    log_success "Environment configuration looks good"
}

# Backup existing deployment
backup_existing() {
    if [ -d "logs" ] && [ "$(ls -A logs)" ]; then
        log_info "Backing up existing logs..."

        BACKUP_FILE="$BACKUP_PATH/freshthreads-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar -czf "$BACKUP_FILE" logs/ .env

        log_success "Backup created: $BACKUP_FILE"
    fi
}

# Deploy containers
deploy() {
    log_info "Deploying FreshThreads containers..."

    # Stop existing containers
    if docker-compose ps | grep -q freshthreads; then
        log_info "Stopping existing containers..."
        docker-compose down
    fi

    # Build and start containers
    log_info "Building and starting containers..."
    docker-compose up -d --build

    log_success "Containers deployed"
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."

    # Wait for containers to start
    sleep 10

    # Check container status
    if ! docker-compose ps | grep -q "Up"; then
        log_error "Some containers failed to start"
        docker-compose logs
        exit 1
    fi

    # Test backend health
    local backend_port=$(grep BACKEND_PORT .env | cut -d'=' -f2)
    backend_port=${backend_port:-8000}

    if curl -f "http://localhost:$backend_port/health" &> /dev/null; then
        log_success "Backend API is healthy"
    else
        log_warning "Backend API health check failed"
    fi

    # Test frontend
    local frontend_port=$(grep FRONTEND_PORT .env | cut -d'=' -f2)
    frontend_port=${frontend_port:-8080}

    if curl -f "http://localhost:$frontend_port/" &> /dev/null; then
        log_success "Frontend is accessible"
    else
        log_warning "Frontend accessibility check failed"
    fi
}

# Display deployment info
show_info() {
    log_info "Deployment Information:"
    echo "========================"

    local frontend_port=$(grep FRONTEND_PORT .env | cut -d'=' -f2)
    frontend_port=${frontend_port:-8080}

    local backend_port=$(grep BACKEND_PORT .env | cut -d'=' -f2)
    backend_port=${backend_port:-8000}

    local qnap_ip=$(hostname -I | awk '{print $1}')

    echo "🌐 Frontend URL: http://$qnap_ip:$frontend_port"
    echo "🔧 Backend API: http://$qnap_ip:$backend_port"
    echo "📊 Health Check: http://$qnap_ip:$backend_port/health"
    echo ""
    echo "📝 View logs: docker-compose logs -f"
    echo "🔄 Restart: docker-compose restart"
    echo "⏹️  Stop: docker-compose down"
    echo "📈 Monitor: docker stats"
}

# Main execution
main() {
    echo ""

    # Change to script directory
    cd "$(dirname "$0")"

    check_qnap
    check_docker
    setup_directories
    check_environment
    backup_existing
    deploy
    verify_deployment
    show_info

    echo ""
    log_success "FreshThreads deployed successfully on QNAP!"
    echo ""
}

# Handle script arguments
case "${1:-}" in
    "stop")
        log_info "Stopping FreshThreads containers..."
        docker-compose down
        log_success "Containers stopped"
        ;;
    "restart")
        log_info "Restarting FreshThreads containers..."
        docker-compose restart
        log_success "Containers restarted"
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "status")
        docker-compose ps
        ;;
    "update")
        log_info "Updating FreshThreads deployment..."
        docker-compose down
        docker-compose pull
        docker-compose up -d --build
        log_success "Update completed"
        ;;
    *)
        main
        ;;
esac
