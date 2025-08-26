# 📂 Repository Separation Plan

## FreshThreads Frontend/Backend Split

### Overview

This document outlines the plan to separate the FreshThreads monorepo into two focused repositories:

- **freshthreads-frontend**: Static website with GitHub Pages deployment
- **freshthreads-backend**: Flask API services with container deployment

---

## 🎨 Frontend Repository: `freshthreads-frontend`

### **Core Files to Move**

```
freshthreads-frontend/
├── docs/                           # Entire frontend application
│   ├── *.html                     # All HTML pages
│   ├── assets/                    # CSS, JS, images, fonts
│   ├── styles/                    # Stylesheets
│   ├── favicon.svg                # Site favicon
│   ├── sitemap.xml               # SEO sitemap
│   ├── robots.txt                # Search engine instructions
│   ├── sw.js                     # Service worker
│   └── CNAME                     # GitHub Pages domain config
├── .github/workflows/             # Frontend CI/CD
│   ├── deploy-pages.yml          # GitHub Pages deployment
│   ├── frontend-tests.yml        # HTML validation, Lighthouse
│   └── security-frontend.yml     # Frontend security scans
├── package.json                   # Frontend build tools
├── package-lock.json            # NPM dependencies lock
├── .gitignore                    # Frontend-specific ignores
├── README.md                     # Frontend setup guide
└── docs-config/                  # Configuration templates
    ├── .env.example              # Frontend environment variables
    ├── api-endpoints.js          # Backend API configuration
    └── deployment.md             # Frontend deployment guide
```

### **Frontend-Specific Dependencies**

- **Build Tools**: Prettier, HTML validator, Lighthouse
- **Development**: http-server, live-reload tools
- **Testing**: Lighthouse CI, HTML validation
- **Deployment**: GitHub Pages actions

### **Configuration Changes Needed**

1. **API Endpoints**: Update all API calls to point to backend service URLs
2. **CORS Configuration**: Frontend domain needs to be allowed in backend
3. **Environment Variables**: Separate frontend config (API URLs, keys)
4. **Build Pipeline**: Independent CI/CD for static site deployment

---

## ⚙️ Backend Repository: `freshthreads-backend`

### **Core Files to Move**

```
freshthreads-backend/
├── api/                          # Flask API services
│   ├── printify_proxy.py        # Printify integration
│   ├── payment_api.py           # Payment processing
│   ├── contact_api.py           # Contact form handler
│   └── __init__.py              # Package initialization
├── app.py                       # Main Flask application
├── requirements.txt             # Python dependencies
├── .env.example                 # Backend environment template
├── docker/                      # Container configurations
│   ├── Dockerfile              # Backend container
│   ├── docker-compose.yml      # Local development stack
│   └── nginx.conf              # Reverse proxy config
├── deployment/                  # Deployment configurations
│   ├── aws/                    # AWS deployment scripts
│   ├── azure/                  # Azure deployment scripts
│   └── kubernetes/             # K8s manifests
├── tests/                      # Backend API tests
├── .github/workflows/          # Backend CI/CD
│   ├── api-tests.yml          # API testing pipeline
│   ├── security-backend.yml   # Backend security scans
│   └── deploy-backend.yml     # Container deployment
├── README.md                   # Backend setup guide
└── docs/                       # API documentation
    ├── api-reference.md        # API endpoints documentation
    ├── deployment-guide.md     # Backend deployment guide
    └── environment-setup.md    # Development environment setup
```

### **Backend-Specific Dependencies**

- **Runtime**: Flask, Flask-CORS, requests
- **Development**: pytest, black, mypy
- **Production**: gunicorn, nginx (containerized)
- **Monitoring**: APM tools, health checks

### **Configuration Changes Needed**

1. **CORS Settings**: Configure allowed origins for frontend domain
2. **Environment Variables**: Backend-specific secrets and configs
3. **Health Checks**: Add monitoring endpoints
4. **Container Deployment**: Independent container registry and deployment

---

## 🔄 Migration Process

### **Phase 1: Repository Setup**

1. **Create Frontend Repo**: Initialize `freshthreads-frontend`
2. **Create Backend Repo**: Initialize `freshthreads-backend`
3. **Set Up Basic Structure**: Create initial directory layouts

