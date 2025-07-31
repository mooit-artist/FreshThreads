#!/bin/bash

# OpenAppSec Security Test Script
# Tests various attack patterns to verify OpenAppSec protection

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Target URL
TARGET_URL="http://localhost:8080"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Function to test if server is running
test_server_availability() {
    print_status "Testing server availability..."

    if curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL" | grep -q "200"; then
        print_success "Server is responding"
        return 0
    else
        print_error "Server is not responding"
        return 1
    fi
}

# Function to test basic security headers
test_security_headers() {
    print_status "Testing security headers..."

    local headers
    headers=$(curl -I -s "$TARGET_URL" 2>/dev/null)

    if echo "$headers" | grep -qi "X-Frame-Options"; then
        print_success "X-Frame-Options header present"
    else
        print_error "X-Frame-Options header missing"
    fi

    if echo "$headers" | grep -qi "Content-Security-Policy"; then
        print_success "Content-Security-Policy header present"
    else
        print_error "Content-Security-Policy header missing"
    fi

    if echo "$headers" | grep -qi "X-Content-Type-Options"; then
        print_success "X-Content-Type-Options header present"
    else
        print_error "X-Content-Type-Options header missing"
    fi
}

# Function to test SQL injection protection
test_sql_injection_protection() {
    print_status "Testing SQL injection protection..."

    local sql_payloads=(
        "' OR '1'='1"
        "1' UNION SELECT 1,2,3--"
        "'; DROP TABLE users; --"
        "1' OR 1=1#"
    )

    for payload in "${sql_payloads[@]}"; do
        local response_code
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL/?id=${payload// /%20}" 2>/dev/null)

        if [ "$response_code" -eq 403 ] || [ "$response_code" -eq 400 ]; then
            print_success "SQL injection blocked: $payload"
        else
            print_warning "SQL injection not blocked (HTTP $response_code): $payload"
        fi
    done
}

# Function to test XSS protection
test_xss_protection() {
    print_status "Testing XSS protection..."

    local xss_payloads=(
        "<script>alert('xss')</script>"
        "<img src=x onerror=alert('xss')>"
        "javascript:alert('xss')"
        "<svg onload=alert('xss')>"
    )

    for payload in "${xss_payloads[@]}"; do
        local response_code
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL/?search=${payload// /%20}" 2>/dev/null)

        if [ "$response_code" -eq 403 ] || [ "$response_code" -eq 400 ]; then
            print_success "XSS attack blocked: $payload"
        else
            print_warning "XSS attack not blocked (HTTP $response_code): $payload"
        fi
    done
}

# Function to test rate limiting
test_rate_limiting() {
    print_status "Testing rate limiting..."

    local blocked=0
    local total=20

    for i in $(seq 1 $total); do
        local response_code
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL" 2>/dev/null)

        if [ "$response_code" -eq 429 ]; then
            blocked=$((blocked + 1))
        fi

        sleep 0.1
    done

    if [ $blocked -gt 0 ]; then
        print_success "Rate limiting active ($blocked/$total requests blocked)"
    else
        print_warning "Rate limiting not triggered"
    fi
}

# Function to test file access protection
test_file_access_protection() {
    print_status "Testing file access protection..."

    local sensitive_files=(
        "/.env"
        "/etc/passwd"
        "/.git/config"
        "/config.ini"
        "/backup.sql"
        "/app.log"
    )

    for file in "${sensitive_files[@]}"; do
        local response_code
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL$file" 2>/dev/null)

        if [ "$response_code" -eq 403 ] || [ "$response_code" -eq 404 ]; then
            print_success "Sensitive file blocked: $file"
        else
            print_warning "Sensitive file accessible (HTTP $response_code): $file"
        fi
    done
}

# Function to test OpenAppSec status endpoint
test_openappsec_status() {
    print_status "Testing OpenAppSec status endpoint..."

    # This should be blocked for external access
    local response_code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL/open-appsec-status" 2>/dev/null)

    if [ "$response_code" -eq 403 ]; then
        print_success "OpenAppSec status endpoint properly restricted"
    else
        print_warning "OpenAppSec status endpoint accessible (HTTP $response_code)"
    fi
}

# Function to generate test report
generate_report() {
    echo
    print_status "🛡️  OpenAppSec Security Test Report"
    echo "=================================="
    echo "Target: $TARGET_URL"
    echo "Date: $(date)"
    echo "Tests completed: Security headers, SQL injection, XSS, rate limiting, file access"
    echo
    echo "📋 Summary:"
    echo "  • Server availability: Tested"
    echo "  • Security headers: Validated"
    echo "  • SQL injection protection: Tested"
    echo "  • XSS protection: Tested"
    echo "  • Rate limiting: Tested"
    echo "  • File access protection: Tested"
    echo "  • Status endpoint restriction: Tested"
    echo
    echo "✅ OpenAppSec integration test completed"
}

# Main execution
main() {
    echo "🛡️  OpenAppSec Security Tests"
    echo "============================="
    echo

    if ! test_server_availability; then
        print_error "Cannot proceed without server availability"
        exit 1
    fi

    echo
    test_security_headers
    echo
    test_sql_injection_protection
    echo
    test_xss_protection
    echo
    test_rate_limiting
    echo
    test_file_access_protection
    echo
    test_openappsec_status

    generate_report
}

# Show usage if help requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "OpenAppSec Security Test Script"
    echo
    echo "Usage: $0 [URL]"
    echo
    echo "Arguments:"
    echo "  URL    Target URL to test (default: http://localhost:8080)"
    echo
    echo "Examples:"
    echo "  $0                           # Test localhost:8080"
    echo "  $0 http://localhost:8080     # Test specific URL"
    echo
    echo "Tests performed:"
    echo "  • Server availability"
    echo "  • Security headers validation"
    echo "  • SQL injection protection"
    echo "  • XSS protection"
    echo "  • Rate limiting"
    echo "  • File access protection"
    exit 0
fi

# Allow custom target URL
if [[ -n "${1:-}" ]]; then
    TARGET_URL="$1"
fi

# Run tests
main
