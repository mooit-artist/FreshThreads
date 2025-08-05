# DKIM Auto-Configuration Script for Fresh Threads LLC
# Run this in PowerShell to automatically configure DKIM and get DNS records

param(
    [switch]$TestOnly = $false,
    [switch]$SkipInstall = $false
)

Write-Host "🔐 DKIM Auto-Configuration for Fresh Threads LLC" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Function to check if running as administrator (Windows only)
function Test-Administrator {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return $true  # Assume admin on non-Windows systems
}

# Install required modules
if (!$SkipInstall) {
    Write-Host "📦 Checking PowerShell modules..." -ForegroundColor Blue

    if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Host "Installing ExchangeOnlineManagement module..." -ForegroundColor Yellow
        try {
            Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
            Write-Host "✅ ExchangeOnlineManagement installed" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to install ExchangeOnlineManagement: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Try running: Install-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "✅ ExchangeOnlineManagement already installed" -ForegroundColor Green
    }
}

if ($TestOnly) {
    Write-Host "🧪 Test mode - checking current DKIM status only" -ForegroundColor Yellow
} else {
    Write-Host "🔧 Full configuration mode - will enable DKIM if not active" -ForegroundColor Yellow
}

Write-Host ""

try {
    # Connect to Exchange Online
    Write-Host "🔐 Connecting to Microsoft 365..." -ForegroundColor Blue
    Write-Host "Please sign in with procurement@freshthreadsllc.com when prompted" -ForegroundColor Yellow

    Connect-ExchangeOnline -UserPrincipalName "procurement@freshthreadsllc.com" -ShowProgress $true
    Write-Host "✅ Connected to Exchange Online" -ForegroundColor Green

    # Check current DKIM configuration
    Write-Host ""
    Write-Host "🔍 Checking DKIM configuration for freshthreadsllc.com..." -ForegroundColor Blue

    $dkimConfig = Get-DkimSigningConfig -Identity "freshthreadsllc.com" -ErrorAction SilentlyContinue

    if ($dkimConfig) {
        Write-Host "📋 Current DKIM Status:" -ForegroundColor Cyan
        Write-Host "  Domain: $($dkimConfig.Domain)" -ForegroundColor White
        Write-Host "  Enabled: $($dkimConfig.Enabled)" -ForegroundColor White
        Write-Host "  Status: $($dkimConfig.Status)" -ForegroundColor White

        if ($dkimConfig.Enabled) {
            Write-Host "✅ DKIM is already enabled!" -ForegroundColor Green
        } else {
            if (!$TestOnly) {
                Write-Host "🔧 DKIM is disabled. Enabling now..." -ForegroundColor Yellow
                Set-DkimSigningConfig -Identity "freshthreadsllc.com" -Enabled $true

                # Refresh config after enabling
                Start-Sleep -Seconds 2
                $dkimConfig = Get-DkimSigningConfig -Identity "freshthreadsllc.com"

                if ($dkimConfig.Enabled) {
                    Write-Host "✅ DKIM successfully enabled!" -ForegroundColor Green
                } else {
                    Write-Host "⚠️ DKIM enable command completed, but status still shows disabled" -ForegroundColor Yellow
                    Write-Host "This may take a few minutes to propagate" -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ DKIM is disabled (test mode - not changing)" -ForegroundColor Red
            }
        }

        # Display DNS records needed
        Write-Host ""
        Write-Host "📋 DNS Records Required for Cloudflare:" -ForegroundColor Yellow
        Write-Host "=======================================" -ForegroundColor Yellow

        $selector1 = $dkimConfig.Selector1CNAME
        $selector2 = $dkimConfig.Selector2CNAME

        if ($selector1 -and $selector2) {
            Write-Host ""
            Write-Host "🔹 CNAME Record 1:" -ForegroundColor Cyan
            Write-Host "   Type: CNAME" -ForegroundColor White
            Write-Host "   Name: selector1._domainkey" -ForegroundColor White
            Write-Host "   Target: $selector1" -ForegroundColor Green
            Write-Host ""
            Write-Host "🔹 CNAME Record 2:" -ForegroundColor Cyan
            Write-Host "   Type: CNAME" -ForegroundColor White
            Write-Host "   Name: selector2._domainkey" -ForegroundColor White
            Write-Host "   Target: $selector2" -ForegroundColor Green

            # Create DNS records file
            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
            $dnsFile = "DKIM-DNS-Records-$timestamp.txt"

            $dnsContent = @"
DKIM DNS Configuration for Fresh Threads LLC
Generated: $(Get-Date)
Domain: freshthreadsllc.com

=== ADD THESE CNAME RECORDS TO CLOUDFLARE ===

Record 1:
Type: CNAME
Name: selector1._domainkey
Target: $selector1
TTL: Auto (or 3600)

Record 2:
Type: CNAME
Name: selector2._domainkey
Target: $selector2
TTL: Auto (or 3600)

=== CLOUDFLARE SETUP INSTRUCTIONS ===

1. Log into https://dash.cloudflare.com
2. Select domain: freshthreadsllc.com
3. Go to: DNS → Records
4. Click: + Add record
5. Select: CNAME
6. Add both records above
7. Save changes

=== VERIFICATION (Wait 15-30 minutes after adding) ===

Command line verification:
nslookup -type=CNAME selector1._domainkey.freshthreadsllc.com
nslookup -type=CNAME selector2._domainkey.freshthreadsllc.com

Online verification:
https://mxtoolbox.com/dkim.aspx
https://dkimvalidator.com/

=== EMAIL TEST ===

Send test email from procurement@freshthreadsllc.com to:
check-auth@verifier.port25.com

You'll receive an authentication report showing:
- SPF: Pass
- DKIM: Pass
- DMARC: Pass

This confirms triple email authentication is working.

=== TROUBLESHOOTING ===

If DKIM records don't resolve:
1. Check TTL propagation time
2. Verify exact record names and values
3. Clear DNS cache: ipconfig /flushdns (Windows)
4. Contact Cloudflare support if issues persist

Microsoft Support: 1-800-642-7676
Generated by: DKIM Auto-Configuration Script
"@

            # Save to desktop and current directory
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $desktopFile = Join-Path $desktopPath $dnsFile
            $localFile = Join-Path (Get-Location) $dnsFile

            $dnsContent | Out-File -FilePath $desktopFile -Encoding UTF8
            $dnsContent | Out-File -FilePath $localFile -Encoding UTF8

            Write-Host ""
            Write-Host "📄 DNS records saved to:" -ForegroundColor Green
            Write-Host "   Desktop: $desktopFile" -ForegroundColor White
            Write-Host "   Current directory: $localFile" -ForegroundColor White

        } else {
            Write-Host "⚠️ Could not retrieve DKIM selector information" -ForegroundColor Yellow
            Write-Host "This may indicate the domain is not fully configured" -ForegroundColor Yellow
        }

    } else {
        Write-Host "❌ Could not find DKIM configuration for freshthreadsllc.com" -ForegroundColor Red
        Write-Host "This may indicate:" -ForegroundColor Yellow
        Write-Host "  • Domain not verified in Microsoft 365" -ForegroundColor Yellow
        Write-Host "  • Insufficient permissions" -ForegroundColor Yellow
        Write-Host "  • Domain configuration incomplete" -ForegroundColor Yellow
    }

} catch {
    Write-Host "❌ Error during DKIM configuration: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "• Ensure you're signed in as Global Admin" -ForegroundColor White
    Write-Host "• Verify domain is added and verified in Microsoft 365" -ForegroundColor White
    Write-Host "• Check network connectivity" -ForegroundColor White
    Write-Host "• Try running: Connect-ExchangeOnline manually first" -ForegroundColor White
} finally {
    # Disconnect from Exchange Online
    Write-Host ""
    Write-Host "🔌 Disconnecting from Exchange Online..." -ForegroundColor Blue
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "=============" -ForegroundColor Yellow
Write-Host "1. Add the CNAME records to Cloudflare DNS" -ForegroundColor White
Write-Host "2. Wait 15-30 minutes for DNS propagation" -ForegroundColor White
Write-Host "3. Verify with nslookup commands" -ForegroundColor White
Write-Host "4. Send test email to check-auth@verifier.port25.com" -ForegroundColor White
Write-Host "5. Monitor DMARC reports for authentication improvements" -ForegroundColor White

Write-Host ""
Write-Host "🔒 Security Impact:" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "With DKIM enabled, you now have SPF + DKIM + DMARC protection" -ForegroundColor White
Write-Host "This provides enterprise-level email authentication and anti-spoofing" -ForegroundColor White

Write-Host ""
Write-Host "🆘 Support Resources:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "• Microsoft 365 Support: 1-800-642-7676" -ForegroundColor White
Write-Host "• Cloudflare Support: Via dashboard → Support" -ForegroundColor White
Write-Host "• DKIM Validator: https://dkimvalidator.com/" -ForegroundColor White
Write-Host "• Email Auth Checker: https://mxtoolbox.com/emailheaders.aspx" -ForegroundColor White
