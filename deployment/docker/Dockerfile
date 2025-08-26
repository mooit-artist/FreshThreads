# FreshThreads Docker Setup
# Multi-stage build for development and production

# Development stage
FROM node:24-alpine AS development

LABEL maintainer="FreshThreads LLC"
LABEL description="Development environment for FreshThreads static website"

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
  adduser -S freshthreads -u 1001

# Install system dependencies
RUN apk add --no-cache \
  bash \
  curl \
  git \
  make \
  py3-pip \
  python3

# Copy package files
COPY package*.json ./

# Install Node.js dependencies
RUN npm ci --only=development

# Copy application code
COPY . .

# Set ownership
RUN chown -R freshthreads:nodejs /app

# Switch to non-root user
USER freshthreads

# Expose development port
EXPOSE 5500

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5500 || exit 1

# Default command for development
CMD ["npm", "run", "dev"]

# Testing stage
FROM development AS testing

USER root

# Install testing dependencies
RUN npm install -g \
  html-validate \
  prettier \
  eslint \
  stylelint \
  markdownlint-cli \
  snyk

# Install Python testing tools
RUN pip3 install --no-cache-dir --break-system-packages \
  flake8 \
  black \
  yamllint \
  beautifulsoup4 \
  requests

# Copy test scripts
COPY scripts/ ./scripts/
RUN chmod +x scripts/*.sh

# Switch back to non-root user
USER freshthreads

# Run tests by default in testing stage
CMD ["make", "lint"]

# Production stage
FROM nginx:alpine AS production

LABEL maintainer="FreshThreads LLC"
LABEL description="Production environment for FreshThreads static website with OpenAppSec protection"

# Install security tools and create user
RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  openssl \
  wget && \
  adduser -S freshthreads -u 1001 -G nginx && \
  mkdir -p /etc/cp && \
  mkdir -p /var/log/nano_agent

# Copy static files and nginx configuration
COPY docs/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/start-nginx.sh /usr/local/bin/start-nginx.sh

# Set proper permissions and create directories
RUN chown -R freshthreads:nginx /usr/share/nginx/html && \
  chown -R freshthreads:nginx /var/cache/nginx && \
  chown -R freshthreads:nginx /var/log/nginx && \
  chown -R freshthreads:nginx /etc/nginx/conf.d && \
  chmod +x /usr/local/bin/start-nginx.sh && \
  mkdir -p /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp && \
  chown -R freshthreads:nginx /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp

# Switch to non-root user
USER freshthreads

# Expose port 80
EXPOSE 80

# Health check for production
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["/usr/local/bin/start-nginx.sh"]
