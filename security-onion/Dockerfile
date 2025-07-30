# Custom Security Onion Docker image for FreshThreads
FROM securityonion/so-elasticsearch:2.3.0

# Add custom configurations
COPY security-onion/config/ /opt/so/conf/
COPY security-onion/suricata/ /opt/so/conf/suricata/
COPY security-onion/zeek/ /opt/so/conf/zeek/

# Set proper permissions
RUN chown -R elasticsearch:elasticsearch /opt/so/conf/

# Add FreshThreads specific monitoring
COPY security-onion/scripts/ /opt/so/scripts/
RUN chmod +x /opt/so/scripts/*.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:9200/_cluster/health || exit 1

EXPOSE 9200 9300
