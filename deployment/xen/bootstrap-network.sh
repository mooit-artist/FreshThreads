#!/bin/bash

# 🌐 XEN Network Infrastructure Bootstrap Script
# Run this on XEN Dom0 (hypervisor) to set up network infrastructure

set -e

echo "🚀 Setting up XEN Network Infrastructure for FreshThreads..."

# Colors
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

# Check if XEN is installed
if ! command -v xl &> /dev/null; then
    log_error "XEN not found. Please install XEN hypervisor first."
    exit 1
fi

log_info "Setting up XEN bridges..."

# 1. Create Public Bridge Script
log_info "Creating public bridge configuration..."
cat > /etc/xen/scripts/network-bridge-public << 'EOF'
#!/bin/bash
# Public bridge for external access

# Check if bridge exists
if ! brctl show | grep -q xenbr0; then
    # Create public bridge
    brctl addbr xenbr0

    # Add physical interface (adjust eth0 to your interface)
    PHYSICAL_IF=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$PHYSICAL_IF" ]; then
        brctl addif xenbr0 $PHYSICAL_IF
        echo "Added $PHYSICAL_IF to xenbr0"
    fi

    # Bring bridge up
    ip link set dev xenbr0 up

    echo "Public bridge xenbr0 created"
else
    echo "Public bridge xenbr0 already exists"
fi
EOF

chmod +x /etc/xen/scripts/network-bridge-public

# 2. Create Private Bridge Script
log_info "Creating private bridge configuration..."
cat > /etc/xen/scripts/network-bridge-private << 'EOF'
#!/bin/bash
# Private bridge for internal network

# Check if bridge exists
if ! brctl show | grep -q xenbr1; then
    # Create private bridge
    brctl addbr xenbr1

    # Bring bridge up
    ip link set dev xenbr1 up

    # Add IP to bridge (acts as gateway)
    ip addr add 10.0.1.1/24 dev xenbr1

    echo "Private bridge xenbr1 created with IP 10.0.1.1/24"
else
    echo "Private bridge xenbr1 already exists"
fi
EOF

chmod +x /etc/xen/scripts/network-bridge-private

# 3. Execute bridge creation
log_info "Creating network bridges..."
/etc/xen/scripts/network-bridge-public
/etc/xen/scripts/network-bridge-private

# 4. Enable IP forwarding
log_info "Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

# 5. Setup NAT for private network
log_info "Configuring NAT for private network..."
DEFAULT_IF=$(ip route | grep default | awk '{print $5}' | head -1)
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o "$DEFAULT_IF" -j MASQUERADE
iptables -A FORWARD -i xenbr1 -o "$DEFAULT_IF" -j ACCEPT
iptables -A FORWARD -i "$DEFAULT_IF" -o xenbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Save iptables rules
if command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4
fi

# 6. Create systemd service for bridge startup
log_info "Creating systemd service for bridges..."
cat > /etc/systemd/system/xen-bridges.service << 'EOF'
[Unit]
Description=XEN Network Bridges for FreshThreads
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/etc/xen/scripts/network-bridge-public
ExecStart=/etc/xen/scripts/network-bridge-private
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xen-bridges.service

# 7. Create DNS entries for internal resolution
log_info "Setting up internal DNS..."
if ! grep -q "freshthreads.local" /etc/hosts; then
    echo "10.0.1.1 freshthreads.local" >> /etc/hosts
    echo "10.0.1.1 api.freshthreads.local" >> /etc/hosts
    echo "192.168.1.100 dmz.freshthreads.local" >> /etc/hosts
fi

# 8. Create VM configuration directory
log_info "Creating VM configuration directory..."
mkdir -p /etc/xen/freshthreads
mkdir -p /var/lib/xen/images/freshthreads

# 9. Network verification script
log_info "Creating network verification script..."
cat > /usr/local/bin/freshthreads-net-check << 'EOF'
#!/bin/bash

echo "🌐 FreshThreads Network Status"
echo "=============================="

echo -e "\n📊 Bridge Status:"
brctl show

echo -e "\n🔗 Network Interfaces:"
ip addr show xenbr0 2>/dev/null || echo "xenbr0: Not found"
ip addr show xenbr1 2>/dev/null || echo "xenbr1: Not found"

echo -e "\n🚦 IP Forwarding:"
cat /proc/sys/net/ipv4/ip_forward

echo -e "\n📍 Routing Table:"
route -n | grep -E "(10.0.1|192.168.1)"

echo -e "\n🔧 XEN VMs:"
xl list 2>/dev/null || echo "No VMs running"

echo -e "\n✅ Network check complete"
EOF

chmod +x /usr/local/bin/freshthreads-net-check

# 10. Display network information
echo ""
log_success "🎉 XEN Network Infrastructure Setup Complete!"
echo ""
echo "📋 Network Configuration:"
echo "Public Bridge:  xenbr0 (external access)"
echo "Private Bridge: xenbr1 (10.0.1.1/24)"
echo ""
echo "📊 Planned IP Allocation:"
echo "DMZ VM:      192.168.1.100 (public)"
echo "Frontend:    10.0.1.10 (private)"
echo "Backend:     10.0.1.20 (private)"
echo "Database:    10.0.1.30 (private)"
echo ""
echo "🔧 Management Commands:"
echo "Check status:  freshthreads-net-check"
echo "List VMs:      xl list"
echo "Network info:  brctl show"
echo ""
log_warning "Next: Create VMs using the configuration files in deployment/xen/"

# 11. Check current status
log_info "Running network verification..."
/usr/local/bin/freshthreads-net-check
