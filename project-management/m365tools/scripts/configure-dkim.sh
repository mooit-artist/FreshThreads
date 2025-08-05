#!/bin/bash

# DKIM Configuration Script for Fresh Threads LLC
# Purpose: Automate DKIM setup for Microsoft 365 and provide DNS instructions

echo "🔐 DKIM Configuration for Fresh Threads LLC"
echo "==========================================="
echo ""

# Check if we have the required tools
echo "📋 Prerequisites Check:"

# Check if PowerShell is available (for M365 configuration)
if command -v pwsh >/dev/null 2>&1; then
    echo "✅ PowerShell Core found"
    PS_CMD="pwsh"
elif command -v powershell >/dev/null 2>&1; then
    echo "✅ PowerShell found"
    PS_CMD="powershell"
else
    echo "❌ PowerShell not found"
    echo "   Install PowerShell Core: https://github.com/PowerShell/PowerShell"
    echo "   Or use the manual steps provided below"
    PS_AVAILABLE=false
fi

echo ""
echo "🎯 DKIM Setup Process:"
echo "======================"

if [[ $PS_AVAILABLE != false ]]; then
    echo "1. Automated M365 DKIM configuration (PowerShell)"
    echo "2. Manual DNS record addition (Cloudflare)"
    echo ""
    echo "Do you want to run the automated PowerShell configuration? (y/n)"
    read -r run_ps_config

    if [[ $run_ps_config == "y" || $run_ps_config == "Y" ]]; then
        echo ""
        echo "🔧 Running PowerShell DKIM configuration..."

        # Create temporary PowerShell script
        cat > /tmp/dkim-config.ps1 << 'EOF'
# DKIM Configuration Script for Microsoft 365
Write-Host "🔐 Configuring DKIM for Fresh Threads LLC" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Install ExchangeOnline module if not present
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing ExchangeOnlineManagement module..." -ForegroundColor Yellow
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
}

try {
    # Connect to Exchange Online
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Blue
    Write-Host "Please sign in with procurement@freshthreadsllc.com" -ForegroundColor Yellow
    Connect-ExchangeOnline -UserPrincipalName "procurement@freshthreadsllc.com" -ShowProgress $true

    # Get current DKIM config
    Write-Host "Checking current DKIM configuration..." -ForegroundColor Blue
    $dkimConfig = Get-DkimSigningConfig -Identity "freshthreadsllc.com"

    if ($dkimConfig) {
        Write-Host "Current DKIM Status: $($dkimConfig.Enabled)" -ForegroundColor Cyan

        if (!$dkimConfig.Enabled) {
            Write-Host "Enabling DKIM for freshthreadsllc.com..." -ForegroundColor Green
            Set-DkimSigningConfig -Identity "freshthreadsllc.com" -Enabled $true
            Write-Host "✅ DKIM enabled successfully!" -ForegroundColor Green
        } else {
            Write-Host "✅ DKIM is already enabled" -ForegroundColor Green
        }

        # Get the CNAME records needed
        Write-Host ""
        Write-Host "📋 DNS Records to Add to Cloudflare:" -ForegroundColor Yellow
        Write-Host "====================================" -ForegroundColor Yellow

        $selector1 = $dkimConfig.Selector1CNAME
        $selector2 = $dkimConfig.Selector2CNAME

        Write-Host ""
        Write-Host "Record 1:" -ForegroundColor Cyan
        Write-Host "Type: CNAME" -ForegroundColor White
        Write-Host "Name: selector1._domainkey" -ForegroundColor White
        Write-Host "Value: $selector1" -ForegroundColor White
        Write-Host ""
        Write-Host "Record 2:" -ForegroundColor Cyan
        Write-Host "Type: CNAME" -ForegroundColor White
        Write-Host "Name: selector2._domainkey" -ForegroundColor White
        Write-Host "Value: $selector2" -ForegroundColor White
        Write-Host ""

        # Save records to file
        $dnsRecords = @"
DKIM DNS Records for Fresh Threads LLC
Generated: $(Get-Date)

Add these CNAME records to Cloudflare DNS:

Record 1:
Type: CNAME
Name: selector1._domainkey
Value: $selector1

Record 2:
Type: CNAME
Name: selector2._domainkey
Value: $selector2

Instructions:
1. Log into Cloudflare dashboard
2. Select freshthreadsllc.com domain
3. Go to DNS → Records
4. Click "Add record"
5. Add both CNAME records above
6. Wait 15-30 minutes for propagation
7. Verify with: nslookup -type=CNAME selector1._domainkey.freshthreadsllc.com

"@

        $dnsRecords | Out-File -FilePath "$env:USERPROFILE/Desktop/DKIM-DNS-Records.txt" -Encoding UTF8
        Write-Host "📄 DNS records saved to: $env:USERPROFILE/Desktop/DKIM-DNS-Records.txt" -ForegroundColor Green

    } else {
        Write-Host "❌ Could not find DKIM configuration for freshthreadsllc.com" -ForegroundColor Red
        Write-Host "Domain may not be fully configured in Microsoft 365" -ForegroundColor Yellow
    }

} catch {
    Write-Host "❌ Error configuring DKIM: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to configure manually via admin.microsoft.com" -ForegroundColor Yellow
} finally {
    # Disconnect
    Write-Host "Disconnecting..." -ForegroundColor Blue
    Disconnect-ExchangeOnline -Confirm:$false
}

