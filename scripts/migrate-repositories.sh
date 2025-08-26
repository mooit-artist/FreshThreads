#!/bin/bash

# 🔄 Repository Migration Script
# Helps separate FreshThreads into frontend and backend repositories

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Configuration
CURRENT_DIR=$(pwd)
FRONTEND_REPO="freshthreads-frontend"
BACKEND_REPO="freshthreads-backend"

echo "🔄 FreshThreads Repository Migration"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "docs" ] || [ ! -d "api" ]; then
    log_error "This script must be run from the FreshThreads repository root"
    exit 1
fi

log_info "Current directory: $CURRENT_DIR"
echo ""

# Function to create frontend repository structure
create_frontend_repo() {
    local repo_dir="$1"

    log_info "Creating frontend repository structure in $repo_dir..."

    mkdir -p "$repo_dir"
    cd "$repo_dir"

    # Initialize git
    git init

    # Copy frontend files
    log_info "Copying frontend files..."
    cp -r "$CURRENT_DIR/docs"/* .

    # Copy frontend-specific configs
    cp "$CURRENT_DIR/package.json" .
    cp "$CURRENT_DIR/package-lock.json" . 2>/dev/null || true

    # Create frontend-specific .gitignore
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.npm
.yarn

# Build outputs
dist/
build/
.cache/

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Coverage
coverage/
.nyc_output

# Temporary
tmp/
temp/
EOF

    # Create frontend README
    cat > README.md << 'EOF'
# FreshThreads Frontend

Static website for FreshThreads e-commerce platform.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Format code
npm run format

# Validate HTML
npm run validate
```

## 📁 Structure

```
├── index.html          # Homepage
├── products.html       # Product catalog
├── cart.html          # Shopping cart
├── checkout.html       # Checkout process
├── assets/            # CSS, JS, images
├── styles/            # Stylesheets
└── docs/              # Documentation
```

## 🔗 Backend Integration

The frontend communicates with the backend API:
- Development: `http://localhost:8000`
- Production: `https://api.freshthreadsllc.com`

## 🌐 Deployment

Deployed via GitHub Pages to `freshthreadsllc.com`

## 🧪 Testing

- HTML validation with html-validate
- Performance testing with Lighthouse
- Cross-browser compatibility testing

EOF

    # Update package.json for frontend-only
    cat > package.json << 'EOF'
{
  "name": "freshthreads-frontend",
  "version": "1.0.0",
  "description": "FreshThreads e-commerce frontend",
  "main": "index.html",
  "scripts": {
    "dev": "npx http-server . -p 5500 -c-1 -o",
    "format": "prettier --write *.html assets/**/*.css assets/**/*.js",
    "validate": "html-validate *.html",
    "lighthouse": "lighthouse http://localhost:5500 --output=json --output-path=./lighthouse-report.json",
    "build": "echo 'Static site - no build required'",
    "deploy": "echo 'Deployed via GitHub Pages'"
  },
  "devDependencies": {
    "prettier": "^3.0.0",
    "html-validate": "^8.0.0",
    "lighthouse": "^11.0.0",
    "http-server": "^14.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/mooit-artist/freshthreads-frontend.git"
  },
  "keywords": ["ecommerce", "frontend", "static-site", "printify"],
  "author": "FreshThreads LLC",
  "license": "MIT"
}
EOF

    log_success "Frontend repository created in $repo_dir"
    cd "$CURRENT_DIR"
}

# Function to create backend repository structure
create_backend_repo() {
    local repo_dir="$1"

    log_info "Creating backend repository structure in $repo_dir..."

    mkdir -p "$repo_dir"
    cd "$repo_dir"

    # Initialize git
    git init

    # Copy backend files
    log_info "Copying backend files..."
    cp -r "$CURRENT_DIR/api" .
    cp "$CURRENT_DIR/requirements.txt" .
    cp "$CURRENT_DIR/app.py" .
    cp "$CURRENT_DIR/.env.example" . 2>/dev/null || true

    # Copy deployment configs
    mkdir -p deployment
    cp -r "$CURRENT_DIR/deployment/docker" deployment/ 2>/dev/null || true
    cp "$CURRENT_DIR/docker-compose.yml" . 2>/dev/null || true

    # Create backend-specific .gitignore
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
.pytest_cache/
.coverage
htmlcov/

# Databases
*.db
*.sqlite3

# Secrets
.env
*.pem
*.key
EOF

    # Create backend README
    cat > README.md << 'EOF'
# FreshThreads Backend

Flask API server for FreshThreads e-commerce platform.

## 🚀 Quick Start

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your API keys

# Run the server
python app.py
```

## 📁 Structure

```
├── app.py              # Main Flask application
├── api/                # API modules
│   ├── printify_proxy.py   # Printify integration
│   ├── payment_api.py      # Payment processing
│   └── contact_api.py      # Contact forms
├── deployment/         # Deployment configs
├── tests/             # Unit tests
└── requirements.txt   # Python dependencies
```

## 🔌 API Endpoints

- `GET /health` - Health check
- `GET /api` - API information
- `GET /api/printify/*` - Printify proxy endpoints
- `POST /api/payment/*` - Payment processing
- `POST /api/contact/*` - Contact form handling

## 🐳 Docker Deployment

```bash
# Build image
docker build -t freshthreads-backend .

# Run container
docker run -p 8000:8000 --env-file .env freshthreads-backend
```

## 🧪 Testing

```bash
# Run tests
python -m pytest

# Test API endpoints
curl http://localhost:8000/health
curl http://localhost:8000/api
```

## 🔐 Environment Variables

See `.env.example` for required environment variables.

EOF

    # Create Dockerfile for backend
    cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["python", "app.py"]
EOF

    log_success "Backend repository created in $repo_dir"
    cd "$CURRENT_DIR"
}

# Main execution
echo "This script will create two new directories:"
echo "📁 $FRONTEND_REPO - Frontend repository"
echo "📁 $BACKEND_REPO - Backend repository"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Migration cancelled"
    exit 0
fi

# Create repositories
create_frontend_repo "$FRONTEND_REPO"
create_backend_repo "$BACKEND_REPO"

echo ""
log_success "🎉 Migration complete!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Frontend Repository ($FRONTEND_REPO):"
echo "   cd $FRONTEND_REPO"
echo "   git remote add origin https://github.com/mooit-artist/freshthreads-frontend.git"
echo "   git add ."
echo "   git commit -m 'Initial frontend repository'"
echo "   git push -u origin main"
echo ""
echo "2. Backend Repository ($BACKEND_REPO):"
echo "   cd $BACKEND_REPO"
echo "   git remote add origin https://github.com/mooit-artist/freshthreads-backend.git"
echo "   git add ."
echo "   git commit -m 'Initial backend repository'"
echo "   git push -u origin main"
echo ""
echo "3. Update DNS/Deployment:"
echo "   - Frontend: GitHub Pages → freshthreadsllc.com"
echo "   - Backend: Container platform → api.freshthreadsllc.com"
echo ""
echo "4. Update API endpoints in frontend to point to backend domain"
echo ""

log_warning "Remember to:"
echo "• Create the GitHub repositories before pushing"
echo "• Update environment variables in both repos"
echo "• Test frontend-backend integration"
echo "• Set up CI/CD pipelines for each repository"