### **Phase 2: Content Migration**

1. **Frontend Migration**:

   ```bash
   # Copy frontend files
   cp -r docs/* freshthreads-frontend/
   cp package.json freshthreads-frontend/
   cp package-lock.json freshthreads-frontend/

   # Copy relevant configs
   cp .github/workflows/*frontend* freshthreads-frontend/.github/workflows/
   cp .github/workflows/*pages* freshthreads-frontend/.github/workflows/
   ```

2. **Backend Migration**:

   ```bash
   # Copy backend files
   cp -r api/ freshthreads-backend/
   cp requirements.txt freshthreads-backend/
   cp docker-compose.yml freshthreads-backend/

   # Copy backend configs
   cp -r deployment/ freshthreads-backend/
   cp .github/workflows/*api* freshthreads-backend/.github/workflows/
   ```

### **Phase 3: Configuration Updates**

#### **Frontend Configuration**

1. **Update API Endpoints**: Create environment-based API configuration

   ```javascript
   // api-config.js
   const API_CONFIG = {
     development: 'http://localhost:8000',
     staging: 'https://api-staging.freshthreadsllc.com',
     production: 'https://api.freshthreadsllc.com',
   };
   ```

2. **GitHub Pages Setup**: Configure custom domain and deployment

#### **Backend Configuration**

1. **CORS Setup**: Configure allowed origins

   ```python
   CORS(app, origins=[
       'https://freshthreadsllc.com',
       'https://localhost:5500',  # Local development
       'http://localhost:5500'
   ])
   ```

2. **Environment Variables**: Separate backend-specific configs

### **Phase 4: CI/CD Pipeline Setup**

#### **Frontend Pipeline**

- **Triggers**: Push to main, PR to main
- **Steps**:
  1. HTML validation
  2. Lighthouse testing
  3. Security scanning
  4. Deploy to GitHub Pages

#### **Backend Pipeline**

- **Triggers**: Push to main, PR to main
- **Steps**:
  1. Python testing (pytest)
  2. Security scanning
  3. Docker build
  4. Deploy to container platform

### **Phase 5: DNS and Routing**

1. **Frontend**: `freshthreadsllc.com` → GitHub Pages
2. **Backend**: `api.freshthreadsllc.com` → Container platform
3. **SSL Certificates**: Separate certificates for each domain

---

## 🔗 Integration Points

### **API Communication**

- **Development**: Backend runs on `localhost:8000`
- **Production**: Backend accessible via `api.freshthreadsllc.com`
- **Authentication**: JWT tokens passed between services
- **Error Handling**: Graceful degradation if backend unavailable

### **Shared Dependencies**

- **Orchestration Repo**: Infrastructure as Code
- **Shared Assets**: Common branding, logos (consider npm package or CDN)
- **Documentation**: Cross-repository links and references

---

## 📋 Post-Migration Checklist

### **Frontend Repository**

- [ ] GitHub Pages deployment working
- [ ] All API calls updated to backend URLs
- [ ] Lighthouse scores maintained
- [ ] Search engine optimization intact
- [ ] Custom domain configured

### **Backend Repository**

- [ ] All API endpoints functional
- [ ] CORS properly configured
- [ ] Environment variables separated
- [ ] Container deployment working
- [ ] Health checks responding
- [ ] API documentation updated

### **Integration Testing**

- [ ] Frontend-backend communication working
- [ ] Payment processing functional
- [ ] Printify integration operational
- [ ] Contact forms working
- [ ] Error handling graceful

---

## 🎯 Benefits of This Separation

1. **Independent Scaling**: Frontend CDN vs backend containers
2. **Team Autonomy**: Different teams can own different repos
3. **Technology Flexibility**: Different tech stacks and update cycles
4. **Security**: Backend secrets isolated from frontend
5. **Deployment Speed**: Faster deployments for each component
6. **Cost Optimization**: Frontend free (GitHub Pages), backend optimized for load

---

## 🚀 Next Steps

1. **Decision**: Confirm this separation approach
2. **Timeline**: Establish migration timeline
3. **Resources**: Assign team members to each repository
4. **Testing**: Plan integration testing strategy
5. **Rollback Plan**: Prepare rollback strategy if needed

This separation will provide a solid foundation for scaling FreshThreads as the business grows!
