#!/bin/bash

# FreshThreads Lighthouse Performance Test Script
# This script runs Lighthouse tests without heavy npm dependencies

set -e

echo "🚀 FreshThreads Lighthouse Performance Test"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVER_PORT=5500
SERVER_URL="http://localhost:${SERVER_PORT}"
REPORTS_DIR="lighthouse-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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

# Create reports directory
mkdir -p "$REPORTS_DIR"

# Function to check if server is running
check_server() {
    echo -e "${BLUE}Checking if server is running on port ${SERVER_PORT}...${NC}"
    if curl -s -f "$SERVER_URL" > /dev/null; then
        echo -e "${GREEN}✅ Server is running${NC}"
        return 0
    else
        echo -e "${RED}❌ Server is not running${NC}"
        return 1
    fi
}

# Function to start server if needed
start_server() {
    echo -e "${YELLOW}Starting HTTP server...${NC}"
    cd docs && http-server . -p $SERVER_PORT -c-1 --silent &
    SERVER_PID=$!
    echo "Server PID: $SERVER_PID"
    sleep 3

    if check_server; then
        echo -e "${GREEN}✅ Server started successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to start server${NC}"
        return 1
    fi
}

# Function to stop server
cleanup() {
    if [ ! -z "$SERVER_PID" ]; then
        echo -e "${YELLOW}Stopping server (PID: $SERVER_PID)...${NC}"
        kill "$SERVER_PID" 2>/dev/null || true
    fi
}

# Function to check if lighthouse is installed
check_lighthouse() {
    if command -v lighthouse &> /dev/null; then
        echo -e "${GREEN}✅ Lighthouse CLI found${NC}"
        lighthouse --version
        return 0
    else
        echo -e "${RED}❌ Lighthouse CLI not found${NC}"
        echo -e "${YELLOW}Install with: npm install -g lighthouse${NC}"
        return 1
    fi
}

# Function to run lighthouse on a single URL
run_lighthouse_test() {
    local url=$1
    local name=$2
    local output_file="${REPORTS_DIR}/lighthouse_${name,,}_${TIMESTAMP}"

    echo -e "${BLUE}📊 Testing ${name} (${url})...${NC}"

    # Run lighthouse with minimal configuration
    lighthouse "$url" \
        --only-categories=performance,accessibility,best-practices,seo,pwa \
        --output=json,html \
        --output-path="$output_file" \
        --chrome-flags="--headless --no-sandbox --disable-gpu" \
        --quiet || {
        echo -e "${RED}❌ Lighthouse test failed for ${name}${NC}"
        return 1
    }

    # Extract key metrics from JSON report
    if [ -f "${output_file}.report.json" ]; then
        local json_file="${output_file}.report.json"
        local performance=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.performance.score * 100))" 2>/dev/null || echo "N/A")
        local accessibility=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.accessibility.score * 100))" 2>/dev/null || echo "N/A")
        local best_practices=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories['best-practices'].score * 100))" 2>/dev/null || echo "N/A")
        local seo=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.seo.score * 100))" 2>/dev/null || echo "N/A")
        local pwa=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.pwa.score * 100))" 2>/dev/null || echo "N/A")

        echo -e "${GREEN}✅ ${name} Results:${NC}"
        echo -e "   Performance: ${performance}/100"
        echo -e "   Accessibility: ${accessibility}/100"
        echo -e "   Best Practices: ${best_practices}/100"
        echo -e "   SEO: ${seo}/100"
        echo -e "   PWA: ${pwa}/100"
        echo -e "   📄 HTML Report: ${output_file}.report.html"
        echo -e "   📊 JSON Report: ${output_file}.report.json"
        echo ""

        # Check if performance meets threshold
        if [ "$performance" != "N/A" ] && [ "$performance" -lt 90 ]; then
            echo -e "${YELLOW}⚠️ Warning: ${name} performance score (${performance}) is below 90${NC}"
            PERFORMANCE_WARNINGS=true
        fi
    else
        echo -e "${RED}❌ Failed to generate JSON report for ${name}${NC}"
    fi
}

# Function to generate summary report
generate_summary() {
    echo -e "${BLUE}📋 Generating Summary Report...${NC}"

    local summary_file="${REPORTS_DIR}/lighthouse_summary_${TIMESTAMP}.md"

    cat > "$summary_file" << EOF
# 🚀 FreshThreads Lighthouse Performance Report

**Generated:** $(date)
**Test Run:** $TIMESTAMP

## Results Summary

EOF

    for i in "${!URL_NAMES[@]}"; do
        local name="${URL_NAMES[$i]}"
        local json_file="${REPORTS_DIR}/lighthouse_${name,,}_${TIMESTAMP}.report.json"

        if [ -f "$json_file" ]; then
            echo "### ${name}" >> "$summary_file"
            echo "" >> "$summary_file"

            # Extract metrics and add to summary
            local performance=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.performance.score * 100))" 2>/dev/null || echo "N/A")
            local accessibility=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.accessibility.score * 100))" 2>/dev/null || echo "N/A")
            local best_practices=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories['best-practices'].score * 100))" 2>/dev/null || echo "N/A")
            local seo=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.seo.score * 100))" 2>/dev/null || echo "N/A")
            local pwa=$(node -e "console.log(Math.round(JSON.parse(require('fs').readFileSync('$json_file')).categories.pwa.score * 100))" 2>/dev/null || echo "N/A")

            echo "- **Performance:** ${performance}/100" >> "$summary_file"
            echo "- **Accessibility:** ${accessibility}/100" >> "$summary_file"
            echo "- **Best Practices:** ${best_practices}/100" >> "$summary_file"
            echo "- **SEO:** ${seo}/100" >> "$summary_file"
            echo "- **PWA:** ${pwa}/100" >> "$summary_file"
            echo "" >> "$summary_file"
        fi
    done

    echo -e "${GREEN}✅ Summary report generated: ${summary_file}${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting Lighthouse performance tests...${NC}"

    # Check if lighthouse is available
    if ! check_lighthouse; then
        echo -e "${RED}Please install Lighthouse CLI: npm install -g lighthouse${NC}"
        exit 1
    fi

    # Check if server is running, start if needed
    local server_started=false
    if ! check_server; then
        if start_server; then
            server_started=true
            trap cleanup EXIT
        else
            echo -e "${RED}Failed to start server. Please start it manually with: npm run dev${NC}"
            exit 1
        fi
    fi

    # Run tests for each URL
    PERFORMANCE_WARNINGS=false
    for i in "${!URLS[@]}"; do
        run_lighthouse_test "${URLS[$i]}" "${URL_NAMES[$i]}"
    done

    # Generate summary
    generate_summary

    # Final status
    echo -e "${GREEN}🎉 Lighthouse tests completed!${NC}"
    echo -e "${BLUE}Reports saved to: ${REPORTS_DIR}/${NC}"

    if [ "$PERFORMANCE_WARNINGS" = true ]; then
        echo -e "${YELLOW}⚠️ Some pages have performance scores below 90${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ All performance tests passed!${NC}"
        exit 0
    fi
}

# Run main function
main "$@"
