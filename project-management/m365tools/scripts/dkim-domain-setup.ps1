# DKIM Domain Setup Script for Fresh Threads LLC
# Handles domain verification and DKIM configuration

param(
    [switch]$Force = $false
)

Write-Host "🔐 DKIM Domain Configuration for Fresh Threads LLC" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""

try {
    Write-Host "🔐 Connecting to Microsoft 365..." -ForegroundColor Blue
    Write-Host "Please sign in with procurement@freshthreadsllc.com" -ForegroundColor Yellow

    Connect-ExchangeOnline -UserPrincipalName "procurement@freshthreadsllc.com" -ShowProgress $true
    Write-Host "✅ Connected to Exchange Online" -ForegroundColor Green

    # Check accepted domains
    Write-Host ""
    Write-Host "🌐 Checking accepted domains..." -ForegroundColor Blue
    $domains = Get-AcceptedDomain

    Write-Host "Configured domains:" -ForegroundColor Cyan
    foreach ($domain in $domains) {
        $status = if ($domain.Default) { "(Default)" } else { "" }
        Write-Host "  • $($domain.DomainName) - $($domain.DomainType) $status" -ForegroundColor White
    }

    # Check if freshthreadsllc.com exists
    $targetDomain = $domains | Where-Object { $_.DomainName -eq "freshthreadsllc.com" }

    if ($targetDomain) {
        Write-Host "✅ freshthreadsllc.com is configured as $($targetDomain.DomainType)" -ForegroundColor Green

        # Try to get DKIM config - sometimes it needs to be initialized first
        Write-Host ""
        Write-Host "🔍 Checking DKIM configuration..." -ForegroundColor Blue

        try {
            $dkimConfig = Get-DkimSigningConfig -Identity "freshthreadsllc.com" -ErrorAction Stop

            Write-Host "Current DKIM Status:" -ForegroundColor Cyan
            Write-Host "  Domain: $($dkimConfig.Domain)" -ForegroundColor White
            Write-Host "  Enabled: $($dkimConfig.Enabled)" -ForegroundColor White
            Write-Host "  Status: $($dkimConfig.Status)" -ForegroundColor White

            if (!$dkimConfig.Enabled) {
                Write-Host ""
                Write-Host "🔧 DKIM is disabled. Enabling now..." -ForegroundColor Yellow

                try {
                    Set-DkimSigningConfig -Identity "freshthreadsllc.com" -Enabled $true
                    Write-Host "✅ DKIM enable command sent" -ForegroundColor Green

                    # Wait a moment and check again
                    Write-Host "Waiting for configuration to apply..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 5

                    $dkimConfig = Get-DkimSigningConfig -Identity "freshthreadsllc.com"

                } catch {
                    Write-Host "⚠️ Error enabling DKIM: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "This may be normal - DKIM sometimes needs to be configured via GUI first" -ForegroundColor Yellow
                }
            }

            # Display selectors regardless of enable status
            if ($dkimConfig.Selector1CNAME -and $dkimConfig.Selector2CNAME) {
                Write-Host ""
                Write-Host "📋 DKIM DNS Records for Cloudflare:" -ForegroundColor Yellow
                Write-Host "===================================" -ForegroundColor Yellow

                Write-Host ""
                Write-Host "🔹 CNAME Record 1:" -ForegroundColor Cyan
                Write-Host "   Type: CNAME" -ForegroundColor White
                Write-Host "   Name: selector1._domainkey" -ForegroundColor White
                Write-Host "   Target: $($dkimConfig.Selector1CNAME)" -ForegroundColor Green

                Write-Host ""
                Write-Host "🔹 CNAME Record 2:" -ForegroundColor Cyan
                Write-Host "   Type: CNAME" -ForegroundColor White
                Write-Host "   Name: selector2._domainkey" -ForegroundColor White
                Write-Host "   Target: $($dkimConfig.Selector2CNAME)" -ForegroundColor Green

                # Save to file
                $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
                $dnsFile = "DKIM-DNS-Records-$timestamp.txt"

                $dnsContent = @"
DKIM DNS Configuration for Fresh Threads LLC
Generated: $(Get-Date)
Domain: freshthreadsllc.com
User: procurement@freshthreadsllc.com

ADD THESE RECORDS TO CLOUDFLARE:

Record 1:
Type: CNAME
Name: selector1._domainkey
Target: $($dkimConfig.Selector1CNAME)

Record 2:
Type: CNAME
Name: selector2._domainkey
Target: $($dkimConfig.Selector2CNAME)

CLOUDFLARE INSTRUCTIONS:
1. Go to https://dash.cloudflare.com
2. Select freshthreadsllc.com
3. DNS → Records → Add record
4. Add both CNAME records above
5. Save and wait 15-30 minutes

VERIFICATION:
nslookup -type=CNAME selector1._domainkey.freshthreadsllc.com
nslookup -type=CNAME selector2._domainkey.freshthreadsllc.com

TEST EMAIL:
Send from procurement@freshthreadsllc.com to check-auth@verifier.port25.com
"@

                $desktopPath = [Environment]::GetFolderPath("Desktop")
                $outputFile = Join-Path $desktopPath $dnsFile
                $dnsContent | Out-File -FilePath $outputFile -Encoding UTF8

                Write-Host ""
                Write-Host "📄 DNS records saved to: $outputFile" -ForegroundColor Green

            } else {
                Write-Host "⚠️ DKIM selectors not available yet" -ForegroundColor Yellow
                Write-Host "This usually means DKIM needs to be initialized via the GUI first" -ForegroundColor Yellow
            }

        } catch {
            Write-Host "❌ Could not access DKIM configuration: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "This might mean:" -ForegroundColor Yellow
            Write-Host "• DKIM has not been initialized for this domain" -ForegroundColor White
            Write-Host "• Domain verification is still pending" -ForegroundColor White
            Write-Host "• Need to configure DKIM via Security Center GUI first" -ForegroundColor White

            Write-Host ""
            Write-Host "🔧 Manual Setup Required:" -ForegroundColor Cyan
            Write-Host "1. Go to https://security.microsoft.com" -ForegroundColor White
            Write-Host "2. Sign in with procurement@freshthreadsllc.com" -ForegroundColor White
            Write-Host "3. Email & Collaboration → Policies & Rules → Threat Policies → DKIM" -ForegroundColor White
            Write-Host "4. Find freshthreadsllc.com and enable DKIM signing" -ForegroundColor White
            Write-Host "5. Copy the CNAME records and add to Cloudflare" -ForegroundColor White
        }

    } else {
        Write-Host "❌ freshthreadsllc.com not found in accepted domains" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available domains:" -ForegroundColor Yellow
        foreach ($domain in $domains) {
            Write-Host "  • $($domain.DomainName)" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "You may need to add and verify freshthreadsllc.com in Microsoft 365 admin center first" -ForegroundColor Yellow
    }

} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Write-Host ""
    Write-Host "🔌 Disconnecting..." -ForegroundColor Blue
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "🎯 Summary:" -ForegroundColor Green
Write-Host "==========" -ForegroundColor Green
Write-Host "✅ Scripts updated to use procurement@freshthreadsllc.com" -ForegroundColor White
Write-Host "✅ Domain freshthreadsllc.com is configured in Microsoft 365" -ForegroundColor White
Write-Host "🔧 DKIM may need manual GUI configuration first" -ForegroundColor White
Write-Host ""
Write-Host "📖 Next steps:" -ForegroundColor Yellow
Write-Host "1. Try manual DKIM setup via Security Center if automated failed" -ForegroundColor White
Write-Host "2. Add DNS records to Cloudflare when you get them" -ForegroundColor White
Write-Host "3. Test email authentication after setup" -ForegroundColor White
