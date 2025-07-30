#!/bin/bash

# FreshThreads SonarQube Management Script
# Manages SonarQube server and code analysis

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# SonarQube settings
SONAR_URL="http://localhost:9000"
SONAR_PROJECT_KEY="freshthreads-llc"
SONAR_COMPOSE_FILE="docker-compose.sonarqube.yml"

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

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to start SonarQube server
start_sonarqube() {
    print_status "Starting SonarQube server..."

    if docker-compose -f "$SONAR_COMPOSE_FILE" ps | grep -q "Up"; then
        print_warning "SonarQube is already running"
        return 0
    fi

    docker-compose -f "$SONAR_COMPOSE_FILE" up -d sonarqube sonarqube-db

    print_status "Waiting for SonarQube to be ready..."
    local attempts=0
    local max_attempts=60

    while [ $attempts -lt $max_attempts ]; do
        if curl -s "$SONAR_URL/api/system/status" >/dev/null 2>&1; then
            print_success "SonarQube is ready at $SONAR_URL"
            print_status "Default credentials: admin/admin"
            return 0
        fi

        echo -n "."
        sleep 5
        attempts=$((attempts + 1))
    done

    print_error "SonarQube failed to start within expected time"
    return 1
}

# Function to stop SonarQube server
stop_sonarqube() {
    print_status "Stopping SonarQube server..."

    docker-compose -f "$SONAR_COMPOSE_FILE" down

    print_success "SonarQube stopped"
}

