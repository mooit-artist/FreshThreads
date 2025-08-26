#!/bin/bash

# QNAP QTS API Integration Script
# Enhanced deployment using QNAP QTS Authentication API
# Based on docs/API_QNAP_QTS_Authentication.pdf

source .env.qnap

# QNAP QTS API Configuration
QTS_API_BASE="https://${QNAP_IP}:443/cgi-bin"
QTS_SESSION_FILE="/tmp/qnap_session.json"

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

# QTS API Authentication
# Based on QNAP QTS Authentication API documentation
authenticate_qts() {
    log_info "Authenticating with QNAP QTS API..."

    if [ -z "$QNAP_USERNAME" ] || [ -z "$QNAP_PASSWORD" ]; then
        log_warning "QNAP credentials not set in .env.qnap"
        log_info "Please set QNAP_USERNAME and QNAP_PASSWORD for API access"
        return 1
    fi

    # QTS Login API endpoint
    login_response=$(curl -s -k -X POST \
        "$QTS_API_BASE/authLogin.cgi" \
        -d "user=$QNAP_USERNAME" \
        -d "pwd=$QNAP_PASSWORD" \
        -d "serviceKey=1" \
        -c "$QTS_SESSION_FILE")

    if echo "$login_response" | grep -q '"authPassed":true'; then
        log_success "QTS API authentication successful"
        return 0
    else
        log_error "QTS API authentication failed"
        echo "Response: $login_response"
        return 1
    fi
}

# Check QTS System Status via API
check_qts_status() {
    log_info "Checking QTS system status..."

    status_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        "$QTS_API_BASE/management/manaRequest.cgi?subfunc=sysinfo&hd=no&multicpu=1")

    if echo "$status_response" | grep -q '"result":0'; then
        log_success "QTS system is operational"

        # Extract system info
        model=$(echo "$status_response" | grep -o '"model":"[^"]*"' | cut -d'"' -f4)
        version=$(echo "$status_response" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)

        log_info "Model: $model"
        log_info "QTS Version: $version"
        return 0
    else
        log_warning "Could not retrieve QTS status"
        return 1
    fi
}

# Check Container Station Status via API
check_container_station() {
    log_info "Checking Container Station status..."

    container_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        "$QTS_API_BASE/container-station/containerRequest.cgi?op=config_get")

    if echo "$container_response" | grep -q '"container_station_enabled":true'; then
        log_success "Container Station is enabled"
        return 0
    else
        log_warning "Container Station may not be enabled or installed"
        log_info "Please install Container Station from App Center"
        return 1
    fi
}

# Get Container Station Docker Info
get_docker_info() {
    log_info "Getting Docker information..."

    docker_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        "$QTS_API_BASE/container-station/containerRequest.cgi?op=docker_info")

    if echo "$docker_response" | grep -q '"result":0'; then
        log_success "Docker is available"

        # Extract Docker version if available
        docker_version=$(echo "$docker_response" | grep -o '"ServerVersion":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$docker_version" ]; then
            log_info "Docker Version: $docker_version"
        fi
        return 0
    else
        log_warning "Docker information not available"
        return 1
    fi
}

# Create Container via API
create_container_project() {
    log_info "Creating FreshThreads container project via API..."

    # Upload docker-compose.yml via QTS file manager API
    compose_content=$(cat docker-compose.yml | base64)

    upload_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        -X POST "$QTS_API_BASE/filemanager/utilRequest.cgi" \
        -F "func=upload" \
        -F "type=standard" \
        -F "dest_path=/share/Container/FreshThreads" \
        -F "overwrite=1" \
        -F "file=@docker-compose.yml")

    if echo "$upload_response" | grep -q '"success":true'; then
        log_success "Docker compose file uploaded"

        # Create container project via Container Station API
        create_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
            -X POST "$QTS_API_BASE/container-station/containerRequest.cgi" \
            -d "op=compose_create" \
            -d "project_name=freshthreads" \
            -d "compose_file_path=/share/Container/FreshThreads/docker-compose.yml")

        if echo "$create_response" | grep -q '"result":0'; then
            log_success "Container project created successfully"
            return 0
        else
            log_error "Failed to create container project"
            echo "Response: $create_response"
            return 1
        fi
    else
        log_error "Failed to upload docker-compose.yml"
        return 1
    fi
}

# Start Container Project
start_container_project() {
    log_info "Starting FreshThreads containers..."

    start_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        -X POST "$QTS_API_BASE/container-station/containerRequest.cgi" \
        -d "op=compose_start" \
        -d "project_name=freshthreads")

    if echo "$start_response" | grep -q '"result":0'; then
        log_success "Containers started successfully"
        return 0
    else
        log_error "Failed to start containers"
        echo "Response: $start_response"
        return 1
    fi
}

