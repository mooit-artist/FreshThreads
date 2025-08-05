#!/bin/bash

# Fully Automated DKIM Setup for Fresh Threads LLC
# This script handles the complete DKIM configuration process

set -e  # Exit on any error

echo "🚀 Automated DKIM Setup for Fresh Threads LLC"
echo "=============================================="
echo ""

# Configuration
DOMAIN="freshthreadsllc.com"
ADMIN_EMAIL="procurement@freshthreadsllc.com"
DNS_PROVIDER="Cloudflare"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

log_step() {
    echo -e "${CYAN}🔧 $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."

    # Check if PowerShell is available
    if command -v pwsh >/dev/null 2>&1; then
        log_success "PowerShell Core found"
        PS_CMD="pwsh"
    elif command -v powershell >/dev/null 2>&1; then
        log_success "PowerShell found"
        PS_CMD="powershell"
    else
        log_error "PowerShell not found. Please install PowerShell Core."
        echo "Install from: https://github.com/PowerShell/PowerShell"
        exit 1
    fi

    # Check internet connectivity
    if ping -c 1 google.com >/dev/null 2>&1; then
        log_success "Internet connectivity confirmed"
    else
        log_error "No internet connection. Please check your network."
        exit 1
    fi
}

# Install required PowerShell modules
install_modules() {
    log_step "Installing required PowerShell modules..."

    cat > /tmp/install-modules.ps1 << 'EOF'
# Install required modules for DKIM setup
$modules = @("ExchangeOnlineManagement", "AzureAD")

foreach ($module in $modules) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        try {
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
            Write-Host "✅ $module installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to install $module`: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✅ $module already installed" -ForegroundColor Green
    }
}
EOF

    $PS_CMD -File /tmp/install-modules.ps1
    rm /tmp/install-modules.ps1
}

