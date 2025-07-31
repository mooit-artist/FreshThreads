#!/bin/bash
# Security Onion Manager - Orchestration and Management Script
# Comprehensive management for Security Onion Docker deployment

set -euo pipefail

# Configuration
COMPOSE_FILE="../docker-compose.security-onion.yml"
LOG_DIR="/tmp/security-onion"
CONFIG_DIR="../security-onion"
BACKUP_DIR="/tmp/backup/security-onion"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Initialize directories
init_directories() {
    log "Initializing Security Onion directories..."

    mkdir -p "$LOG_DIR"/{elasticsearch,kibana,logstash,suricata,zeek,filebeat}
    mkdir -p "$BACKUP_DIR"
    mkdir -p /tmp/security-onion-data/{elasticsearch,kibana}
    mkdir -p /tmp/security-onion-config

    # Set proper permissions (macOS compatible)
    chmod -R 755 "$LOG_DIR"
    chmod -R 755 /tmp/security-onion-data

    log "Directories initialized successfully"
}# Update Suricata rules
update_suricata_rules() {
    log "Updating Suricata rules..."

    local rules_dir="$CONFIG_DIR/suricata/rules"

    # Download Emerging Threats rules (if available)
    if command -v wget >/dev/null 2>&1; then
        wget -q -O /tmp/emerging.rules.tar.gz \
            "https://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz" || warn "Failed to download ET rules"

        if [[ -f /tmp/emerging.rules.tar.gz ]]; then
            tar -xzf /tmp/emerging.rules.tar.gz -C /tmp/
            cp /tmp/rules/*.rules "$rules_dir/" 2>/dev/null || warn "Failed to extract ET rules"
            rm -rf /tmp/emerging.rules.tar.gz /tmp/rules
            log "Emerging Threats rules updated"
        fi
    fi

    # Update rule permissions
    chmod 644 "$rules_dir"/*.rules 2>/dev/null || warn "Failed to set rule permissions"
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."

    # Check memory (macOS compatible)
    if command -v vm_stat >/dev/null 2>&1; then
        local mem_mb=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//' | awk '{print $1 * 4096 / 1024 / 1024}')
        if [[ ${mem_mb%.*} -lt 8192 ]]; then
            warn "System may have less than 8GB RAM. Security Onion may perform poorly."
        fi
    else
        warn "Cannot determine system memory on this platform"
    fi

    # Check disk space (macOS compatible)
    local disk_gb=$(df -h /tmp | tail -1 | awk '{print $4}' | sed 's/G.*//' | sed 's/[^0-9].*//')
    if [[ -n "$disk_gb" ]] && [[ $disk_gb -lt 50 ]]; then
        warn "Less than 50GB free disk space available."
    fi

    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is not installed"
    fi

    if ! command -v docker-compose >/dev/null 2>&1; then
        error "Docker Compose is not installed"
    fi

    log "System requirements check completed"
}# Start Security Onion services
start_services() {
    log "Starting Security Onion services..."

    # Change to the directory containing the compose file
    local compose_dir=$(dirname "$(realpath "$COMPOSE_FILE")")
    cd "$compose_dir"

    # Start core services first
    docker-compose -f "$(basename "$COMPOSE_FILE")" up -d elasticsearch
    sleep 30

    # Wait for Elasticsearch to be ready
    local count=0
    while ! curl -s http://localhost:9200/_cluster/health >/dev/null 2>&1; do
        sleep 10
        count=$((count + 1))
        if [[ $count -gt 30 ]]; then
            error "Elasticsearch failed to start within 5 minutes"
        fi
        log "Waiting for Elasticsearch to be ready... ($count/30)"
    done

    # Start remaining services
    docker-compose -f "$(basename "$COMPOSE_FILE")" up -d

    log "Security Onion services started successfully"
}

# Stop Security Onion services
stop_services() {
    log "Stopping Security Onion services..."

    local compose_dir=$(dirname "$(realpath "$COMPOSE_FILE")")
    cd "$compose_dir"
    docker-compose -f "$(basename "$COMPOSE_FILE")" down

    log "Security Onion services stopped"
}

# Restart services
restart_services() {
    log "Restarting Security Onion services..."
    stop_services
    sleep 10
    start_services
}