# Function to check SonarQube status
check_status() {
    print_status "Checking SonarQube status..."

    if curl -s "$SONAR_URL/api/system/status" >/dev/null 2>&1; then
        local status
        status=$(curl -s "$SONAR_URL/api/system/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        print_success "SonarQube is running - Status: $status"
        print_status "Web UI: $SONAR_URL"

        # Check if project exists
        if curl -s -u admin:admin "$SONAR_URL/api/projects/search?projects=$SONAR_PROJECT_KEY" | grep -q "$SONAR_PROJECT_KEY"; then
            print_success "Project '$SONAR_PROJECT_KEY' exists"
        else
            print_warning "Project '$SONAR_PROJECT_KEY' not found - run analysis to create it"
        fi
    else
        print_error "SonarQube is not running or not accessible"
        print_status "Start with: $0 start"
        return 1
    fi
}

# Function to run code analysis
run_analysis() {
    print_status "Running SonarQube code analysis..."

    if ! curl -s "$SONAR_URL/api/system/status" >/dev/null 2>&1; then
        print_error "SonarQube server is not running"
        print_status "Start SonarQube first: $0 start"
        return 1
    fi

    # Create reports directory
    mkdir -p sonar-reports

    # Run analysis with Docker
    print_status "Starting code analysis..."

    # Use internal Docker network URL for scanner
    SONAR_INTERNAL_URL="http://sonarqube:9000"

    if docker-compose -f "$SONAR_COMPOSE_FILE" run --rm sonar-scanner \
        sonar-scanner \
        -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
        -Dsonar.sources=. \
        -Dsonar.host.url="$SONAR_INTERNAL_URL" \
        -Dsonar.login=admin \
        -Dsonar.password=admin \
        -Dsonar.projectBaseDir=/usr/src; then

        print_success "Code analysis completed successfully"
        print_status "View results at: $SONAR_URL/dashboard?id=$SONAR_PROJECT_KEY"

        # Generate report
        generate_report
    else
        print_error "Code analysis failed"
        return 1
    fi
}

# Function to generate quality report
generate_report() {
    print_status "Generating quality report..."

    local report_file="sonar-reports/quality-report-$(date +%Y%m%d-%H%M%S).json"

    # Get project metrics
    if curl -s -u admin:admin "$SONAR_URL/api/measures/component?component=$SONAR_PROJECT_KEY&metricKeys=bugs,vulnerabilities,code_smells,coverage,duplicated_lines_density,ncloc,sqale_rating,reliability_rating,security_rating" > "$report_file"; then
        print_success "Quality report saved to: $report_file"

        # Extract key metrics
        print_status "📊 Quality Summary:"
        echo "  • Lines of Code: $(jq -r '.component.measures[] | select(.metric=="ncloc") | .value // "N/A"' "$report_file")"
        echo "  • Bugs: $(jq -r '.component.measures[] | select(.metric=="bugs") | .value // "0"' "$report_file")"
        echo "  • Vulnerabilities: $(jq -r '.component.measures[] | select(.metric=="vulnerabilities") | .value // "0"' "$report_file")"
        echo "  • Code Smells: $(jq -r '.component.measures[] | select(.metric=="code_smells") | .value // "0"' "$report_file")"
        echo "  • Coverage: $(jq -r '.component.measures[] | select(.metric=="coverage") | .value // "N/A"' "$report_file")%"
        echo "  • Duplicated Lines: $(jq -r '.component.measures[] | select(.metric=="duplicated_lines_density") | .value // "0"' "$report_file")%"
    else
        print_warning "Could not generate detailed report - check if analysis completed"
    fi
}

# Function to clean up SonarQube data
cleanup() {
    print_status "Cleaning up SonarQube data..."

    docker-compose -f "$SONAR_COMPOSE_FILE" down -v
    docker volume prune -f

    print_success "SonarQube data cleaned up"
}

# Function to view logs
view_logs() {
    print_status "Viewing SonarQube logs..."

    docker-compose -f "$SONAR_COMPOSE_FILE" logs -f sonarqube
}

# Function to reset admin password
reset_password() {
    print_status "Resetting admin password..."

    if ! curl -s "$SONAR_URL/api/system/status" >/dev/null 2>&1; then
        print_error "SonarQube server is not running"
        return 1
    fi

    # Reset to default password
    if curl -X POST -u admin:admin "$SONAR_URL/api/users/change_password?login=admin&password=admin&previousPassword=admin" >/dev/null 2>&1; then
        print_success "Admin password reset to default"
    else
        print_warning "Password reset may have failed - try logging in with admin/admin"
    fi
}

# Function to install plugins
install_plugins() {
    print_status "Installing recommended SonarQube plugins..."

    print_status "Available plugins for web development:"
    echo "  • SonarJS - JavaScript/TypeScript analysis"
    echo "  • SonarHTML - HTML analysis"
    echo "  • SonarCSS - CSS analysis"
    echo "  • SonarPython - Python analysis"
    echo ""
    print_status "Plugins can be installed through the SonarQube web interface:"
    print_status "  1. Go to Administration > Marketplace"
    print_status "  2. Search and install desired plugins"
    print_status "  3. Restart SonarQube server"
}

# Function to backup SonarQube data
backup() {
    print_status "Creating SonarQube backup..."

    local backup_dir="sonar-backups/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Backup database
    docker-compose -f "$SONAR_COMPOSE_FILE" exec -T sonarqube-db pg_dump -U sonar sonar > "$backup_dir/database.sql"

    # Backup volumes
    docker run --rm -v freshthreads_sonarqube_data:/data -v "$(pwd)/$backup_dir":/backup alpine tar czf /backup/sonarqube_data.tar.gz -C /data .

    print_success "Backup created in: $backup_dir"
}

# Function to show usage
show_usage() {
    echo "FreshThreads SonarQube Management Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start             Start SonarQube server"
    echo "  stop              Stop SonarQube server"
    echo "  restart           Restart SonarQube server"
    echo "  status            Check SonarQube status"
    echo "  analyze           Run code analysis"
    echo "  report            Generate quality report"
    echo "  logs              View SonarQube logs"
    echo "  reset-password    Reset admin password to default"
    echo "  plugins           Show plugin installation info"
    echo "  backup            Create backup of SonarQube data"
    echo "  cleanup           Clean up all SonarQube data"
    echo "  help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start          # Start SonarQube server"
    echo "  $0 analyze        # Run code analysis"
    echo "  $0 status         # Check server status"
    echo "  $0 cleanup        # Clean up data and restart fresh"
    echo
    echo "Web Interface: http://localhost:9000"
    echo "Default credentials: admin/admin"
}

# Main execution
main() {
    case "${1:-help}" in
        "start")
            check_docker
            start_sonarqube
            ;;
        "stop")
            stop_sonarqube
            ;;
        "restart")
            stop_sonarqube
            sleep 5
            start_sonarqube
            ;;
        "status")
            check_status
            ;;
        "analyze")
            check_docker
            run_analysis
            ;;
        "report")
            generate_report
            ;;
        "logs")
            view_logs
            ;;
        "reset-password")
            reset_password
            ;;
        "plugins")
            install_plugins
            ;;
        "backup")
            backup
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"