# Get Container Status
get_container_status() {
    log_info "Checking container status..."

    status_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        "$QTS_API_BASE/container-station/containerRequest.cgi?op=compose_ps&project_name=freshthreads")

    if echo "$status_response" | grep -q '"result":0'; then
        log_success "Container status retrieved"

        # Parse and display container status
        echo "$status_response" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read container; do
            log_info "Container: $container"
        done
        return 0
    else
        log_warning "Could not retrieve container status"
        return 1
    fi
}

# Setup Shared Folders via API
setup_shared_folders() {
    log_info "Setting up shared folders for FreshThreads..."

    # Create Container shared folder if it doesn't exist
    folder_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        -X POST "$QTS_API_BASE/filemanager/utilRequest.cgi" \
        -d "func=createfolder" \
        -d "dest_path=/share" \
        -d "dest_folder=Container")

    # Create FreshThreads project folder
    project_response=$(curl -s -k -b "$QTS_SESSION_FILE" \
        -X POST "$QTS_API_BASE/filemanager/utilRequest.cgi" \
        -d "func=createfolder" \
        -d "dest_path=/share/Container" \
        -d "dest_folder=FreshThreads")

    if echo "$project_response" | grep -q '"success":true' || echo "$project_response" | grep -q 'already exists'; then
        log_success "FreshThreads project folder ready"
        return 0
    else
        log_warning "Could not create project folder via API"
        return 1
    fi
}

# Logout from QTS API
logout_qts() {
    log_info "Logging out from QTS API..."

    curl -s -k -b "$QTS_SESSION_FILE" \
        "$QTS_API_BASE/authLogout.cgi" > /dev/null

    rm -f "$QTS_SESSION_FILE"
    log_success "QTS API session closed"
}

# Main QTS API deployment function
deploy_via_qts_api() {
    log_info "🚀 Starting QNAP QTS API deployment..."

    # Test network connectivity first
    if ! ping -c 1 "$QNAP_IP" > /dev/null 2>&1; then
        log_error "Cannot reach QNAP at $QNAP_IP"
        exit 1
    fi

    # Authenticate with QTS API
    if ! authenticate_qts; then
        log_error "QTS API authentication failed"
        exit 1
    fi

    # Check system status
    check_qts_status

    # Check Container Station
    if ! check_container_station; then
        log_warning "Container Station needs to be installed manually"
        log_info "1. Login to QTS Web Interface: https://$QNAP_IP"
        log_info "2. Go to App Center"
        log_info "3. Install Container Station"
        logout_qts
        exit 1
    fi

    # Get Docker info
    get_docker_info

    # Setup shared folders
    setup_shared_folders

    # Create and start container project
    if create_container_project; then
        sleep 5  # Wait for creation to complete
        start_container_project
        sleep 10  # Wait for startup
        get_container_status
    fi

    # Logout
    logout_qts

    log_success "🎉 QTS API deployment completed!"
    echo ""
    echo "Access your application:"
    echo "Frontend: https://$QNAP_IP:$FRONTEND_PORT"
    echo "Backend API: https://$QNAP_IP:$BACKEND_PORT"
    echo "QTS Management: https://$QNAP_IP"
}

# Test API connectivity
test_qts_api() {
    log_info "🧪 Testing QNAP QTS API connectivity..."

    # Test HTTPS connectivity
    if curl -s -k --connect-timeout 5 "https://$QNAP_IP/cgi-bin/authLogin.cgi" > /dev/null; then
        log_success "QTS API endpoint is accessible"
    else
        log_error "Cannot connect to QTS API"
        return 1
    fi

    # Test authentication if credentials are provided
    if [ -n "$QNAP_USERNAME" ] && [ -n "$QNAP_PASSWORD" ]; then
        if authenticate_qts; then
            check_qts_status
            check_container_station
            logout_qts
        fi
    else
        log_info "Set QNAP_USERNAME and QNAP_PASSWORD in .env.qnap for full API testing"
    fi
}

# Command line interface
case "${1:-deploy}" in
    "test")
        test_qts_api
        ;;
    "deploy")
        deploy_via_qts_api
        ;;
    "auth")
        authenticate_qts
        check_qts_status
        logout_qts
        ;;
    *)
        echo "Usage: $0 {test|deploy|auth}"
        echo "  test   - Test QTS API connectivity"
        echo "  deploy - Full deployment via QTS API"
        echo "  auth   - Test authentication only"
        exit 1
        ;;
esac