# Main DKIM configuration function
configure_dkim() {
    log_step "Configuring DKIM for $DOMAIN..."

    # Create comprehensive PowerShell script
    cat > /tmp/dkim-auto-setup.ps1 << EOF
# Automated DKIM Configuration Script
param()

Write-Host "🔐 Automated DKIM Setup for Fresh Threads LLC" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

try {
    # Connect to Exchange Online
    Write-Host "🔗 Connecting to Exchange Online..." -ForegroundColor Blue
    Write-Host "Please authenticate with $ADMIN_EMAIL" -ForegroundColor Yellow

    Connect-ExchangeOnline -UserPrincipalName "$ADMIN_EMAIL" -ShowProgress \$true
    Write-Host "✅ Connected successfully" -ForegroundColor Green

    # Verify domain exists
    Write-Host ""
    Write-Host "🌐 Verifying domain configuration..." -ForegroundColor Blue
    \$domains = Get-AcceptedDomain
    \$targetDomain = \$domains | Where-Object { \$_.DomainName -eq "$DOMAIN" }

    if (!\$targetDomain) {
        Write-Host "❌ Domain $DOMAIN not found in accepted domains" -ForegroundColor Red
        Write-Host "Available domains:" -ForegroundColor Yellow
        \$domains | ForEach-Object { Write-Host "  • \$(\$_.DomainName)" -ForegroundColor White }
        exit 1
    }

    Write-Host "✅ Domain $DOMAIN found and configured" -ForegroundColor Green

    # Try multiple approaches to configure DKIM
    Write-Host ""
    Write-Host "🔧 Configuring DKIM signing..." -ForegroundColor Blue

    # Approach 1: Try to get existing config
    try {
        \$dkimConfig = Get-DkimSigningConfig -Identity "$DOMAIN" -ErrorAction Stop
        Write-Host "✅ DKIM configuration found" -ForegroundColor Green

        if (!\$dkimConfig.Enabled) {
            Write-Host "🔄 Enabling DKIM signing..." -ForegroundColor Yellow
            Set-DkimSigningConfig -Identity "$DOMAIN" -Enabled \$true
            Start-Sleep -Seconds 3
            \$dkimConfig = Get-DkimSigningConfig -Identity "$DOMAIN"
        }

    } catch {
        Write-Host "⚠️ DKIM config not found, initializing..." -ForegroundColor Yellow

        # Approach 2: Try to create new DKIM config
        try {
            New-DkimSigningConfig -DomainName "$DOMAIN" -Enabled \$true -ErrorAction Stop
            Write-Host "✅ DKIM configuration created" -ForegroundColor Green
            Start-Sleep -Seconds 5
            \$dkimConfig = Get-DkimSigningConfig -Identity "$DOMAIN"

        } catch {
            Write-Host "⚠️ New-DkimSigningConfig failed, trying alternative..." -ForegroundColor Yellow

            # Approach 3: Enable via Set command (sometimes works)
            try {
                Set-DkimSigningConfig -Identity "$DOMAIN" -Enabled \$true -ErrorAction Stop
                Start-Sleep -Seconds 3
                \$dkimConfig = Get-DkimSigningConfig -Identity "$DOMAIN" -ErrorAction SilentlyContinue

            } catch {
                Write-Host "⚠️ All automated approaches failed" -ForegroundColor Yellow
                Write-Host "This usually means DKIM needs manual initialization via GUI" -ForegroundColor Yellow

                # Create manual instructions
                \$manualInstructions = @"
MANUAL DKIM SETUP REQUIRED

1. Open: https://security.microsoft.com
2. Sign in: $ADMIN_EMAIL
3. Navigate: Email & Collaboration → Policies & Rules → Threat Policies → DKIM
4. Find: $DOMAIN
5. Click: Enable DKIM signing
6. Copy: The two CNAME records
7. Run this script again to get DNS records automatically

This is a one-time setup requirement for new domains.
"@

                \$manualInstructions | Out-File -FilePath "\$env:USERPROFILE/Desktop/Manual-DKIM-Setup.txt"
                Write-Host "📄 Manual instructions saved to Desktop" -ForegroundColor Cyan
                throw "Manual setup required"
            }
        }
    }

    # If we have DKIM config, extract DNS records
    if (\$dkimConfig) {
        Write-Host ""
        Write-Host "📋 DKIM Configuration Status:" -ForegroundColor Cyan
        Write-Host "  Domain: \$(\$dkimConfig.Domain)" -ForegroundColor White
        Write-Host "  Enabled: \$(\$dkimConfig.Enabled)" -ForegroundColor White
        Write-Host "  Status: \$(\$dkimConfig.Status)" -ForegroundColor White

        if (\$dkimConfig.Selector1CNAME -and \$dkimConfig.Selector2CNAME) {
            Write-Host ""
            Write-Host "🎯 DNS Records for $DNS_PROVIDER:" -ForegroundColor Yellow
            Write-Host "=================================" -ForegroundColor Yellow

            \$selector1 = \$dkimConfig.Selector1CNAME
            \$selector2 = \$dkimConfig.Selector2CNAME

            Write-Host ""
            Write-Host "Record 1:" -ForegroundColor Cyan
            Write-Host "  Type: CNAME" -ForegroundColor White
            Write-Host "  Name: selector1._domainkey" -ForegroundColor White
            Write-Host "  Target: \$selector1" -ForegroundColor Green

            Write-Host ""
            Write-Host "Record 2:" -ForegroundColor Cyan
            Write-Host "  Type: CNAME" -ForegroundColor White
            Write-Host "  Name: selector2._domainkey" -ForegroundColor White
            Write-Host "  Target: \$selector2" -ForegroundColor Green

            # Generate DNS automation script
            \$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            \$dnsScript = @"
#!/bin/bash
# Automated DNS Record Addition for $DNS_PROVIDER
# Generated: \$(Get-Date)

echo "🌐 Adding DKIM DNS Records to $DNS_PROVIDER"
echo "=========================================="

# Record 1
echo "Adding selector1._domainkey CNAME record..."
# For Cloudflare API (requires API token):
# curl -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
#   -H "Authorization: Bearer YOUR_API_TOKEN" \
#   -H "Content-Type: application/json" \
#   --data '{"type":"CNAME","name":"selector1._domainkey","content":"\$selector1","ttl":3600}'

echo "Record 1: selector1._domainkey → \$selector1"

# Record 2
echo "Adding selector2._domainkey CNAME record..."
# curl -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
#   -H "Authorization: Bearer YOUR_API_TOKEN" \
#   -H "Content-Type: application/json" \
#   --data '{"type":"CNAME","name":"selector2._domainkey","content":"\$selector2","ttl":3600}'

echo "Record 2: selector2._domainkey → \$selector2"

echo ""
echo "✅ DNS records ready for manual addition to $DNS_PROVIDER"
echo "📖 Add these via $DNS_PROVIDER dashboard → DNS → Records"
"@

            # Save all outputs
            \$outputDir = "\$env:USERPROFILE/Desktop"
            \$dnsRecordsFile = "\$outputDir/DKIM-DNS-Records-\$timestamp.txt"
            \$dnsScriptFile = "\$outputDir/add-dns-records-\$timestamp.sh"

            # DNS Records file
            \$dnsContent = @"
DKIM DNS Configuration for Fresh Threads LLC
Generated: \$(Get-Date)
Domain: $DOMAIN
Admin: $ADMIN_EMAIL

CLOUDFLARE DNS RECORDS TO ADD:
=============================

Record 1:
Type: CNAME
Name: selector1._domainkey
Target: \$selector1
TTL: Auto (or 3600)

Record 2:
Type: CNAME
Name: selector2._domainkey
Target: \$selector2
TTL: Auto (or 3600)

MANUAL SETUP INSTRUCTIONS:
=========================
1. Go to: https://dash.cloudflare.com
2. Select: $DOMAIN
3. Navigate: DNS → Records
4. Click: Add record
5. Add both CNAME records above

VERIFICATION COMMANDS:
=====================
# Wait 15-30 minutes after adding, then test:
nslookup -type=CNAME selector1._domainkey.$DOMAIN
nslookup -type=CNAME selector2._domainkey.$DOMAIN

# Online verification:
https://mxtoolbox.com/dkim.aspx
https://dkimvalidator.com/

EMAIL AUTHENTICATION TEST:
=========================
Send test email:
From: $ADMIN_EMAIL
To: check-auth@verifier.port25.com
Subject: DKIM Test

Expected result: SPF=Pass, DKIM=Pass, DMARC=Pass

SECURITY IMPACT:
===============
✅ Email spoofing prevention
✅ Improved deliverability
✅ Enhanced brand protection
✅ Business email trust
"@

            \$dnsContent | Out-File -FilePath \$dnsRecordsFile -Encoding UTF8
            \$dnsScript | Out-File -FilePath \$dnsScriptFile -Encoding UTF8

            Write-Host ""
            Write-Host "📄 Files created:" -ForegroundColor Green
            Write-Host "  DNS Records: \$dnsRecordsFile" -ForegroundColor White
            Write-Host "  DNS Script: \$dnsScriptFile" -ForegroundColor White

            # Set executable permission on script
            if (\$IsLinux -or \$IsMacOS) {
                chmod +x \$dnsScriptFile
            }

            return \$true

        } else {
            Write-Host "⚠️ DKIM selectors not available yet" -ForegroundColor Yellow
            Write-Host "The configuration may need more time to initialize" -ForegroundColor Yellow
            return \$false
        }

    } else {
        Write-Host "❌ Could not retrieve DKIM configuration" -ForegroundColor Red
        return \$false
    }

} catch {
    Write-Host "❌ Error: \$(\$_.Exception.Message)" -ForegroundColor Red
    return \$false
} finally {
    Write-Host ""
    Write-Host "🔌 Disconnecting from Exchange Online..." -ForegroundColor Blue
    Disconnect-ExchangeOnline -Confirm:\$false -ErrorAction SilentlyContinue
}
EOF

    # Execute the PowerShell script
    $PS_CMD -File /tmp/dkim-auto-setup.ps1
    local result=$?

    # Cleanup
    rm /tmp/dkim-auto-setup.ps1

    return $result
}

