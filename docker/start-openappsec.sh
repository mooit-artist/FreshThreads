#!/bin/bash

# FreshThreads OpenAppSec Startup Script
# Initializes OpenAppSec and starts Nginx with security protection

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as correct user
check_user() {
    if [ "$(whoami)" != "freshthreads" ]; then
        print_error "Script must run as freshthreads user"
        exit 1
    fi
    print_success "Running as correct user: freshthreads"
}

# Function to validate OpenAppSec installation
validate_openappsec() {
    print_status "Validating OpenAppSec installation..."

    if [ ! -f "/usr/lib/nginx/modules/ngx_http_cp_module.so" ]; then
        print_error "OpenAppSec module not found"
        exit 1
    fi

    if [ ! -d "/etc/cp" ]; then
        print_error "OpenAppSec configuration directory not found"
        exit 1
    fi

    print_success "OpenAppSec installation validated"
}

# Function to initialize OpenAppSec configuration
init_openappsec_config() {
    print_status "Initializing OpenAppSec configuration..."

    # Create necessary directories
    mkdir -p /var/log/nano_agent
    mkdir -p /etc/cp/conf/rules

    # Set up basic configuration if not exists
    if [ ! -f "/etc/cp/conf/nginx_cp.conf" ]; then
        cat > /etc/cp/conf/nginx_cp.conf << 'EOF'
# OpenAppSec Nginx Configuration
cp_enable on;
cp_log_level info;
cp_log_format json;
cp_log_file /var/log/nano_agent/cp_nginx.log;

# Include custom rules
include /etc/cp/conf/custom.conf;
EOF
    fi

    print_success "OpenAppSec configuration initialized"
}

# Function to validate nginx configuration
validate_nginx_config() {
    print_status "Validating Nginx configuration..."

    if nginx -t 2>/dev/null; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration validation failed"
        nginx -t
        exit 1
    fi
}

# Function to start services
start_services() {
    print_status "Starting OpenAppSec and Nginx..."

    # Start OpenAppSec agent in background
    if [ -f "/usr/bin/cp-nano-agent" ]; then
        print_status "Starting OpenAppSec nano agent..."
        /usr/bin/cp-nano-agent --config /etc/cp/conf/nano_agent.conf &
        sleep 2
        print_success "OpenAppSec nano agent started"
    fi

    # Start Nginx
    print_status "Starting Nginx with OpenAppSec protection..."
    exec nginx -g "daemon off;"
}

# Function to handle shutdown
cleanup() {
    print_status "Shutting down services..."

    # Kill background processes
    jobs -p | xargs -r kill

    print_success "Cleanup completed"
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Main execution
main() {
    print_status "🛡️  FreshThreads OpenAppSec Startup"
    echo

    check_user
    validate_openappsec
    init_openappsec_config
    validate_nginx_config

    print_success "🚀 All validations passed - starting services"
    echo

    start_services
}

# Run main function
main "$@"
