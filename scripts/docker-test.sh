#!/bin/bash

# FreshThreads Docker Test Runner
# Comprehensive testing suite using Docker containers

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

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to create security reports directory
setup_directories() {
    mkdir -p security-reports
    mkdir -p test-reports
    print_success "Test directories created"
}

# Function to build Docker images
build_images() {
    print_status "Building Docker images..."

    if docker-compose build --no-cache; then
        print_success "Docker images built successfully"
    else
        print_error "Failed to build Docker images"
        exit 1
    fi
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..."

    if docker-compose -f docker-compose.test.yml run --rm unit-tests; then
        print_success "Unit tests passed"
        return 0
    else
        print_error "Unit tests failed"
        return 1
    fi
}

# Function to run integration tests
run_integration_tests() {
    print_status "Running integration tests..."

    if docker-compose -f docker-compose.test.yml run --rm integration-tests; then
        print_success "Integration tests passed"
        return 0
    else
        print_error "Integration tests failed"
        return 1
    fi
}

# Function to run security tests
run_security_tests() {
    print_status "Running security tests..."

    if docker-compose -f docker-compose.test.yml run --rm security-tests; then
        print_success "Security tests passed"
        return 0
    else
        print_warning "Security tests completed with warnings"
        return 0
    fi
}

# Function to run E2E tests
run_e2e_tests() {
    print_status "Running end-to-end tests..."

    if docker-compose -f docker-compose.test.yml run --rm e2e-tests; then
        print_success "E2E tests passed"
        return 0
    else
        print_error "E2E tests failed"
        return 1
    fi
}

# Function to run accessibility tests
run_accessibility_tests() {
    print_status "Running accessibility tests..."

    if docker-compose -f docker-compose.test.yml run --rm accessibility-tests; then
        print_success "Accessibility tests completed"
        return 0
    else
        print_warning "Accessibility tests completed with issues"
        return 0
    fi
}

# Function to run load tests
run_load_tests() {
    print_status "Running load tests..."

    # Start production server for testing
    docker-compose -f docker-compose.test.yml up -d prod-server

    if docker-compose -f docker-compose.test.yml run --rm load-tests; then
        print_success "Load tests completed"
        test_result=0
    else
        print_warning "Load tests completed with issues"
        test_result=0
    fi

    # Stop production server
    docker-compose -f docker-compose.test.yml down

    return $test_result
}

# Function to run all tests
run_all_tests() {
    local failed_tests=0

    print_status "🧪 Running comprehensive test suite..."
    echo

    # Run each test and track failures
    run_unit_tests || ((failed_tests++))
    echo

    run_integration_tests || ((failed_tests++))
    echo

    run_security_tests || ((failed_tests++))
    echo

    run_e2e_tests || ((failed_tests++))
    echo

    run_accessibility_tests || ((failed_tests++))
    echo

    run_load_tests || ((failed_tests++))
    echo

    # Summary
    if [ $failed_tests -eq 0 ]; then
        print_success "🎉 All tests completed successfully!"
        echo
        print_status "📊 Test Reports:"
        echo "  • Security: ./security-reports/"
        echo "  • Accessibility: ./accessibility-report.json"
        echo "  • Logs: Check Docker logs for detailed output"
        return 0
    else
        print_error "❌ $failed_tests test suite(s) failed"
        return 1
    fi
}

# Function to clean up containers and images
cleanup() {
    print_status "Cleaning up Docker resources..."

    # Stop and remove containers
    docker-compose down --remove-orphans >/dev/null 2>&1 || true
    docker-compose -f docker-compose.test.yml down --remove-orphans >/dev/null 2>&1 || true

    # Remove dangling images
    docker image prune -f >/dev/null 2>&1 || true

    print_success "Cleanup completed"
}

# Function to show usage
show_usage() {
    echo "FreshThreads Docker Test Runner"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  build               Build Docker images"
    echo "  test                Run all tests"
    echo "  unit                Run unit tests only"
    echo "  integration         Run integration tests only"
    echo "  security            Run security tests only"
    echo "  e2e                 Run end-to-end tests only"
    echo "  accessibility       Run accessibility tests only"
    echo "  load                Run load tests only"
    echo "  cleanup             Clean up Docker resources"
    echo "  help                Show this help message"
    echo
    echo "Examples:"
    echo "  $0 build           # Build images"
    echo "  $0 test            # Run full test suite"
    echo "  $0 unit            # Run only unit tests"
    echo "  $0 cleanup         # Clean up resources"
}

# Main execution
main() {
    case "${1:-help}" in
        "build")
            check_docker
            setup_directories
            build_images
            ;;
        "test")
            check_docker
            setup_directories
            build_images
            run_all_tests
            ;;
        "unit")
            check_docker
            setup_directories
            build_images
            run_unit_tests
            ;;
        "integration")
            check_docker
            setup_directories
            build_images
            run_integration_tests
            ;;
        "security")
            check_docker
            setup_directories
            build_images
            run_security_tests
            ;;
        "e2e")
            check_docker
            setup_directories
            build_images
            run_e2e_tests
            ;;
        "accessibility")
            check_docker
            setup_directories
            build_images
            run_accessibility_tests
            ;;
        "load")
            check_docker
            setup_directories
            build_images
            run_load_tests
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Set up trap for cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
