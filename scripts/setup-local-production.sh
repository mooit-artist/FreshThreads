#!/bin/bash

# 🧪 FreshThreads Local Production Simulation
# This script sets up a local environment that mimics GitHub Pages + AWS

set -e

echo "🚀 Setting up local production simulation..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 not found"
        exit 1
    fi

    if ! command -v npx &> /dev/null; then
        echo "❌ npx not found (install Node.js)"
        exit 1
    fi

    log_success "Dependencies check passed"
}

# Create production-like frontend configuration
setup_frontend_config() {
    log_info "Setting up frontend configuration..."

    # Create a production config for local testing
    cat > docs/config/local-prod.js << 'EOF'
// Local Production Simulation Config
const CONFIG = {
    API_BASE_URL: 'http://localhost:8000',
    ENVIRONMENT: 'local-production',
    DEBUG: false,
    CORS_ENABLED: true,

    // Simulate production behavior
    CACHE_ENABLED: true,
    ERROR_REPORTING: true,
    ANALYTICS_ENABLED: false // Don't spam analytics in testing
};

// Make config available globally
window.FRESH_THREADS_CONFIG = CONFIG;
EOF

    log_success "Frontend config created"
}

# Update frontend to use production-like URLs
update_frontend_api_calls() {
    log_info "Updating frontend API configuration..."

    # Backup original file
    if [ ! -f "docs/assets/js/print-on-demand.js.backup" ]; then
        cp docs/assets/js/print-on-demand.js docs/assets/js/print-on-demand.js.backup
    fi

    # Create production version that uses config
    cat > docs/assets/js/api-config.js << 'EOF'
// Production-ready API configuration
class APIConfig {
    constructor() {
        // Use config if available, otherwise fall back to defaults
        this.config = window.FRESH_THREADS_CONFIG || {
            API_BASE_URL: 'http://localhost:8000',
            ENVIRONMENT: 'development'
        };
    }

    getBaseURL() {
        return this.config.API_BASE_URL;
    }

    getEnvironment() {
        return this.config.ENVIRONMENT;
    }

    isProduction() {
        return this.config.ENVIRONMENT === 'production';
    }

    isLocalProduction() {
        return this.config.ENVIRONMENT === 'local-production';
    }
}

// Global API config instance
window.apiConfig = new APIConfig();

// Production-ready fetch wrapper
async function fetchAPI(endpoint, options = {}) {
    const baseURL = window.apiConfig.getBaseURL();
    const url = `${baseURL}${endpoint}`;

    const defaultOptions = {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    };

    const config = { ...defaultOptions, ...options };

    try {
        console.log(`🔗 API Call: ${config.method} ${url}`);
        const response = await fetch(url, config);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('❌ API Error:', error);
        throw error;
    }
}
EOF

    log_success "Frontend API configuration updated"
}

# Setup backend for production simulation
setup_backend_config() {
    log_info "Setting up backend for production simulation..."

    # Create production-like Flask configuration
    cat > config/local-production.py << 'EOF'
# Local Production Configuration
import os

class LocalProductionConfig:
    # Flask settings
    DEBUG = False
    TESTING = False

    # CORS settings (more restrictive than dev)
    CORS_ORIGINS = ['http://localhost:5500', 'https://freshthreadsllc.com']

    # Logging
    LOG_LEVEL = 'INFO'
    LOG_FILE = 'logs/local-production.log'

    # API settings
    API_RATE_LIMIT = '100 per minute'

    # Security headers
    SECURITY_HEADERS = {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block'
    }

    @staticmethod
    def init_app(app):
        # Add security headers
        @app.after_request
        def add_security_headers(response):
            for header, value in LocalProductionConfig.SECURITY_HEADERS.items():
                response.headers[header] = value
            return response
EOF

    # Create directories if they don't exist
    mkdir -p config
    mkdir -p logs

    log_success "Backend configuration created"
}

# Create startup scripts
create_startup_scripts() {
    log_info "Creating startup scripts..."

    # Frontend startup script
    cat > scripts/start-frontend-local-prod.sh << 'EOF'
#!/bin/bash
echo "🌐 Starting Frontend (Local Production Mode)"
echo "URL: http://localhost:5500"
echo "Simulating: GitHub Pages"
echo "API Target: http://localhost:8000"
echo ""

cd docs
npx http-server . -p 5500 -c-1 --cors -o
EOF

    # Backend startup script
    cat > scripts/start-backend-local-prod.sh << 'EOF'
#!/bin/bash
echo "☁️ Starting Backend (Local Production Mode)"
echo "URL: http://localhost:8000"
echo "Simulating: AWS App Runner"
echo "Config: Production-like settings"
echo ""

export FLASK_ENV=production
export FLASK_CONFIG=local-production

# Start with production-like settings
python3 -c "
import sys
sys.path.append('.')
from api.printify_proxy import app

# Production-like configuration
app.config['DEBUG'] = False
app.config['TESTING'] = False

print('🚀 Backend starting in local production mode...')
app.run(host='0.0.0.0', port=8000, debug=False)
"
EOF

    chmod +x scripts/start-frontend-local-prod.sh
    chmod +x scripts/start-backend-local-prod.sh

    log_success "Startup scripts created"
}

# Create testing script
create_test_script() {
    log_info "Creating integration test script..."

    cat > scripts/test-local-production.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing Local Production Environment"
echo "======================================"

# Test backend health
echo "1. Testing backend health..."
curl -s http://localhost:8000/health || echo "❌ Backend not responding"

# Test CORS
echo "2. Testing CORS headers..."
curl -s -H "Origin: http://localhost:5500" http://localhost:8000/api/products | head -1

# Test API endpoints
echo "3. Testing Printify integration..."
curl -s "http://localhost:8000/api/printify/shops/6563836/products.json" | head -1

echo ""
echo "✅ Local production test complete"
echo "Frontend: http://localhost:5500"
echo "Backend: http://localhost:8000"
EOF

    chmod +x scripts/test-local-production.sh

    log_success "Test script created"
}

# Main setup function
main() {
    echo "🧪 FreshThreads Local Production Simulation Setup"
    echo "================================================="

    check_dependencies
    setup_frontend_config
    update_frontend_api_calls
    setup_backend_config
    create_startup_scripts
    create_test_script

    echo ""
    log_success "🎉 Local production environment setup complete!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Start backend:  ./scripts/start-backend-local-prod.sh"
    echo "2. Start frontend: ./scripts/start-frontend-local-prod.sh"
    echo "3. Run tests:      ./scripts/test-local-production.sh"
    echo ""
    echo "🌐 URLs:"
    echo "Frontend: http://localhost:5500 (simulates GitHub Pages)"
    echo "Backend:  http://localhost:8000 (simulates AWS App Runner)"
}

main "$@"
