# 🛡️ Aikido Runtime Security Configuration

## Overview

Aikido provides real-time runtime application security protection for the FreshThreads LLC platform. This document covers the complete setup, configuration, and usage of Aikido's security firewall.

## Current Status ✅

- **Package**: @aikidosec/firewall v1.7.9 installed
- **Configuration**: Complete with aikido.json
- **Integration**: Ready for development and production
- **Demo Server**: Available for testing security features

## Installation & Setup

### 1. Package Installation

```bash
npm install @aikidosec/firewall
```

### 2. Environment Configuration

Add to your `.env` file:

```bash
# Aikido Runtime Security
AIKIDO_TOKEN=your_aikido_api_token      # Optional: for cloud reporting
AIKIDO_BLOCK=true                       # Enable blocking mode
AIKIDO_DEBUG=false                      # Set to true for detailed logs
AIKIDO_CONFIG_PATH=./aikido.json        # Path to configuration file
```

### 3. Configuration File

The `aikido.json` file contains comprehensive security settings:

```json
{
  "version": "1.0.0",
  "firewall": {
    "enabled": true,
    "mode": "blocking",
    "log_level": "info"
  },
  "protection": {
    "sql_injection": { "enabled": true, "mode": "blocking" },
    "xss": { "enabled": true, "mode": "blocking" },
    "path_traversal": { "enabled": true, "mode": "blocking" },
    "command_injection": { "enabled": true, "mode": "blocking" },
    "ssrf": { "enabled": true, "mode": "blocking" },
    "nosql_injection": { "enabled": true, "mode": "blocking" },
    "prototype_pollution": { "enabled": true, "mode": "blocking" }
  }
}
```

## Security Features

### Real-Time Protection

- **SQL Injection**: Detects and blocks SQL injection attempts
- **Cross-Site Scripting (XSS)**: Prevents XSS attacks
- **Path Traversal**: Blocks directory traversal attempts
- **Command Injection**: Prevents OS command injection
- **SSRF**: Server-Side Request Forgery protection
- **NoSQL Injection**: MongoDB and other NoSQL injection protection
- **Prototype Pollution**: JavaScript prototype pollution prevention

### Rate Limiting

- **Max Requests**: 100 requests per minute per IP
- **Window**: 60-second sliding window
- **Configurable**: Adjustable limits per endpoint

### Allowlist & Blocklist

- **Trusted IPs**: Localhost and development IPs allowed
- **Blocked User Agents**: Security scanners automatically blocked
- **Static Assets**: CSS, JS, images excluded from scanning

## Integration Methods

### 1. Automatic Integration (Recommended)

```javascript
// Import at the very top of your main application file
require('@aikidosec/firewall');

// Your application code follows
const express = require('express');
const app = express();
```

### 2. Express.js Integration

```javascript
const aikido = require('@aikidosec/firewall');
const express = require('express');

const app = express();

// Aikido automatically instruments Express
app.get('/', (req, res) => {
  res.json({ message: 'Protected by Aikido' });
});
```

### 3. HTTP Server Integration

```javascript
require('@aikidosec/firewall');
const http = require('http');

const server = http.createServer((req, res) => {
  // Aikido automatically protects HTTP requests
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'protected' }));
});
```

## Available Commands

### Development Commands

```bash
# Check Aikido status and configuration
make aikido-status

# Start interactive security demo
make aikido-demo

# Run automated security tests
make aikido-test
```

### Command Details

#### `make aikido-status`

Checks the complete Aikido setup:

- Configuration file presence
- Package installation
- Environment variables
- Import functionality

#### `make aikido-demo`

Starts an interactive demo server with:

- Multiple test endpoints
- Example attack scenarios
- Real-time protection demonstration
- Educational security testing

#### `make aikido-test`

Automated security testing:

- XSS attack simulation
- SQL injection attempts
- Path traversal tests
- Automatic server management

## Security Testing

### Manual Testing Endpoints

When running the demo server (`make aikido-demo`):

```bash
# Basic functionality test
curl http://localhost:3000/

# Health check
curl http://localhost:3000/health

# XSS protection test
curl "http://localhost:3000/security-test?input=<script>alert('xss')</script>"

# SQL injection test
curl "http://localhost:3000/security-test?input='; DROP TABLE users; --"

# Path traversal test
curl "http://localhost:3000/security-test?file=../../../etc/passwd"

# POST endpoint test
curl -X POST http://localhost:3000/vulnerable-endpoint \
  -H "Content-Type: application/json" \
  -d '{"test": "normal data"}'
```

### Expected Behavior

