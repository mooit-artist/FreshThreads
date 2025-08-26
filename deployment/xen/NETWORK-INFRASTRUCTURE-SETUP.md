# 🌐 XEN Network Infrastructure Setup for FreshThreads

## 📋 **Network Architecture Overview**

### **Network Topology:**

```
Internet/External Network
         │
    ┌────▼────┐
    │ XEN Host │ (Physical Server)
    └────┬────┘
         │
    ┌────▼────┐
    │ xenbr0  │ (Public Bridge - External Access)
    └────┬────┘
         │
    ┌────▼────────────────────────────────┐
    │         Public Subnet               │
    │     192.168.1.0/24                 │
    │  ┌──────────────────────────────┐   │
    │  │  FreshThreads-DMZ VM         │   │
    │  │  IP: 192.168.1.100          │   │
    │  │  Nginx Reverse Proxy        │   │
    │  │  SSL Termination            │   │
    │  └──────────────────────────────┘   │
    └────────────┬────────────────────────┘
                 │
    ┌────────────▼────────────────────────┐
    │         Private Subnet              │
    │     10.0.1.0/24                    │
    │  ┌────────────────┐  ┌─────────────┐│
    │  │ Frontend VM    │  │ Backend VM  ││
    │  │ 10.0.1.10     │  │ 10.0.1.20   ││
    │  │ Static Files   │  │ Flask APIs  ││
    │  └────────────────┘  └─────────────┘│
    │  ┌─────────────────────────────────┐ │
    │  │        Database VM              │ │
    │  │        10.0.1.30               │ │
    │  │        PostgreSQL              │ │
    │  └─────────────────────────────────┘ │
    └──────────────────────────────────────┘
```

## 🔧 **XEN Network Configuration**

### **1. Create Network Bridges**

#### **Public Bridge (External Access):**

```bash
# On XEN Dom0 (hypervisor)
sudo xl network-list-bridges

# Create public bridge configuration
cat > /etc/xen/scripts/network-bridge-public << 'EOF'
#!/bin/bash
brctl addbr xenbr0
brctl addif xenbr0 eth0
ip link set dev xenbr0 up
EOF

chmod +x /etc/xen/scripts/network-bridge-public
```

#### **Private Bridge (Internal Network):**

```bash
# Create private bridge configuration
cat > /etc/xen/scripts/network-bridge-private << 'EOF'
#!/bin/bash
brctl addbr xenbr1
ip link set dev xenbr1 up
ip addr add 10.0.1.1/24 dev xenbr1
EOF

chmod +x /etc/xen/scripts/network-bridge-private
```

### **2. Configure XEN Network Settings**

#### **Update XEN Configuration:**

```bash
# Edit /etc/xen/xl.conf
cat >> /etc/xen/xl.conf << 'EOF'
# Network configuration
vif.default.bridge = "xenbr0"
vif.default.backend = "0"

# Enable network bridges
network.bridge.enable = 1
EOF
```

#### **Network Bridge Startup:**

```bash
# Add to /etc/rc.local or systemd service
cat > /etc/systemd/system/xen-bridges.service << 'EOF'
[Unit]
Description=XEN Network Bridges
After=network.target

[Service]
Type=oneshot
ExecStart=/etc/xen/scripts/network-bridge-public
ExecStart=/etc/xen/scripts/network-bridge-private
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable xen-bridges.service
systemctl start xen-bridges.service
```

## 🖥️ **VM Network Configurations**

### **1. DMZ VM (Public-Facing Reverse Proxy)**

#### **VM Configuration (dmz.cfg):**

```python
# FreshThreads DMZ VM Configuration
name = "freshthreads-dmz"
memory = 2048
vcpus = 2
disk = ['/var/lib/xen/images/freshthreads-dmz.img,raw,xvda,rw']

# Network: Public bridge access
vif = ['bridge=xenbr0,mac=00:16:3E:01:01:01']

# Boot configuration
builder = "hvm"
boot = "cd"
vnc = 1
vnclisten = "0.0.0.0"
vncpasswd = "password"

# OS
kernel = "/usr/lib/xen-4.0/boot/hvmloader"
device_model = "/usr/lib/xen/bin/qemu-dm"
```

#### **DMZ VM IP Configuration:**

```bash
# Inside DMZ VM - /etc/netplan/01-network.yaml
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
```

### **2. Frontend VM (Private Network)**

#### **VM Configuration (frontend.cfg):**

```python
# FreshThreads Frontend VM Configuration
name = "freshthreads-frontend"
memory = 1024
vcpus = 1
disk = ['/var/lib/xen/images/freshthreads-frontend.img,raw,xvda,rw']

# Network: Private bridge only
vif = ['bridge=xenbr1,mac=00:16:3E:02:01:01']

# Boot configuration
builder = "hvm"
boot = "cd"
vnc = 1
vnclisten = "0.0.0.0"
```

#### **Frontend VM IP Configuration:**

