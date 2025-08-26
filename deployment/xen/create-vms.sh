#!/bin/bash

# 🏗️ XEN VM Creation Script for FreshThreads
# Creates all VMs with proper network configuration

set -e

echo "🏗️ Creating FreshThreads VMs in XEN..."

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

# Variables
VM_DIR="/var/lib/xen/images/freshthreads"
CONFIG_DIR="/etc/xen/freshthreads"
UBUNTU_ISO="/var/lib/xen/iso/ubuntu-22.04-server-amd64.iso"

# Create directories
mkdir -p "$VM_DIR"
mkdir -p "$CONFIG_DIR"

# 1. Create DMZ VM (Public-facing reverse proxy)
log_info "Creating DMZ VM configuration..."
cat > "$CONFIG_DIR/dmz.cfg" << 'EOF'
# FreshThreads DMZ VM - Public facing reverse proxy
name = "freshthreads-dmz"
type = "hvm"
memory = 2048
vcpus = 2
disk = ['/var/lib/xen/images/freshthreads/dmz.img,raw,xvda,rw',
        '/var/lib/xen/iso/ubuntu-22.04-server-amd64.iso,raw,xvdb:cdrom,r']

# Network: Public bridge for external access
vif = ['bridge=xenbr0,mac=00:16:3E:01:01:01']

# Boot from CD first, then disk
boot = "dc"
vnc = 1
vnclisten = "0.0.0.0"
vncpasswd = "freshthreads"

# Hardware
acpi = 1
apic = 1
viridian = 1
EOF

# 2. Create Frontend VM (Private network)
log_info "Creating Frontend VM configuration..."
cat > "$CONFIG_DIR/frontend.cfg" << 'EOF'
# FreshThreads Frontend VM - Static files and Nginx
name = "freshthreads-frontend"
type = "hvm"
memory = 1024
vcpus = 1
disk = ['/var/lib/xen/images/freshthreads/frontend.img,raw,xvda,rw',
        '/var/lib/xen/iso/ubuntu-22.04-server-amd64.iso,raw,xvdb:cdrom,r']

# Network: Private bridge only
vif = ['bridge=xenbr1,mac=00:16:3E:02:01:01']

# Boot configuration
boot = "dc"
vnc = 1
vnclisten = "0.0.0.0"
vncpasswd = "freshthreads"

# Hardware
acpi = 1
apic = 1
viridian = 1
EOF

# 3. Create Backend VM (Private network)
log_info "Creating Backend VM configuration..."
cat > "$CONFIG_DIR/backend.cfg" << 'EOF'
# FreshThreads Backend VM - Flask APIs
name = "freshthreads-backend"
type = "hvm"
memory = 2048
vcpus = 2
disk = ['/var/lib/xen/images/freshthreads/backend.img,raw,xvda,rw',
        '/var/lib/xen/iso/ubuntu-22.04-server-amd64.iso,raw,xvdb:cdrom,r']

# Network: Private bridge only
vif = ['bridge=xenbr1,mac=00:16:3E:02:02:01']

# Boot configuration
boot = "dc"
vnc = 1
vnclisten = "0.0.0.0"
vncpasswd = "freshthreads"

# Hardware
acpi = 1
apic = 1
viridian = 1
EOF

# 4. Create Database VM (Private network)
log_info "Creating Database VM configuration..."
cat > "$CONFIG_DIR/database.cfg" << 'EOF'
# FreshThreads Database VM - PostgreSQL
name = "freshthreads-database"
type = "hvm"
memory = 2048
vcpus = 2
disk = ['/var/lib/xen/images/freshthreads/database.img,raw,xvda,rw',
        '/var/lib/xen/iso/ubuntu-22.04-server-amd64.iso,raw,xvdb:cdrom,r']

# Network: Private bridge only
vif = ['bridge=xenbr1,mac=00:16:3E:02:03:01']

# Boot configuration
boot = "dc"
vnc = 1
vnclisten = "0.0.0.0"
vncpasswd = "freshthreads"

# Hardware
acpi = 1
apic = 1
viridian = 1
EOF

# 5. Create disk images
log_info "Creating VM disk images..."

# Check if Ubuntu ISO exists
if [ ! -f "$UBUNTU_ISO" ]; then
    log_warning "Ubuntu ISO not found at $UBUNTU_ISO"
    log_info "Download Ubuntu 22.04 Server ISO and place it at the specified location"

    mkdir -p /var/lib/xen/iso
    log_info "You can download it with:"
    echo "cd /var/lib/xen/iso"
    echo "wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
    echo "mv ubuntu-22.04.3-live-server-amd64.iso ubuntu-22.04-server-amd64.iso"
fi

# Create disk images
log_info "Creating DMZ VM disk (20GB)..."
if [ ! -f "$VM_DIR/dmz.img" ]; then
    dd if=/dev/zero of="$VM_DIR/dmz.img" bs=1G count=20
    log_success "DMZ disk created"
else
    log_warning "DMZ disk already exists"
fi

