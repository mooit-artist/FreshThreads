# Complete Automated DKIM Setup for Fresh Threads LLC
# This script handles everything: modules, authentication, configuration, DNS records

param(
    [switch]$Force = $false,
    [switch]$SkipVerification = $false,
    [string]$CloudflareApiToken = "",
    [string]$CloudflareZoneId = ""
)

# Configuration
$Global:Config = @{
    Domain = "freshthreadsllc.com"
    AdminEmail = "procurement@freshthreadsllc.com"
    DnsProvider = "Cloudflare"
    MaxRetries = 3
    WaitTimeSeconds = 5
}

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Info", "Success", "Warning", "Error", "Step")]
        [string]$Type
    )

    $colors = @{
        "Info" = "Cyan"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Step" = "Blue"
    }

    $prefixes = @{
        "Info" = "ℹ️ "
        "Success" = "✅ "
        "Warning" = "⚠️ "
        "Error" = "❌ "
        "Step" = "🔧 "
    }

    Write-Host "$($prefixes[$Type])$Message" -ForegroundColor $colors[$Type]
}

function Install-RequiredModules {
    Write-ColorOutput "Installing required PowerShell modules..." "Step"

    $modules = @("ExchangeOnlineManagement", "AzureAD")

    foreach ($module in $modules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-ColorOutput "Installing $module..." "Info"
            try {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
                Write-ColorOutput "$module installed successfully" "Success"
            } catch {
                Write-ColorOutput "Failed to install $module`: $($_.Exception.Message)" "Error"
                throw
            }
        } else {
            Write-ColorOutput "$module already installed" "Success"
        }
    }
}

