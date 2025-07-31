# Security Onion Manager Dockerfile
# Custom orchestration container for Security Onion management

FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install required packages
RUN apt-get update && apt-get install -y \
  curl \
  wget \
  jq \
  tar \
  gzip \
  cron \
  supervisor \
  python3 \
  python3-pip \
  docker.io \
  docker-compose \
  && rm -rf /var/lib/apt/lists/*

# Install Python packages for monitoring
RUN pip3 install \
  requests \
  elasticsearch \
  pyyaml \
  schedule

# Create application directory
WORKDIR /app

# Copy management scripts
COPY so-manager.sh /usr/local/bin/so-manager
COPY monitor.py /app/monitor.py
COPY health-check.py /app/health-check.py

# Make scripts executable
RUN chmod +x /usr/local/bin/so-manager

# Create log directory
RUN mkdir -p /var/log/security-onion-manager

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create cron job for regular maintenance
RUN echo "0 2 * * * /usr/local/bin/so-manager cleanup" > /etc/cron.d/security-onion-cleanup
RUN echo "0 3 * * 0 /usr/local/bin/so-manager backup" > /etc/cron.d/security-onion-backup
RUN chmod 0644 /etc/cron.d/security-onion-*

# Expose management port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python3 /app/health-check.py

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