# Verify DNS records after configuration
verify_dns_records() {
    log_step "Setting up DNS verification..."

    cat > /tmp/verify-dkim-dns.sh << 'EOF'
#!/bin/bash

DOMAIN="freshthreadsllc.com"

echo "🔍 DKIM DNS Verification for $DOMAIN"
echo "==================================="
echo ""

wait_time=30
echo "⏱️  Waiting $wait_time seconds for DNS propagation..."
sleep $wait_time

echo "🧪 Testing DNS records..."
echo ""

echo "Testing selector1._domainkey.$DOMAIN:"
if nslookup -type=CNAME selector1._domainkey.$DOMAIN; then
    echo "✅ Selector1 record found"
else
    echo "❌ Selector1 record not found (may need more time)"
fi

echo ""
echo "Testing selector2._domainkey.$DOMAIN:"
if nslookup -type=CNAME selector2._domainkey.$DOMAIN; then
    echo "✅ Selector2 record found"
else
    echo "❌ Selector2 record not found (may need more time)"
fi

echo ""
echo "📊 Online verification tools:"
echo "• https://mxtoolbox.com/dkim.aspx"
echo "• https://dkimvalidator.com/"
echo ""
echo "📧 Test email authentication:"
echo "Send from: procurement@freshthreadsllc.com"
echo "To: check-auth@verifier.port25.com"
EOF

    chmod +x /tmp/verify-dkim-dns.sh

    echo ""
    read -p "Do you want to verify DNS records now? (y/n): " verify_now

    if [[ $verify_now == "y" || $verify_now == "Y" ]]; then
        /tmp/verify-dkim-dns.sh
    else
        log_info "DNS verification script saved to /tmp/verify-dkim-dns.sh"
        log_info "Run it later with: /tmp/verify-dkim-dns.sh"
    fi

    rm /tmp/verify-dkim-dns.sh
}

# Main execution
main() {
    echo "🎯 Starting automated DKIM setup for $DOMAIN"
    echo "Admin email: $ADMIN_EMAIL"
    echo "DNS Provider: $DNS_PROVIDER"
    echo ""

    check_prerequisites
    echo ""

    install_modules
    echo ""

    if configure_dkim; then
        log_success "DKIM configuration completed successfully!"
        echo ""
        verify_dns_records

        echo ""
        log_success "🎉 Automated DKIM setup complete!"
        echo ""
        log_info "Next steps:"
        echo "1. Add DNS records to Cloudflare (files saved to Desktop)"
        echo "2. Wait 15-30 minutes for DNS propagation"
        echo "3. Test email authentication"
        echo "4. Monitor DMARC reports for improvements"

    else
        log_warning "Automated setup partially completed"
        log_info "Check Desktop for manual setup instructions"
        echo ""
        log_info "Common next steps:"
        echo "1. Complete manual DKIM initialization if needed"
        echo "2. Re-run this script after manual setup"
        echo "3. Add DNS records when available"
    fi

    echo ""
    log_info "Security documentation: project-management/m365tools/"
    log_info "Support: Microsoft 365 Support 1-800-642-7676"
}

# Run main function
main "$@"
