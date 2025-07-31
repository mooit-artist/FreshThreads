# Security Onion Docker Installation Guide

## Quick Start

The Security Onion Docker deployment has been successfully configured for your FreshThreads e-commerce website. This comprehensive network security monitoring platform includes:

### Components Installed

1. **Elasticsearch** - Log storage and search engine
2. **Kibana** - Visualization and dashboard platform
3. **Logstash** - Log processing and enrichment
4. **Suricata IDS** - Network intrusion detection system
5. **Zeek** - Network analysis framework
6. **Filebeat** - Log shipping agent
7. **Security Proxy** - Nginx reverse proxy
8. **SO Manager** - Custom orchestration container

### Starting Security Onion

```bash
# Navigate to project directory
cd /Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads

# Start all Security Onion services
docker-compose -f docker-compose.security-onion.yml up -d

# Check service status
docker-compose -f docker-compose.security-onion.yml ps

# View logs
docker-compose -f docker-compose.security-onion.yml logs -f
```

### Management Commands

Use the custom Security Onion manager script:

```bash
# Initialize (run once)
sudo ./security-onion/so-manager/so-manager.sh init

# Start services
sudo ./security-onion/so-manager/so-manager.sh start

# Check status
./security-onion/so-manager/so-manager.sh status

# View specific service logs
./security-onion/so-manager/so-manager.sh logs elasticsearch

# Update rules and images
sudo ./security-onion/so-manager/so-manager.sh update

# Create backup
sudo ./security-onion/so-manager/so-manager.sh backup

# Clean up old data
sudo ./security-onion/so-manager/so-manager.sh cleanup
```

### Web Interfaces

Once running, access these interfaces:

- **Kibana Dashboard**: http://localhost:5601
  - Username: `elastic`
  - Password: `changeme` (change in production)

- **Elasticsearch**: http://localhost:9200
  - Direct API access for queries

- **Security Proxy**: http://localhost:8080
  - Unified access point

### Security Features for FreshThreads

#### 1. E-commerce Specific Monitoring

- Price manipulation detection
- Inventory tampering alerts
- Checkout process bypass detection
- Payment security monitoring

#### 2. Web Application Protection

- SQL injection detection
- XSS attack prevention
- Admin access monitoring
- Sensitive file access alerts

#### 3. Payment Security (PCI DSS)

- Credit card data exposure detection
- Insecure payment page alerts
- Payment processor communication monitoring
- SSL/TLS validation

#### 4. Bot and Scraping Detection

- Automated scraping alerts
- Rate limiting violations
- Suspicious user agent detection
- Security scanner identification

### Configuration Files

Key configuration files created:

```
security-onion/
├── elasticsearch.yml          # Elasticsearch configuration
├── kibana.yml                 # Kibana dashboard config
├── logstash/
│   ├── config/logstash.yml   # Logstash main config
│   └── pipeline/             # Processing pipelines
├── suricata/
│   ├── suricata.yaml         # IDS configuration
│   └── rules/                # Detection rules
├── zeek/
│   ├── local.zeek            # Network analysis config
│   └── scripts/              # Custom monitoring scripts
├── filebeat/
│   └── filebeat.yml          # Log shipping config
└── so-manager/
    ├── so-manager.sh         # Management script
    └── Dockerfile            # Custom orchestration
```

### Monitoring Your Website

1. **Real-time Alerts**: Monitor the Kibana dashboard for security events
2. **Log Analysis**: Review detailed logs in `/var/log/security-onion/`
3. **Network Traffic**: Zeek provides comprehensive network analysis
4. **Intrusion Detection**: Suricata IDS monitors for malicious activity

### Production Considerations

Before production deployment:

1. **Change Default Passwords**: Update Elasticsearch credentials
2. **SSL Certificates**: Configure proper SSL/TLS certificates
3. **Firewall Rules**: Restrict access to management interfaces
4. **Resource Allocation**: Ensure sufficient CPU and memory
5. **Backup Strategy**: Implement regular backup procedures

### Troubleshooting

```bash
# Check service health
docker-compose -f docker-compose.security-onion.yml ps

# View all logs
docker-compose -f docker-compose.security-onion.yml logs

# Restart specific service
docker-compose -f docker-compose.security-onion.yml restart elasticsearch

# Check resource usage
docker stats

# Clean up and restart
docker-compose -f docker-compose.security-onion.yml down
docker system prune -f
docker-compose -f docker-compose.security-onion.yml up -d
```

### Integration with Existing Security

Security Onion complements your existing security infrastructure:

- **SonarQube**: Code quality and security analysis
- **OpenAppSec WAF**: Web application firewall
- **Aikido Security**: Runtime application security
- **Security Onion**: Network monitoring and intrusion detection

This creates a comprehensive, multi-layered security approach for your FreshThreads e-commerce platform.

### Next Steps

1. Start the Security Onion services
2. Access Kibana dashboard to configure visualizations
3. Review and customize detection rules
4. Set up alerting and notifications
5. Integrate with your monitoring workflow

For detailed configuration and advanced features, refer to the official Security Onion documentation and the custom scripts provided in the `so-manager` directory.