```bash
# Inside Frontend VM - /etc/netplan/01-network.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 10.0.1.10/24
      gateway4: 10.0.1.1
      nameservers:
        addresses:
          - 10.0.1.1
```

### **3. Backend VM (Private Network)**

#### **VM Configuration (backend.cfg):**

```python
# FreshThreads Backend VM Configuration
name = "freshthreads-backend"
memory = 2048
vcpus = 2
disk = ['/var/lib/xen/images/freshthreads-backend.img,raw,xvda,rw']

# Network: Private bridge only
vif = ['bridge=xenbr1,mac=00:16:3E:02:02:01']

# Boot configuration
builder = "hvm"
boot = "cd"
vnc = 1
vnclisten = "0.0.0.0"
```

#### **Backend VM IP Configuration:**

```bash
# Inside Backend VM - /etc/netplan/01-network.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 10.0.1.20/24
      gateway4: 10.0.1.1
      nameservers:
        addresses:
          - 10.0.1.1
```

### **4. Database VM (Private Network)**

#### **VM Configuration (database.cfg):**

```python
# FreshThreads Database VM Configuration
name = "freshthreads-database"
memory = 2048
vcpus = 2
disk = ['/var/lib/xen/images/freshthreads-database.img,raw,xvda,rw']

# Network: Private bridge only
vif = ['bridge=xenbr1,mac=00:16:3E:02:03:01']

# Boot configuration
builder = "hvm"
boot = "cd"
vnc = 1
vnclisten = "0.0.0.0"
```

#### **Database VM IP Configuration:**

```bash
# Inside Database VM - /etc/netplan/01-network.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 10.0.1.30/24
      gateway4: 10.0.1.1
      nameservers:
        addresses:
          - 10.0.1.1
```

## 🔒 **Security Configuration**

### **1. DMZ VM Firewall (iptables):**

```bash
# DMZ VM Firewall Rules
#!/bin/bash

# Clear existing rules
iptables -F
iptables -t nat -F

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (from specific IPs only)
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# NAT rules for private network access
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE

# Forward rules for internal services
iptables -A FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

### **2. Private Network Firewall:**

```bash
# Backend VM Firewall
#!/bin/bash

# Only allow connections from DMZ and other private VMs
iptables -A INPUT -s 10.0.1.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.1.100 -j ACCEPT
iptables -A INPUT -j DROP
```

## 📊 **Network Monitoring & Testing**

### **1. Connectivity Tests:**

```bash
# Test script for network connectivity
#!/bin/bash

echo "🌐 Testing XEN Network Infrastructure..."

# Test public connectivity
ping -c 3 8.8.8.8

# Test DMZ VM
ping -c 3 192.168.1.100

# Test private network
ping -c 3 10.0.1.10  # Frontend
ping -c 3 10.0.1.20  # Backend
ping -c 3 10.0.1.30  # Database

# Test DNS resolution
nslookup freshthreads.local
nslookup api.freshthreads.local

echo "✅ Network tests complete"
```

### **2. Network Monitoring:**

```bash
# Network monitoring script
#!/bin/bash

echo "📊 XEN Network Status"
echo "===================="

# Bridge status
echo "Network Bridges:"
brctl show

# VM network status
echo -e "\nVM Network Interfaces:"
xl network-list

# Routing table
echo -e "\nRouting Table:"
route -n

# Active connections
echo -e "\nActive Connections:"
netstat -tupln
```

## 🚀 **Deployment Scripts**

### **1. Create VMs Script:**

```bash
#!/bin/bash

echo "🏗️ Creating FreshThreads XEN VMs..."

# Create disk images
xl create-image /var/lib/xen/images/freshthreads-dmz.img 20G
xl create-image /var/lib/xen/images/freshthreads-frontend.img 10G
xl create-image /var/lib/xen/images/freshthreads-backend.img 15G
xl create-image /var/lib/xen/images/freshthreads-database.img 20G

# Create VMs
xl create dmz.cfg
xl create frontend.cfg
xl create backend.cfg
xl create database.cfg

echo "✅ VMs created successfully"
```

### **2. Network Bootstrap Script:**

```bash
#!/bin/bash

echo "🌐 Bootstrapping XEN Network Infrastructure..."

# Setup bridges
/etc/xen/scripts/network-bridge-public
/etc/xen/scripts/network-bridge-private

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Setup DNS
echo "10.0.1.1 freshthreads.local" >> /etc/hosts
echo "10.0.1.1 api.freshthreads.local" >> /etc/hosts

echo "✅ Network infrastructure ready"
```

## 📋 **Next Steps After Network Setup**

1. **Create VMs** with the configurations above
2. **Install Ubuntu 22.04** in each VM
3. **Configure networking** as specified
4. **Deploy applications** using the Docker configs we created earlier
5. **Test connectivity** between all components

This infrastructure gives you **true enterprise-grade separation** with proper DMZ architecture and private backend networks, just like real production environments!
