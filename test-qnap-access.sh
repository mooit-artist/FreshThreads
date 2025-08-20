#!/bin/bash

# QNAP API Access Test Script for jorgnas71d098.server.lan
# Tests various API endpoints and connectivity

source .env.qnap

echo "🧪 Testing QNAP API Access"
echo "=========================="
echo "Target: $QNAP_HOSTNAME ($QNAP_IP)"
echo ""

# Test basic connectivity
echo "1. Testing Network Connectivity..."
if ping -c 3 "$QNAP_IP" > /dev/null 2>&1; then
    echo "✅ QNAP is reachable"
else
    echo "❌ QNAP is not reachable"
    exit 1
fi

# Test SSH access
echo ""
echo "2. Testing SSH Access..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes admin1@"$QNAP_IP" "echo 'SSH OK'" 2>/dev/null; then
    echo "✅ SSH access working"
else
    echo "⚠️  SSH access requires password or key setup"
    echo "   Run: ssh-copy-id admin1@$QNAP_IP"
fi

# Test Container Station
echo ""
echo "3. Testing Container Station..."
if ssh admin1@"$QNAP_IP" "/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker --version" 2>/dev/null; then
    echo "✅ Docker is available"
else
    echo "❌ Docker/Container Station not available"
fi

# Test web interface
echo ""
echo "4. Testing QNAP Web Interface..."
if curl -s --connect-timeout 5 http://"$QNAP_IP":8080 > /dev/null 2>&1; then
    echo "✅ QNAP web interface accessible on port 8080"
elif curl -s --connect-timeout 5 http://"$QNAP_IP":80 > /dev/null 2>&1; then
    echo "✅ QNAP web interface accessible on port 80"
else
    echo "⚠️  QNAP web interface not responding"
fi

# Test if FreshThreads is already deployed
echo ""
echo "5. Testing Existing FreshThreads Deployment..."
if curl -s http://"$QNAP_IP":"$BACKEND_PORT"/health 2>/dev/null | grep -q "healthy"; then
    echo "✅ FreshThreads backend is running"
    echo "   Backend: http://$QNAP_IP:$BACKEND_PORT"
else
    echo "ℹ️  FreshThreads not yet deployed"
fi

if curl -s http://"$QNAP_IP":"$FRONTEND_PORT" 2>/dev/null | grep -q "FreshThreads"; then
    echo "✅ FreshThreads frontend is running"
    echo "   Frontend: http://$QNAP_IP:$FRONTEND_PORT"
else
    echo "ℹ️  FreshThreads frontend not yet deployed"
fi

echo ""
echo "🔧 Quick Setup Commands:"
echo "========================"
echo "1. Enable SSH (if needed):"
echo "   - Login to QNAP web interface"
echo "   - Go to Control Panel > Telnet/SSH"
echo "   - Enable SSH service"
echo ""
echo "2. Install Container Station (if needed):"
echo "   - Go to App Center"
echo "   - Install 'Container Station'"
echo ""
echo "3. Setup SSH key access:"
echo "   ssh-copy-id admin1@$QNAP_IP"
echo ""
echo "4. Deploy FreshThreads:"
echo "   ./deploy-to-qnap.sh"
echo ""
echo "📊 QNAP System Info:"
echo "===================="
if ssh admin1@"$QNAP_IP" "uname -a 2>/dev/null"; then
    echo "System information retrieved"
else
    echo "System information requires SSH access"
fi
