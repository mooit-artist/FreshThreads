#!/bin/bash

# Pre-analysis script for FreshThreads
# Prepares code for SonarQube analysis

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[PRE-ANALYSIS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to run ESLint
run_eslint() {
    print_status "Running ESLint analysis..."

    if find . -name "*.js" -not -path "./node_modules/*" -not -path "./venv/*" | head -1 | grep -q .; then
        eslint --format json --output-file /opt/reports/eslint-report.json \
            $(find . -name "*.js" -not -path "./node_modules/*" -not -path "./venv/*") || true
        print_success "ESLint analysis completed"
    else
        print_status "No JavaScript files found for ESLint"
    fi
}

# Function to run StyleLint
run_stylelint() {
    print_status "Running StyleLint analysis..."

    if find . -name "*.css" -not -path "./node_modules/*" -not -path "./venv/*" | head -1 | grep -q .; then
        stylelint --formatter json --output-file /opt/reports/stylelint-report.json \
            $(find . -name "*.css" -not -path "./node_modules/*" -not -path "./venv/*") || true
        print_success "StyleLint analysis completed"
    else
        print_status "No CSS files found for StyleLint"
    fi
}

# Function to run HTMLHint
run_htmlhint() {
    print_status "Running HTMLHint analysis..."

    if find . -name "*.html" -not -path "./node_modules/*" -not -path "./venv/*" | head -1 | grep -q .; then
        htmlhint --format json --reporter json \
            $(find . -name "*.html" -not -path "./node_modules/*" -not -path "./venv/*") > /opt/reports/htmlhint-report.json || true
        print_success "HTMLHint analysis completed"
    else
        print_status "No HTML files found for HTMLHint"
    fi
}

# Function to run Python linting
run_python_lint() {
    print_status "Running Python linting..."

    if find . -name "*.py" -not -path "./venv/*" | head -1 | grep -q .; then
        # Flake8
        flake8 --format=json --output-file=/opt/reports/flake8-report.json \
            $(find . -name "*.py" -not -path "./venv/*") || true

        # Bandit security analysis
        bandit -f json -o /opt/reports/bandit-report.json -r . || true

        print_success "Python linting completed"
    else
        print_status "No Python files found for linting"
    fi
}

# Function to generate file metrics
generate_metrics() {
    print_status "Generating code metrics..."

    cat > /opt/reports/code-metrics.json << EOF
{
    "timestamp": "$(date -Iseconds)",
    "files": {
        "html": $(find . -name "*.html" -not -path "./node_modules/*" -not -path "./venv/*" | wc -l),
        "css": $(find . -name "*.css" -not -path "./node_modules/*" -not -path "./venv/*" | wc -l),
        "javascript": $(find . -name "*.js" -not -path "./node_modules/*" -not -path "./venv/*" | wc -l),
        "python": $(find . -name "*.py" -not -path "./venv/*" | wc -l)
    },
    "lines_of_code": {
        "html": $(find . -name "*.html" -not -path "./node_modules/*" -not -path "./venv/*" -exec wc -l {} + | tail -1 | awk '{print $1}' || echo 0),
        "css": $(find . -name "*.css" -not -path "./node_modules/*" -not -path "./venv/*" -exec wc -l {} + | tail -1 | awk '{print $1}' || echo 0),
        "javascript": $(find . -name "*.js" -not -path "./node_modules/*" -not -path "./venv/*" -exec wc -l {} + | tail -1 | awk '{print $1}' || echo 0),
        "python": $(find . -name "*.py" -not -path "./venv/*" -exec wc -l {} + | tail -1 | awk '{print $1}' || echo 0)
    }
}
EOF

    print_success "Code metrics generated"
}

# Main execution
main() {
    print_status "🔍 Starting pre-analysis for FreshThreads"
    echo

    # Create reports directory
    mkdir -p /opt/reports

    # Run linting tools
    run_eslint
    run_stylelint
    run_htmlhint
    run_python_lint
    generate_metrics

    print_success "✅ Pre-analysis completed successfully"
    echo
    print_status "📊 Reports generated in /opt/reports/"
    ls -la /opt/reports/ || true
}

# Run main function
main "$@"
