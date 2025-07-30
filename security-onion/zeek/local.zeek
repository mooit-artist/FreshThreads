# Zeek network analysis configuration for Security Onion
# Comprehensive network monitoring and analysis

##! Local site policy for FreshThreads security monitoring
##! This file defines the local site policy for network monitoring

global LOG_NETWORK_TRAFFIC = T;
global LOG_APPLICATION_DATA = T;
global LOG_SECURITY_EVENTS = T;

# Enable comprehensive logging
redef Log::enable_local_logging = T;
redef Log::enable_remote_logging = T;

# Network interfaces to monitor
redef interfaces = { "any" };

# Site-specific networks
redef Site::local_nets = {
    192.168.0.0/16,
    10.0.0.0/8,
    172.16.0.0/12,
};

# Load additional scripts for enhanced monitoring
@load frameworks/files/hash-all-files
@load frameworks/files/detect-MHR
@load frameworks/software/vulnerable
@load frameworks/software/version-changes
@load policy/protocols/conn/known-hosts
@load policy/protocols/conn/known-services
@load policy/protocols/dns/detect-external-names
@load policy/protocols/ftp/detect
@load policy/protocols/http/detect-sqli
@load policy/protocols/http/detect-webapps
@load policy/protocols/http/header-names
@load policy/protocols/http/var-extraction-cookies
@load policy/protocols/http/var-extraction-uri
@load policy/protocols/smtp/detect-suspicious-orig
@load policy/protocols/ssh/detect-bruteforcing
@load policy/protocols/ssh/geo-data
@load policy/protocols/ssh/interesting-hostnames
@load policy/protocols/ssl/certificate-log
@load policy/protocols/ssl/extract-certs-pem
@load policy/protocols/ssl/heartbleed
@load policy/protocols/ssl/validate-certs

# E-commerce specific monitoring
@load policy/protocols/http/software-browser-plugins
@load policy/protocols/http/software

# Custom FreshThreads monitoring scripts
@load ./scripts/freshthreads-monitoring.zeek
@load ./scripts/ecommerce-security.zeek
@load ./scripts/payment-security.zeek

# File analysis
redef FileExtract::prefix = "/var/log/zeek/extracted/";
redef FileExtract::default_limit = 10485760;  # 10MB

# Notification settings for critical events
redef Notice::emailed_types += {
    HTTP::SQL_Injection_Attacker,
    HTTP::SQL_Injection_Victim,
    Scan::Port_Scan,
    SSH::Login,
    SSL::Certificate_Expired,
    SSL::Certificate_Expires_Soon,
    SSL::Certificate_Not_Valid_Yet,
};

# Intel framework configuration
@load policy/frameworks/intel/seen
@load policy/frameworks/intel/do_notice
redef Intel::read_files += { "/opt/zeek/share/zeek/site/intel/intel.dat" };

# Signature framework
@load frameworks/signatures/detect-sig-changes

# Performance tuning
redef PacketFilter::default_capture_filter = "not (src net 224.0.0.0/4 or dst net 224.0.0.0/4)";

# Custom event handlers for FreshThreads
event http_request(c: connection, method: string, original_URI: string,
                  unescaped_URI: string, version: string)
{
    # Log all HTTP requests to FreshThreads
    if ( c$id$resp_h in Site::local_nets )
    {
        Log::write(HTTP::LOG, [$ts=network_time(),
                               $uid=c$uid,
                               $id=c$id,
                               $method=method,
                               $uri=original_URI,
                               $version=version]);
    }
}

event connection_established(c: connection)
{
    # Monitor new connections to web servers
    if ( c$id$resp_p == 80/tcp || c$id$resp_p == 443/tcp )
    {
        Log::write(Conn::LOG, [$ts=network_time(),
                               $uid=c$uid,
                               $id=c$id,
                               $proto=get_conn_transport_proto(c$id),
                               $service="web"]);
    }
}

# GeoIP configuration
@load policy/protocols/conn/add-geodata
redef Conn::use_geodata = T;
