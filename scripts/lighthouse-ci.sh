#!/bin/bash

# FreshThreads Lighthouse CI Script for GitHub Actions
# Simplified version without heavy dependencies

set -e

echo "🚀 FreshThreads Lighthouse CI"
echo "============================="

# Configuration
SERVER_PORT=5500
SERVER_URL="http://localhost:${SERVER_PORT}"
MIN_PERFORMANCE_SCORE=90
MIN_ACCESSIBILITY_SCORE=90
MIN_BEST_PRACTICES_SCORE=90
MIN_SEO_SCORE=90

# URLs to test (using virtual/clean paths)
declare -a URLS=(
    "${SERVER_URL}/"
    "${SERVER_URL}/products"
    "${SERVER_URL}/about"
    "${SERVER_URL}/contact"
)

declare -a URL_NAMES=(
    "Homepage"
    "Products"
    "About"
    "Contact"
)

# Function to install lighthouse if not available
install_lighthouse() {
    echo "Installing Lighthouse CLI..."
    npm install -g lighthouse@latest
}

# Function to check lighthouse installation
check_lighthouse() {
    if command -v lighthouse &> /dev/null; then
        echo "✅ Lighthouse CLI found"
        return 0
    else
        echo "❌ Lighthouse CLI not found, installing..."
        install_lighthouse
        return $?
    fi
}

# Function to wait for server
wait_for_server() {
    echo "Waiting for server to be ready..."
    local attempts=0
    local max_attempts=30

    while [ $attempts -lt $max_attempts ]; do
        if curl -s -f "$SERVER_URL" > /dev/null; then
            echo "✅ Server is ready"
            return 0
        fi

        attempts=$((attempts + 1))
        echo "Waiting... (attempt $attempts/$max_attempts)"
        sleep 2
    done

    echo "❌ Server failed to start within expected time"
    return 1
}

# Function to run lighthouse test
run_ci_test() {
    local url=$1
    local name=$2

    echo "📊 Testing $name ($url)..."

    # Run lighthouse and capture output
    local output
    output=$(lighthouse "$url" \
        --only-categories=performance,accessibility,best-practices,seo \
        --output=json \
        --chrome-flags="--headless --no-sandbox --disable-gpu" \
        --quiet 2>/dev/null) || {
        echo "❌ Lighthouse test failed for $name"
        return 1
    }

    # Parse scores using node (more reliable than jq)
    local scores
    scores=$(echo "$output" | node -e "
        const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
        const cats = data.categories;
        console.log(JSON.stringify({
            performance: Math.round(cats.performance.score * 100),
            accessibility: Math.round(cats.accessibility.score * 100),
            bestPractices: Math.round(cats['best-practices'].score * 100),
            seo: Math.round(cats.seo.score * 100)
        }));
    " 2>/dev/null) || {
        echo "❌ Failed to parse scores for $name"
        return 1
    }

    # Extract individual scores
    local performance accessibility best_practices seo
    performance=$(echo "$scores" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).performance)" 2>/dev/null || echo "0")
    accessibility=$(echo "$scores" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).accessibility)" 2>/dev/null || echo "0")
    best_practices=$(echo "$scores" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).bestPractices)" 2>/dev/null || echo "0")
    seo=$(echo "$scores" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).seo)" 2>/dev/null || echo "0")

    echo "✅ $name Results:"
    echo "   Performance: $performance/100"
    echo "   Accessibility: $accessibility/100"
    echo "   Best Practices: $best_practices/100"
    echo "   SEO: $seo/100"

    # Check thresholds
    local failed=false

    if [ "$performance" -lt $MIN_PERFORMANCE_SCORE ]; then
        echo "❌ Performance score ($performance) below threshold ($MIN_PERFORMANCE_SCORE)"
        failed=true
    fi

    if [ "$accessibility" -lt $MIN_ACCESSIBILITY_SCORE ]; then
        echo "❌ Accessibility score ($accessibility) below threshold ($MIN_ACCESSIBILITY_SCORE)"
        failed=true
    fi

    if [ "$best_practices" -lt $MIN_BEST_PRACTICES_SCORE ]; then
        echo "❌ Best Practices score ($best_practices) below threshold ($MIN_BEST_PRACTICES_SCORE)"
        failed=true
    fi

    if [ "$seo" -lt $MIN_SEO_SCORE ]; then
        echo "❌ SEO score ($seo) below threshold ($MIN_SEO_SCORE)"
        failed=true
    fi

    if [ "$failed" = true ]; then
        return 1
    else
        echo "✅ All scores meet thresholds"
        return 0
    fi
}

# Main execution
main() {
    echo "Starting CI performance tests..."

    # Check lighthouse
    if ! check_lighthouse; then
        echo "❌ Failed to install/find Lighthouse"
        exit 1
    fi

    # Wait for server
    if ! wait_for_server; then
        echo "❌ Server not ready"
        exit 1
    fi

    # Run tests
    local failed_tests=0

    for i in "${!URLS[@]}"; do
        if ! run_ci_test "${URLS[$i]}" "${URL_NAMES[$i]}"; then
            failed_tests=$((failed_tests + 1))
        fi
        echo ""
    done

    # Final result
    if [ $failed_tests -eq 0 ]; then
        echo "🎉 All CI tests passed!"
        exit 0
    else
        echo "❌ $failed_tests test(s) failed"
        exit 1
    fi
}

# Run main function
main "$@"