log_info "Creating Frontend VM disk (10GB)..."
if [ ! -f "$VM_DIR/frontend.img" ]; then
    dd if=/dev/zero of="$VM_DIR/frontend.img" bs=1G count=10
    log_success "Frontend disk created"
else
    log_warning "Frontend disk already exists"
fi

log_info "Creating Backend VM disk (15GB)..."
if [ ! -f "$VM_DIR/backend.img" ]; then
    dd if=/dev/zero of="$VM_DIR/backend.img" bs=1G count=15
    log_success "Backend disk created"
else
    log_warning "Backend disk already exists"
fi

log_info "Creating Database VM disk (25GB)..."
if [ ! -f "$VM_DIR/database.img" ]; then
    dd if=/dev/zero of="$VM_DIR/database.img" bs=1G count=25
    log_success "Database disk created"
else
    log_warning "Database disk already exists"
fi

# 6. Create VM management scripts
log_info "Creating VM management scripts..."

cat > /usr/local/bin/freshthreads-vm << 'EOF'
#!/bin/bash

# FreshThreads VM Management Script

case "$1" in
    start)
        echo "🚀 Starting FreshThreads VMs..."
        xl create /etc/xen/freshthreads/dmz.cfg
        xl create /etc/xen/freshthreads/frontend.cfg
        xl create /etc/xen/freshthreads/backend.cfg
        xl create /etc/xen/freshthreads/database.cfg
        echo "✅ All VMs started"
        ;;
    stop)
        echo "🛑 Stopping FreshThreads VMs..."
        xl destroy freshthreads-dmz 2>/dev/null || true
        xl destroy freshthreads-frontend 2>/dev/null || true
        xl destroy freshthreads-backend 2>/dev/null || true
        xl destroy freshthreads-database 2>/dev/null || true
        echo "✅ All VMs stopped"
        ;;
    status)
        echo "📊 FreshThreads VM Status:"
        xl list | grep freshthreads || echo "No FreshThreads VMs running"
        ;;
    console)
        if [ -z "$2" ]; then
            echo "Usage: freshthreads-vm console [dmz|frontend|backend|database]"
            exit 1
        fi
        xl console "freshthreads-$2"
        ;;
    vnc)
        echo "📺 VNC Access Information:"
        echo "DMZ VM:      vnc://$(hostname):5900 (password: freshthreads)"
        echo "Frontend VM: vnc://$(hostname):5901 (password: freshthreads)"
        echo "Backend VM:  vnc://$(hostname):5902 (password: freshthreads)"
        echo "Database VM: vnc://$(hostname):5903 (password: freshthreads)"
        ;;
    *)
        echo "FreshThreads VM Management"
        echo "========================="
        echo "Usage: $0 {start|stop|status|console|vnc}"
        echo ""
        echo "Commands:"
        echo "  start   - Start all VMs"
        echo "  stop    - Stop all VMs"
        echo "  status  - Show VM status"
        echo "  console - Connect to VM console"
        echo "  vnc     - Show VNC connection info"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/freshthreads-vm

# 7. Create network configuration templates
log_info "Creating network configuration templates..."

mkdir -p /usr/local/share/freshthreads

# DMZ network config
cat > /usr/local/share/freshthreads/dmz-netplan.yaml << 'EOF'
# DMZ VM Network Configuration (Public)
# Copy to /etc/netplan/01-network.yaml in DMZ VM
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF

# Private network configs
cat > /usr/local/share/freshthreads/private-netplan.yaml << 'EOF'
# Private VM Network Configuration Template
# Adjust IP address for each VM:
# Frontend: 10.0.1.10
# Backend:  10.0.1.20
# Database: 10.0.1.30

network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 10.0.1.XX/24  # Replace XX with VM-specific IP
      gateway4: 10.0.1.1
      nameservers:
        addresses:
          - 10.0.1.1
          - 8.8.8.8
EOF

echo ""
log_success "🎉 XEN VM Creation Complete!"
echo ""
echo "📋 Created VMs:"
echo "DMZ VM:      freshthreads-dmz (Public: 192.168.1.100)"
echo "Frontend VM: freshthreads-frontend (Private: 10.0.1.10)"
echo "Backend VM:  freshthreads-backend (Private: 10.0.1.20)"
echo "Database VM: freshthreads-database (Private: 10.0.1.30)"
echo ""
echo "🔧 Management Commands:"
echo "Start VMs:   freshthreads-vm start"
echo "Stop VMs:    freshthreads-vm stop"
echo "VM Status:   freshthreads-vm status"
echo "VNC Info:    freshthreads-vm vnc"
echo ""
echo "📱 Network Templates:"
echo "DMZ Config:     /usr/local/share/freshthreads/dmz-netplan.yaml"
echo "Private Config: /usr/local/share/freshthreads/private-netplan.yaml"
echo ""

if [ ! -f "$UBUNTU_ISO" ]; then
    log_warning "⚠️  Don't forget to download Ubuntu 22.04 ISO before starting VMs!"
    echo "Download: https://releases.ubuntu.com/22.04/"
    echo "Place at: $UBUNTU_ISO"
else
    log_info "🚀 Ready to start VMs: freshthreads-vm start"
fi
