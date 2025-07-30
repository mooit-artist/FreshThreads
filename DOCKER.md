# Docker Setup for FreshThreads

This document provides comprehensive instructions for using Docker with the FreshThreads project for development, testing, and production environments.

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)
- Basic familiarity with Docker concepts

## Quick Start

### 1. Build Docker Images

```bash
make docker-build
```

### 2. Start Development Environment

```bash
make docker-dev
```

The development server will be available at http://localhost:5500

### 3. Run Tests

```bash
make docker-test
```

## Available Docker Commands

### Build Commands

- `make docker-build` - Build all Docker images
- `docker-compose build` - Build with Docker Compose

### Development Commands

- `make docker-dev` - Start development server in Docker
- `docker-compose up dev` - Alternative development start

### Production Commands

- `make docker-prod` - Start production server in Docker
- Production server runs at http://localhost:8080
- Health check available at http://localhost:8080/health

### Testing Commands

- `make docker-test` - Run complete test suite
- `make docker-test-unit` - Unit tests only
- `make docker-test-integration` - Integration tests only
- `make docker-test-security` - Security tests only
- `make docker-test-e2e` - End-to-end tests only
- `make docker-test-accessibility` - Accessibility tests only
- `make docker-test-load` - Load/performance tests only

### Utility Commands

- `make docker-cleanup` - Clean up Docker resources
- `make docker-logs` - View container logs
- `make docker-status` - Show container status
- `make docker-security-status` - Check OpenAppSec security status
- `make docker-security-logs` - View OpenAppSec security logs

### SonarQube Code Quality Commands

- `make sonar-start` - Start SonarQube server
- `make sonar-stop` - Stop SonarQube server
- `make sonar-status` - Check SonarQube status
- `make sonar-analyze` - Run code quality analysis
- `make sonar-report` - Generate quality report
- `make sonar-cleanup` - Clean up SonarQube data
- `make sonar-logs` - View SonarQube logs
- `make sonar-backup` - Backup SonarQube data

## Docker Architecture

### Multi-Stage Dockerfile

Our Dockerfile uses multi-stage builds with three targets:

1. **Development Stage** (`development`)
   - Based on Node.js 18 Alpine
   - Includes development dependencies
   - Live reload with volume mounting
   - Port 5500 exposed

2. **Testing Stage** (`testing`)
   - Extends development stage
   - Adds testing tools and linters
   - Python environment for analysis
   - Security scanning tools

3. **Production Stage** (`production`)
   - Based on Nginx Alpine
   - **OpenAppSec integration** for web application firewall
   - Optimized static file serving
   - Security headers configured
   - Health check endpoint
   - Port 80 exposed

## OpenAppSec Integration

### What is OpenAppSec?

OpenAppSec is an open-source web application security solution that provides:

- **Web Application Firewall (WAF)** protection
- **Real-time threat detection** and blocking
- **Machine Learning-based** attack prevention
- **OWASP Top 10** protection
- **Zero-day attack** mitigation

### Security Features

- **SQL Injection** protection
- **Cross-Site Scripting (XSS)** prevention
- **Rate limiting** and DDoS protection
- **File inclusion** attack blocking
- **Malicious bot** detection
- **Real-time monitoring** and logging

### Monitoring OpenAppSec

```bash
# Check OpenAppSec status
make docker-security-status

# View security logs
make docker-security-logs

# Check security headers
curl -I http://localhost:8080
```

### Security Endpoints

- **Health Check**: `http://localhost:8080/health`
- **Security Status**: `http://localhost:8080/open-appsec-status` (internal only)

### Log Files

- OpenAppSec logs: `/var/log/nano_agent/cp_nginx.log`
- Nginx error logs: `/var/log/nginx/error.log`
- Access logs: `/var/log/nginx/access.log`

## SonarQube Code Quality Integration

### What is SonarQube?

SonarQube is a comprehensive code quality platform that provides:

- **Static Code Analysis** for multiple languages
- **Security Vulnerability** detection
- **Code Smell** identification
- **Technical Debt** measurement
- **Duplication** analysis
- **Test Coverage** tracking

### Code Quality Features

- **HTML/CSS/JavaScript** analysis
- **Python** script analysis
- **Security hotspot** detection
- **Maintainability** assessment
- **Reliability** scoring
- **Quality gate** enforcement

### SonarQube Setup

```bash
# Start SonarQube server
make sonar-start

# Wait for startup (2-3 minutes)
# Access web interface at http://localhost:9000
# Default credentials: admin/admin

# Run code analysis
make sonar-analyze

# Check results
make sonar-status
```

### Quality Metrics

SonarQube analyzes your FreshThreads project for:

- **Bugs** - Code defects that can cause runtime issues
- **Vulnerabilities** - Security weaknesses
- **Code Smells** - Maintainability issues
- **Coverage** - Test coverage percentage
- **Duplications** - Code duplication percentage
- **Complexity** - Cyclomatic complexity

### Integration Workflow