- **Legitimate requests**: Pass through normally
- **Malicious payloads**: Detected and logged (blocked in production)
- **Security scanning**: Automatically blocked based on user agent
- **Rate limiting**: Enforced per configuration

## Production Deployment

### Environment Variables

```bash
# Production configuration
AIKIDO_TOKEN=your_production_token
AIKIDO_BLOCK=true
AIKIDO_DEBUG=false
AIKIDO_CONFIG_PATH=/app/aikido.json
```

### Docker Integration

```dockerfile
# Dockerfile example
FROM node:18-alpine

# Copy Aikido configuration
COPY aikido.json /app/aikido.json

# Set environment variables
ENV AIKIDO_BLOCK=true
ENV AIKIDO_CONFIG_PATH=/app/aikido.json

# Install dependencies
COPY package*.json ./
RUN npm ci --production

# Copy application
COPY . .

# Start with Aikido protection
CMD ["node", "app.js"]
```

### Performance Considerations

- **Minimal Overhead**: < 1ms per request
- **Memory Usage**: ~10MB additional memory
- **CPU Impact**: < 2% increase
- **Network**: No external calls (unless reporting enabled)

## Monitoring & Logging

### Local Monitoring

```bash
# Enable debug logging
AIKIDO_DEBUG=true node app.js

# Monitor protection events
tail -f /var/log/aikido.log
```

### Cloud Reporting (Optional)

With `AIKIDO_TOKEN` configured:

- Real-time attack notifications
- Security dashboard access
- Historical attack analysis
- Team collaboration features

### Integration with Other Tools

- **Snyk**: Complementary vulnerability scanning
- **SonarQube**: Static code analysis
- **Security Onion**: Network monitoring
- **GitHub Actions**: Automated security testing

## Troubleshooting

### Common Issues

#### 1. Import Errors

```bash
# Test import functionality
node -e "require('@aikidosec/firewall'); console.log('Success');"
```

#### 2. Configuration Not Loading

```bash
# Verify configuration file
cat aikido.json | jq .

# Check environment variables
env | grep AIKIDO
```

#### 3. Protection Not Active

```bash
# Verify blocking mode
AIKIDO_BLOCK=true AIKIDO_DEBUG=true node app.js
```

### Debug Commands

```bash
# Full status check
make aikido-status

# Test with debug enabled
AIKIDO_DEBUG=true make aikido-demo

# Validate configuration
node -e "console.log(require('./aikido.json'))"
```

## Best Practices

### 1. Development Workflow

- Always test with Aikido enabled locally
- Use debug mode during development
- Regular security testing with demo server

### 2. Production Deployment

- Enable blocking mode (`AIKIDO_BLOCK=true`)
- Configure proper logging
- Monitor attack patterns
- Regular configuration updates

### 3. Security Testing

- Include Aikido tests in CI/CD pipeline
- Regular penetration testing
- Team security training with demo server

### 4. Configuration Management

- Version control aikido.json
- Environment-specific settings
- Regular security policy reviews

## Integration with FreshThreads Security Stack

### Layered Security Approach

1. **Static Analysis**: SonarQube code scanning
2. **Dependency Scanning**: Snyk vulnerability detection
3. **Runtime Protection**: Aikido real-time firewall
4. **Network Monitoring**: Security Onion traffic analysis
5. **Secrets Management**: Bitwarden CLI integration

### Complementary Tools

- **Pre-commit**: Static security checks
- **CI/CD Pipeline**: Automated security validation
- **Monitoring**: Real-time threat detection
- **Incident Response**: Automated alerting and reporting

## Future Enhancements

### Planned Features

- **AI-Powered Detection**: Machine learning threat detection
- **Custom Rules**: Business-specific security policies
- **Advanced Reporting**: Detailed security analytics
- **Zero-Trust Integration**: Enhanced access controls

### Technology Roadmap

- **Q1 2025**: Enhanced container protection
- **Q2 2025**: Serverless function security
- **Q3 2025**: API gateway integration
- **Q4 2025**: Advanced threat intelligence

---

## Quick Reference

### Essential Commands

```bash
make aikido-status    # Check configuration
make aikido-demo      # Interactive demo
make aikido-test      # Automated testing
```

### Key Files

- `aikido.json` - Main configuration
- `scripts/aikido-demo.js` - Demo server
- `.env.example` - Environment template

### Environment Variables

- `AIKIDO_BLOCK=true` - Enable protection
- `AIKIDO_DEBUG=true` - Debug logging
- `AIKIDO_TOKEN=xxx` - Cloud reporting

**Documentation Version**: 1.0
**Last Updated**: January 2025
**Aikido Version**: v1.7.9
**Next Review**: February 2025
