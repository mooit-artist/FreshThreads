#!/bin/bash

# SonarQube analysis script for FreshThreads
# Runs comprehensive code quality analysis

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# SonarQube settings
SONAR_HOST_URL="${SONAR_HOST_URL:-http://sonarqube:9000}"
SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-freshthreads-llc}"
SONAR_PROJECT_NAME="${SONAR_PROJECT_NAME:-FreshThreads LLC}"
SONAR_PROJECT_VERSION="${SONAR_PROJECT_VERSION:-1.0}"

print_status() {
    echo -e "${BLUE}[SONAR]${NC} $1"
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

# Function to wait for SonarQube to be ready
wait_for_sonarqube() {
    print_status "Waiting for SonarQube server to be ready..."

    local attempts=0
    local max_attempts=30

    while [ $attempts -lt $max_attempts ]; do
        if curl -s "$SONAR_HOST_URL/api/system/status" >/dev/null 2>&1; then
            print_success "SonarQube server is ready"
            return 0
        fi

        echo -n "."
        sleep 2
        attempts=$((attempts + 1))
    done

    print_error "SonarQube server not ready after $((max_attempts * 2)) seconds"
    return 1
}

# Function to run pre-analysis
run_pre_analysis() {
    print_status "Running pre-analysis checks..."

    if [ -f "/opt/analysis-scripts/pre-analysis.sh" ]; then
        /opt/analysis-scripts/pre-analysis.sh
    else
        print_warning "Pre-analysis script not found, skipping"
    fi
}

# Function to validate project structure
validate_project() {
    print_status "Validating project structure..."

    if [ ! -f "sonar-project.properties" ]; then
        print_warning "sonar-project.properties not found, using defaults"
        create_default_properties
    fi

    # Check for source files
    local source_files=0
    source_files=$(find . -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.py" | grep -v node_modules | grep -v venv | wc -l)

    if [ "$source_files" -eq 0 ]; then
        print_error "No source files found for analysis"
        return 1
    fi

    print_success "Found $source_files source files for analysis"
}

# Function to create default properties if missing
create_default_properties() {
    cat > sonar-project.properties << EOF
sonar.projectKey=$SONAR_PROJECT_KEY
sonar.projectName=$SONAR_PROJECT_NAME
sonar.projectVersion=$SONAR_PROJECT_VERSION
sonar.sources=docs,scripts
sonar.exclusions=**/node_modules/**,**/venv/**,**/*.min.js,**/*.min.css
sonar.sourceEncoding=UTF-8
EOF
    print_status "Created default sonar-project.properties"
}

# Function to run SonarQube scanner
run_scanner() {
    print_status "Starting SonarQube analysis..."

    local scanner_args=(
        "-Dsonar.host.url=$SONAR_HOST_URL"
        "-Dsonar.projectKey=$SONAR_PROJECT_KEY"
        "-Dsonar.projectName=$SONAR_PROJECT_NAME"
        "-Dsonar.projectVersion=$SONAR_PROJECT_VERSION"
        "-Dsonar.sources=."
        "-Dsonar.exclusions=**/node_modules/**,**/venv/**,**/*.min.js,**/*.min.css,**/vendor/**,**/dist/**,**/build/**"
        "-Dsonar.sourceEncoding=UTF-8"
        "-Dsonar.log.level=INFO"
    )

    # Add authentication if provided
    if [ -n "${SONAR_LOGIN:-}" ]; then
        scanner_args+=("-Dsonar.login=$SONAR_LOGIN")
    fi

    if [ -n "${SONAR_PASSWORD:-}" ]; then
        scanner_args+=("-Dsonar.password=$SONAR_PASSWORD")
    fi

    # Add external reports if they exist
    if [ -f "/opt/reports/eslint-report.json" ]; then
        scanner_args+=("-Dsonar.eslint.reportPaths=/opt/reports/eslint-report.json")
    fi

    # Run the scanner
    if sonar-scanner "${scanner_args[@]}"; then
        print_success "SonarQube analysis completed successfully"
        return 0
    else
        print_error "SonarQube analysis failed"
        return 1
    fi
}

# Function to generate analysis summary
generate_summary() {
    print_status "Generating analysis summary..."

    local summary_file="/opt/reports/analysis-summary.json"

    cat > "$summary_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "project": {
        "key": "$SONAR_PROJECT_KEY",
        "name": "$SONAR_PROJECT_NAME",
        "version": "$SONAR_PROJECT_VERSION"
    },
    "sonar_host": "$SONAR_HOST_URL",
    "analysis_status": "completed",
    "reports_generated": [
        $(find /opt/reports -name "*.json" -type f | sed 's/.*/"&"/' | paste -sd ',' -)
    ]
}
EOF

    print_success "Analysis summary saved to: $summary_file"
    print_status "📊 View results at: $SONAR_HOST_URL/dashboard?id=$SONAR_PROJECT_KEY"
}

# Function to show analysis results
show_results() {
    echo
    print_status "🎯 Analysis Results Summary"
    echo "================================"
    echo "Project: $SONAR_PROJECT_NAME"
    echo "Key: $SONAR_PROJECT_KEY"
    echo "Version: $SONAR_PROJECT_VERSION"
    echo "SonarQube: $SONAR_HOST_URL"
    echo
    echo "📊 Dashboard: $SONAR_HOST_URL/dashboard?id=$SONAR_PROJECT_KEY"
    echo "📋 Issues: $SONAR_HOST_URL/project/issues?id=$SONAR_PROJECT_KEY"
    echo "🔒 Security: $SONAR_HOST_URL/project/security_hotspots?id=$SONAR_PROJECT_KEY"
    echo "📈 Measures: $SONAR_HOST_URL/component_measures?id=$SONAR_PROJECT_KEY"
    echo

    if [ -d "/opt/reports" ]; then
        echo "📁 Generated Reports:"
        ls -la /opt/reports/ | grep -v "^total" | awk '{print "   " $9 " (" $5 " bytes)"}'
    fi

    echo
    print_success "✅ SonarQube analysis completed successfully!"
}

# Main execution
main() {
    print_status "🔍 FreshThreads SonarQube Analysis"
    echo "=================================="
    echo

    # Validate environment
    wait_for_sonarqube || exit 1
    validate_project || exit 1

    # Run analysis
    run_pre_analysis

    if run_scanner; then
        generate_summary
        show_results
    else
        print_error "Analysis failed - check logs above"
        exit 1
    fi
}

# Show help if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "FreshThreads SonarQube Analysis Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Environment Variables:"
    echo "  SONAR_HOST_URL      SonarQube server URL (default: http://sonarqube:9000)"
    echo "  SONAR_PROJECT_KEY   Project key (default: freshthreads-llc)"
    echo "  SONAR_PROJECT_NAME  Project name (default: FreshThreads LLC)"
    echo "  SONAR_PROJECT_VERSION Project version (default: 1.0)"
    echo "  SONAR_LOGIN         SonarQube login token"
    echo "  SONAR_PASSWORD      SonarQube password"
    echo
    echo "Examples:"
    echo "  $0                  # Run with defaults"
    echo "  SONAR_LOGIN=token $0 # Run with authentication"
    exit 0
fi

# Run main function
main "$@"