# Check service status
status_services() {
    log "Checking Security Onion service status..."

    local compose_dir=$(dirname "$(realpath "$COMPOSE_FILE")")
    cd "$compose_dir"
    docker-compose -f "$(basename "$COMPOSE_FILE")" ps

    # Check service health
    echo -e "\n${BLUE}Service Health Checks:${NC}"

    # Elasticsearch
    if curl -s http://localhost:9200/_cluster/health | grep -q "green\|yellow"; then
        echo -e "  Elasticsearch: ${GREEN}✓ Running${NC}"
    else
        echo -e "  Elasticsearch: ${RED}✗ Not responding${NC}"
    fi

    # Kibana
    if curl -s http://localhost:5601/api/status | grep -q "available"; then
        echo -e "  Kibana: ${GREEN}✓ Running${NC}"
    else
        echo -e "  Kibana: ${RED}✗ Not responding${NC}"
    fi

    # Logstash
    if curl -s http://localhost:9600/ >/dev/null 2>&1; then
        echo -e "  Logstash: ${GREEN}✓ Running${NC}"
    else
        echo -e "  Logstash: ${RED}✗ Not responding${NC}"
    fi
}

# View logs
view_logs() {
    local service="${1:-}"

    if [[ -z "$service" ]]; then
        echo "Available services: elasticsearch, kibana, logstash, suricata, zeek, filebeat, so-manager"
        echo "Usage: $0 logs <service_name>"
        return 1
    fi

    cd "$(dirname "$COMPOSE_FILE")"
    docker-compose -f "$COMPOSE_FILE" logs -f "$service"
}

# Backup configuration and data
backup_data() {
    log "Creating Security Onion backup..."

    local backup_file="$BACKUP_DIR/security-onion-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

    # Create backup
    tar -czf "$backup_file" \
        -C / \
        --exclude="*/elasticsearch/nodes" \
        var/lib/security-onion \
        app/security-onion \
        var/log/security-onion

    log "Backup created: $backup_file"

    # Keep only last 7 backups
    find "$BACKUP_DIR" -name "security-onion-backup-*.tar.gz" -mtime +7 -delete
}

# Restore from backup
restore_data() {
    local backup_file="${1:-}"

    if [[ -z "$backup_file" ]] || [[ ! -f "$backup_file" ]]; then
        error "Please provide a valid backup file"
    fi

    log "Restoring from backup: $backup_file"

    # Stop services
    stop_services

    # Restore data
    tar -xzf "$backup_file" -C /

    log "Data restored. Starting services..."
    start_services
}

# Update Security Onion
update_system() {
    log "Updating Security Onion..."

    # Update rules
    update_suricata_rules

    # Pull latest images
    cd "$(dirname "$COMPOSE_FILE")"
    docker-compose -f "$COMPOSE_FILE" pull

    # Restart services with new images
    restart_services

    log "Security Onion updated successfully"
}

# Clean up old data
cleanup() {
    log "Cleaning up old Security Onion data..."

    # Clean Docker
    docker system prune -f

    # Clean old logs (older than 30 days)
    find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.json" -mtime +30 -delete 2>/dev/null || true

    # Clean old Elasticsearch indices (if running)
    if curl -s http://localhost:9200/_cluster/health >/dev/null 2>&1; then
        # Delete indices older than 30 days
        local old_date=$(date -d "30 days ago" +%Y.%m.%d)
        curl -s -X DELETE "http://localhost:9200/*-$old_date" 2>/dev/null || true
    fi

    log "Cleanup completed"
}

# Show help
show_help() {
    cat << EOF
Security Onion Manager - Docker Deployment Management

Usage: $0 <command> [options]

Commands:
    init        Initialize directories and configuration
    start       Start all Security Onion services
    stop        Stop all Security Onion services
    restart     Restart all services
    status      Show service status and health
    logs        View service logs (specify service name)
    update      Update rules and Docker images
    backup      Create backup of configuration and data
    restore     Restore from backup file
    cleanup     Clean up old data and logs
    help        Show this help message

Examples:
    $0 init
    $0 start
    $0 status
    $0 logs elasticsearch
    $0 backup
    $0 restore /backup/security-onion/backup-20240101-120000.tar.gz

EOF
}

# Main execution
main() {
    local command="${1:-help}"

    case "$command" in
        init)
            check_root
            check_requirements
            init_directories
            update_suricata_rules
            ;;
        start)
            check_root
            start_services
            ;;
        stop)
            check_root
            stop_services
            ;;
        restart)
            check_root
            restart_services
            ;;
        status)
            status_services
            ;;
        logs)
            view_logs "$2"
            ;;
        update)
            check_root
            update_system
            ;;
        backup)
            check_root
            backup_data
            ;;
        restore)
            check_root
            restore_data "$2"
            ;;
        cleanup)
            check_root
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $command. Use '$0 help' for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