1. **Start SonarQube**: `make sonar-start`
2. **Run Analysis**: `make sonar-analyze`
3. **View Results**: http://localhost:9000/dashboard?id=freshthreads-llc
4. **Generate Report**: `make sonar-report`
5. **Monitor Quality**: Regular analysis runs

### Quality Gates

The project includes quality gates for:

- Zero bugs in new code
- Zero vulnerabilities in new code
- Code coverage > 80% on new code
- Duplicated lines < 3% on new code
- Maintainability rating A

### Security Features

- Non-root user execution
- **OpenAppSec integration** for web application firewall protection
- Security headers in Nginx
- Content Security Policy (CSP)
- Health checks for all services
- Minimal attack surface
- Real-time threat detection and blocking

## Docker Compose Services

### Development (`docker-compose.yml`)

- **dev**: Development server with live reload
- **test**: Testing environment
- **prod**: Production Nginx server
- **security-test**: OWASP ZAP security scanning
- **performance-test**: Apache Bench load testing

### Testing (`docker-compose.test.yml`)

- **unit-tests**: Linting and code quality
- **integration-tests**: HTML validation and analysis
- **security-tests**: CSP and security validation
- **e2e-tests**: Browser-based testing
- **accessibility-tests**: pa11y accessibility checking
- **load-tests**: Performance and load testing
- **prod-server**: Production server for testing

## Test Reports

Test results are stored in:

- `./security-reports/` - Security scan results
- `./accessibility-report.json` - Accessibility test results
- `./test-reports/` - General test outputs

## Development Workflow

### 1. Start Development

```bash
# Build and start development environment
make docker-build
make docker-dev

# Or in one command
docker-compose up --build dev
```

### 2. Make Changes

- Edit files in your local directory
- Changes are reflected immediately via volume mounting
- Browser auto-refreshes with live-server

### 3. Test Changes

```bash
# Run specific tests
make docker-test-unit
make docker-test-integration

# Or run all tests
make docker-test
```

### 4. Production Testing

```bash
# Test production build
make docker-prod

# Run load tests against production
make docker-test-load
```

### 5. Security Testing

```bash
# Run security scans
make docker-test-security

# Check CSP implementation
make csp-validate
```

## Production Deployment

The production Docker image can be deployed to any container platform:

### Build Production Image

```bash
docker build --target production -t freshthreads:latest .
```

### Run Production Container

```bash
docker run -d -p 80:80 --name freshthreads-prod freshthreads:latest
```

### Health Check

```bash
curl http://localhost/health
```

## Troubleshooting

### Common Issues

1. **Docker not running**

   ```bash
   # Check Docker status
   docker info

   # Start Docker Desktop
   open -a Docker
   ```

2. **Port conflicts**

   ```bash
   # Check what's using the port
   lsof -i :5500
   lsof -i :8080

   # Stop conflicting services
   make dev  # Stop local dev server
   ```

3. **Permission issues**

   ```bash
   # Reset Docker permissions
   make docker-cleanup
   docker system prune -a
   ```

4. **Build failures**

   ```bash
   # Clean build
   docker-compose build --no-cache

   # Check logs
   docker-compose logs dev
   ```

### Debug Commands

```bash
# Access running container
docker-compose exec dev sh

# View container logs
docker-compose logs -f dev

# Check container status
docker-compose ps

# Inspect container
docker inspect freshthreads_dev_1
```

## Performance Optimization

### Build Time Optimization

- `.dockerignore` excludes unnecessary files
- Multi-stage builds reduce image size
- Layer caching optimizes rebuild times

### Runtime Optimization

- Nginx compression enabled
- Static file caching headers
- Health checks for monitoring
- Non-root user for security

## Monitoring

### Health Checks

- Development: `curl http://localhost:5500`
- Production: `curl http://localhost:8080/health`

### Logs

```bash
# View all logs
docker-compose logs

# Follow specific service
docker-compose logs -f prod

# View last N lines
docker-compose logs --tail=50 dev
```

### Resource Usage

```bash
# Container stats
docker stats

# System usage
docker system df

# Clean up unused resources
docker system prune
```

## CI/CD Integration

The Docker setup is designed for CI/CD pipelines:

```yaml
# Example GitHub Actions integration
- name: Run Docker Tests
  run: |
    make docker-build
    make docker-test

- name: Build Production Image
  run: |
    docker build --target production -t freshthreads:${{ github.sha }} .
```

## Best Practices

1. **Always run tests before deployment**

   ```bash
   make docker-test
   ```

2. **Use production image for final testing**

   ```bash
   make docker-prod
   make docker-test-load
   ```

3. **Monitor resource usage**

   ```bash
   make docker-status
   ```

4. **Clean up regularly**

   ```bash
   make docker-cleanup
   ```

5. **Keep images updated**
   ```bash
   docker-compose build --no-cache
   ```

## Support

For Docker-related issues:

1. Check the troubleshooting section above
2. Review container logs: `docker-compose logs`
3. Verify Docker Desktop is running
4. Check available system resources

For project-specific issues:

1. Run local tests first: `make test`
2. Compare with Docker test results
3. Check file permissions and volumes