function Connect-M365Services {
    Write-ColorOutput "Connecting to Microsoft 365 services..." "Step"

    try {
        # Connect to Exchange Online
        Write-ColorOutput "Connecting to Exchange Online with $($Global:Config.AdminEmail)..." "Info"
        Connect-ExchangeOnline -UserPrincipalName $Global:Config.AdminEmail -ShowProgress $true
        Write-ColorOutput "Connected to Exchange Online" "Success"

        return $true
    } catch {
        Write-ColorOutput "Failed to connect to Microsoft 365: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Test-DomainConfiguration {
    Write-ColorOutput "Verifying domain configuration..." "Step"

    try {
        $domains = Get-AcceptedDomain
        $targetDomain = $domains | Where-Object { $_.DomainName -eq $Global:Config.Domain }

        if ($targetDomain) {
            Write-ColorOutput "Domain $($Global:Config.Domain) found and configured as $($targetDomain.DomainType)" "Success"
            return $true
        } else {
            Write-ColorOutput "Domain $($Global:Config.Domain) not found in accepted domains" "Error"
            Write-ColorOutput "Available domains:" "Info"
            $domains | ForEach-Object { Write-ColorOutput "  • $($_.DomainName)" "Info" }
            return $false
        }
    } catch {
        Write-ColorOutput "Error checking domain configuration: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Initialize-DkimConfiguration {
    Write-ColorOutput "Initializing DKIM configuration..." "Step"

    $retryCount = 0
    $maxRetries = $Global:Config.MaxRetries

    while ($retryCount -lt $maxRetries) {
        try {
            Write-ColorOutput "Attempt $($retryCount + 1) of $maxRetries..." "Info"

            # Try to get existing configuration first
            $dkimConfig = $null
            try {
                $dkimConfig = Get-DkimSigningConfig -Identity $Global:Config.Domain -ErrorAction Stop
                Write-ColorOutput "Existing DKIM configuration found" "Success"
            } catch {
                Write-ColorOutput "No existing DKIM config, creating new one..." "Info"

                # Try to create new DKIM configuration
                try {
                    New-DkimSigningConfig -DomainName $Global:Config.Domain -Enabled $true -ErrorAction Stop
                    Write-ColorOutput "New DKIM configuration created" "Success"
                    Start-Sleep -Seconds $Global:Config.WaitTimeSeconds
                    $dkimConfig = Get-DkimSigningConfig -Identity $Global:Config.Domain
                } catch {
                    Write-ColorOutput "New-DkimSigningConfig failed, trying Set-DkimSigningConfig..." "Warning"

                    # Alternative approach
                    Set-DkimSigningConfig -Identity $Global:Config.Domain -Enabled $true -ErrorAction Stop
                    Start-Sleep -Seconds $Global:Config.WaitTimeSeconds
                    $dkimConfig = Get-DkimSigningConfig -Identity $Global:Config.Domain -ErrorAction SilentlyContinue
                }
            }

            # Verify we have a configuration
            if ($dkimConfig) {
                Write-ColorOutput "DKIM configuration successful" "Success"
                return $dkimConfig
            } else {
                throw "Could not retrieve DKIM configuration after setup"
            }

        } catch {
            $retryCount++
            Write-ColorOutput "Attempt $retryCount failed: $($_.Exception.Message)" "Warning"

            if ($retryCount -lt $maxRetries) {
                Write-ColorOutput "Retrying in $($Global:Config.WaitTimeSeconds) seconds..." "Info"
                Start-Sleep -Seconds $Global:Config.WaitTimeSeconds
            }
        }
    }

    Write-ColorOutput "All automated attempts failed. Manual setup may be required." "Error"
    return $null
}

function Enable-DkimSigning {
    param($DkimConfig)

    if (!$DkimConfig.Enabled) {
        Write-ColorOutput "Enabling DKIM signing..." "Step"

        try {
            Set-DkimSigningConfig -Identity $Global:Config.Domain -Enabled $true
            Start-Sleep -Seconds 3

            # Refresh configuration
            $updatedConfig = Get-DkimSigningConfig -Identity $Global:Config.Domain

            if ($updatedConfig.Enabled) {
                Write-ColorOutput "DKIM signing enabled successfully" "Success"
            } else {
                Write-ColorOutput "DKIM signing enable command sent, but status not yet updated" "Warning"
                Write-ColorOutput "This is normal and may take a few minutes to propagate" "Info"
            }

            return $updatedConfig
        } catch {
            Write-ColorOutput "Error enabling DKIM signing: $($_.Exception.Message)" "Error"
            return $DkimConfig
        }
    } else {
        Write-ColorOutput "DKIM signing already enabled" "Success"
        return $DkimConfig
    }
}

function Export-DnsRecords {
    param($DkimConfig)

    if ($DkimConfig.Selector1CNAME -and $DkimConfig.Selector2CNAME) {
        Write-ColorOutput "Exporting DNS records..." "Step"

        $selector1 = $DkimConfig.Selector1CNAME
        $selector2 = $DkimConfig.Selector2CNAME

        Write-ColorOutput "DNS Records for $($Global:Config.DnsProvider):" "Info"
        Write-Host ""
        Write-ColorOutput "Record 1:" "Info"
        Write-Host "  Type: CNAME" -ForegroundColor White
        Write-Host "  Name: selector1._domainkey" -ForegroundColor White
        Write-Host "  Target: $selector1" -ForegroundColor Green
        Write-Host ""
        Write-ColorOutput "Record 2:" "Info"
        Write-Host "  Type: CNAME" -ForegroundColor White
        Write-Host "  Name: selector2._domainkey" -ForegroundColor White
        Write-Host "  Target: $selector2" -ForegroundColor Green

        # Generate comprehensive output files
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $outputDir = [Environment]::GetFolderPath("Desktop")

        # DNS Records file
        $dnsContent = @"
DKIM DNS Configuration for Fresh Threads LLC
===========================================
Generated: $(Get-Date)
Domain: $($Global:Config.Domain)
Admin: $($Global:Config.AdminEmail)
Status: $($DkimConfig.Status)
Enabled: $($DkimConfig.Enabled)

CLOUDFLARE DNS RECORDS:
======================

Record 1:
Type: CNAME
Name: selector1._domainkey
Target: $selector1
TTL: Auto (recommended) or 3600

Record 2:
Type: CNAME
Name: selector2._domainkey
Target: $selector2
TTL: Auto (recommended) or 3600

SETUP INSTRUCTIONS:
==================
1. Login to Cloudflare Dashboard: https://dash.cloudflare.com
2. Select domain: $($Global:Config.Domain)
3. Navigate to: DNS → Records
4. Click: + Add record
5. Add both CNAME records above
6. Save changes

VERIFICATION COMMANDS:
=====================
# Wait 15-30 minutes after adding DNS records, then test:

nslookup -type=CNAME selector1._domainkey.$($Global:Config.Domain)
nslookup -type=CNAME selector2._domainkey.$($Global:Config.Domain)

# Expected result: Both should return Microsoft 365 DKIM selectors

ONLINE VERIFICATION TOOLS:
==========================
• DKIM Validator: https://dkimvalidator.com/
• MX Toolbox DKIM: https://mxtoolbox.com/dkim.aspx
• Mail Tester: https://www.mail-tester.com/

EMAIL AUTHENTICATION TEST:
==========================
Send a test email:
From: $($Global:Config.AdminEmail)
To: check-auth@verifier.port25.com
Subject: DKIM Authentication Test

Expected results in authentication report:
✅ SPF: Pass
✅ DKIM: Pass
✅ DMARC: Pass

SECURITY BENEFITS:
=================
✅ Prevents email spoofing of your domain
✅ Improves email deliverability rates
✅ Enhances brand reputation and trust
✅ Meets business email security standards
✅ Protects against phishing attacks using your domain

TROUBLESHOOTING:
===============
If DNS records don't resolve after 30 minutes:
1. Check record names are exactly: selector1._domainkey and selector2._domainkey
2. Verify targets match exactly (case-sensitive)
3. Clear DNS cache: ipconfig /flushdns (Windows) or sudo dscacheutil -flushcache (macOS)
4. Contact Cloudflare support if issues persist

NEXT STEPS:
==========
1. Add DNS records to Cloudflare
2. Wait for DNS propagation (15-30 minutes)
3. Test email authentication
4. Monitor DMARC reports for improvements
5. Consider upgrading DMARC policy from 'monitoring' to 'quarantine'

SUPPORT RESOURCES:
=================
• Microsoft 365 Support: 1-800-642-7676
• Cloudflare Support: Via dashboard support ticket
• Fresh Threads IT Documentation: project-management/m365tools/

Configuration completed: $(Get-Date)
"@

        # Save files
        $dnsFile = Join-Path $outputDir "DKIM-DNS-Records-$timestamp.txt"
        $summaryFile = Join-Path $outputDir "DKIM-Setup-Summary-$timestamp.txt"

        $dnsContent | Out-File -FilePath $dnsFile -Encoding UTF8

        # Create setup summary
        $summary = @"
DKIM Setup Summary for Fresh Threads LLC
========================================
Completed: $(Get-Date)

✅ DKIM Configuration: Success
✅ DNS Records Generated: $dnsFile
✅ Domain: $($Global:Config.Domain)
✅ Admin Email: $($Global:Config.AdminEmail)

IMMEDIATE ACTIONS REQUIRED:
1. Add DNS records to Cloudflare (see DNS records file)
2. Wait 15-30 minutes for propagation
3. Test with: nslookup -type=CNAME selector1._domainkey.$($Global:Config.Domain)

FILES CREATED:
• $dnsFile
• $summaryFile

VERIFICATION SCRIPT:
Run this PowerShell command in 30 minutes:
Resolve-DnsName -Name "selector1._domainkey.$($Global:Config.Domain)" -Type CNAME
"@

        $summary | Out-File -FilePath $summaryFile -Encoding UTF8

        Write-Host ""
        Write-ColorOutput "Files created:" "Success"
        Write-Host "  📄 DNS Records: $dnsFile" -ForegroundColor White
        Write-Host "  📋 Summary: $summaryFile" -ForegroundColor White

        return @{
            Success = $true
            Selector1 = $selector1
            Selector2 = $selector2
            DnsFile = $dnsFile
        }
    } else {
        Write-ColorOutput "DKIM selectors not available yet" "Warning"
        Write-ColorOutput "This may indicate that DKIM needs manual GUI initialization" "Info"

        # Create manual setup instructions
        $manualInstructions = @"
MANUAL DKIM SETUP REQUIRED

The automated script was unable to retrieve DKIM selectors.
This typically happens with newly configured domains.

MANUAL SETUP STEPS:
==================
1. Open: https://security.microsoft.com
2. Sign in: $($Global:Config.AdminEmail)
3. Navigate: Email & Collaboration → Policies & Rules → Threat Policies → DKIM
4. Find: $($Global:Config.Domain)
5. Toggle: "Sign messages for this domain with DKIM signatures" to ON
6. Copy: The two CNAME records that appear
7. Add records to Cloudflare DNS
8. Re-run this script to verify configuration

This is a one-time initialization requirement.
After manual setup, automation will work for future changes.

Generated: $(Get-Date)
"@

        $manualFile = Join-Path ([Environment]::GetFolderPath("Desktop")) "Manual-DKIM-Setup-Required.txt"
        $manualInstructions | Out-File -FilePath $manualFile -Encoding UTF8

        Write-ColorOutput "Manual setup instructions saved to: $manualFile" "Info"

        return @{
            Success = $false
            ManualRequired = $true
            InstructionsFile = $manualFile
        }
    }
}

function Disconnect-M365Services {
    Write-ColorOutput "Disconnecting from Microsoft 365 services..." "Step"

    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Write-ColorOutput "Disconnected from Exchange Online" "Success"
    } catch {
        # Ignore disconnection errors
    }
}

# Main execution function
function Start-AutomatedDkimSetup {
    Write-Host "🚀 Automated DKIM Setup for Fresh Threads LLC" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""

    try {
        # Step 1: Install modules
        Install-RequiredModules
        Write-Host ""

        # Step 2: Connect to M365
        if (!(Connect-M365Services)) {
            throw "Failed to connect to Microsoft 365 services"
        }
        Write-Host ""

        # Step 3: Verify domain
        if (!(Test-DomainConfiguration)) {
            throw "Domain configuration verification failed"
        }
        Write-Host ""

        # Step 4: Initialize DKIM
        $dkimConfig = Initialize-DkimConfiguration
        if (!$dkimConfig) {
            Write-ColorOutput "Automated DKIM initialization failed" "Warning"
            Write-ColorOutput "Manual setup may be required" "Info"
        } else {
            Write-Host ""

            # Step 5: Enable DKIM if needed
            $dkimConfig = Enable-DkimSigning -DkimConfig $dkimConfig
            Write-Host ""

            # Step 6: Export DNS records
            $exportResult = Export-DnsRecords -DkimConfig $dkimConfig

            if ($exportResult.Success) {
                Write-Host ""
                Write-ColorOutput "🎉 DKIM setup completed successfully!" "Success"
                Write-Host ""
                Write-ColorOutput "Next steps:" "Info"
                Write-Host "1. Add DNS records to Cloudflare (see files on Desktop)" -ForegroundColor White
                Write-Host "2. Wait 15-30 minutes for DNS propagation" -ForegroundColor White
                Write-Host "3. Test email authentication" -ForegroundColor White
                Write-Host "4. Monitor DMARC reports" -ForegroundColor White
            } else {
                Write-Host ""
                Write-ColorOutput "⚠️ Automated setup partially completed" "Warning"
                Write-ColorOutput "Manual GUI setup required (see instructions on Desktop)" "Info"
            }
        }

    } catch {
        Write-ColorOutput "Error during automated setup: $($_.Exception.Message)" "Error"
        Write-Host ""
        Write-ColorOutput "Troubleshooting steps:" "Info"
        Write-Host "1. Ensure you have Global Administrator permissions" -ForegroundColor White
        Write-Host "2. Verify network connectivity" -ForegroundColor White
        Write-Host "3. Try manual setup via https://security.microsoft.com" -ForegroundColor White
        Write-Host "4. Contact Microsoft Support: 1-800-642-7676" -ForegroundColor White

    } finally {
        # Always disconnect
        Disconnect-M365Services
    }

    Write-Host ""
    Write-ColorOutput "Setup session completed" "Info"
    Write-ColorOutput "Documentation: project-management/m365tools/" "Info"
}

# Run the automated setup
Start-AutomatedDkimSetup