Write-Host ""
Write-Host "🎉 DKIM Configuration Complete!" -ForegroundColor Green
Write-Host "Next: Add the DNS records to Cloudflare" -ForegroundColor Yellow
EOF

        # Run the PowerShell script
        $PS_CMD -File /tmp/dkim-config.ps1

        # Clean up
        rm /tmp/dkim-config.ps1

    else
        echo "Skipping automated configuration"
    fi
else
    echo "⚠️ PowerShell not available - using manual process"
fi

echo ""
echo "📖 Manual DKIM Configuration Steps:"
echo "===================================="
echo ""
echo "If the automated script didn't work, follow these steps:"
echo ""
echo "1. Go to: https://security.microsoft.com"
echo "2. Sign in with procurement@freshthreadsllc.com"
echo "3. Navigate: Email & Collaboration → Policies & Rules → Threat Policies"
echo "4. Click: DKIM"
echo "5. Find: freshthreadsllc.com"
echo "6. Click: Enable DKIM signing"
echo "7. Copy the two CNAME records provided"
echo ""
echo "8. Log into Cloudflare:"
echo "   - Go to DNS → Records"
echo "   - Add Type: CNAME"
echo "   - Name: selector1._domainkey"
echo "   - Value: [from Microsoft 365]"
echo "   - Repeat for selector2._domainkey"
echo ""

echo "🔍 Verification Commands:"
echo "========================"
echo ""
echo "After adding DNS records (wait 15-30 minutes):"
echo ""
echo "nslookup -type=CNAME selector1._domainkey.freshthreadsllc.com"
echo "nslookup -type=CNAME selector2._domainkey.freshthreadsllc.com"
echo ""
echo "Expected result: Should return Microsoft 365 DKIM selectors"
echo ""

echo "📊 Test Email Authentication:"
echo "============================"
echo ""
echo "Send a test email from procurement@freshthreadsllc.com to:"
echo "• check-auth@verifier.port25.com"
echo "• You'll receive an authentication report"
echo ""
echo "Or use online tools:"
echo "• https://mxtoolbox.com/dkim.aspx"
echo "• https://dkimvalidator.com/"
echo ""

echo "✅ Next Steps After DKIM:"
echo "========================="
echo "1. Verify DKIM records propagated (15-30 min)"
echo "2. Test email authentication"
echo "3. Monitor DMARC reports for improvements"
echo "4. Consider strengthening DMARC policy to 'quarantine'"
echo ""

echo "🆘 Need Help?"
echo "============="
echo "• Microsoft Support: 1-800-642-7676"
echo "• Cloudflare Support: Via dashboard"
echo "• Documentation: DNS-SECURITY-ANALYSIS.md"
echo ""

echo "🔒 Security Impact:"
echo "=================="
echo "DKIM + SPF + DMARC = Triple Email Authentication"
echo "• Prevents email spoofing"
echo "• Improves deliverability"
echo "• Protects brand reputation"
echo "• Required for business email trust"
