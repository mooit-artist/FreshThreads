#!/usr/bin/env pwsh
# Enable SMTP Authentication for Office 365 Tenant
# Must be run by Global Administrator

Write-Host "=== Enable SMTP Authentication ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Install-ExchangeModule {
    Write-Log "Checking ExchangeOnlineManagement module..." "INFO"

    if (-not (Get-Module -ListAvailable -Name "ExchangeOnlineManagement")) {
        Write-Log "Installing ExchangeOnlineManagement module..." "WARNING"
        try {
            Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
            Write-Log "✅ ExchangeOnlineManagement installed successfully" "SUCCESS"
        } catch {
            Write-Log "❌ Failed to install ExchangeOnlineManagement: $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-Log "✅ ExchangeOnlineManagement already installed" "SUCCESS"
    }
    return $true
}

function Connect-ExchangeOnline {
    Write-Log "Connecting to Exchange Online..." "INFO"

    try {
        Import-Module ExchangeOnlineManagement -Force
        Connect-ExchangeOnline -ShowProgress $true

        Write-Log "✅ Connected to Exchange Online" "SUCCESS"
        return $true
    } catch {
        Write-Log "❌ Failed to connect to Exchange Online: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Enable-SMTPAuthentication {
    Write-Log "Enabling SMTP Authentication..." "INFO"

    try {
        # Check current status
        Write-Log "Checking current SMTP auth status..." "INFO"
        $currentConfig = Get-TransportConfig | Select-Object SmtpClientAuthenticationDisabled
        Write-Log "Current SMTP Auth Disabled: $($currentConfig.SmtpClientAuthenticationDisabled)" "INFO"

        if ($currentConfig.SmtpClientAuthenticationDisabled -eq $true) {
            Write-Log "SMTP Authentication is currently DISABLED. Enabling it..." "WARNING"

            # Enable SMTP authentication
            Set-TransportConfig -SmtpClientAuthenticationDisabled $false

            Write-Log "✅ SMTP Authentication enabled successfully" "SUCCESS"
        } else {
            Write-Log "✅ SMTP Authentication is already enabled" "SUCCESS"
        }

        # Verify the change
        Start-Sleep -Seconds 3
        $newConfig = Get-TransportConfig | Select-Object SmtpClientAuthenticationDisabled
        Write-Log "Updated SMTP Auth Disabled: $($newConfig.SmtpClientAuthenticationDisabled)" "INFO"

        return $true
    } catch {
        Write-Log "❌ Failed to enable SMTP Authentication: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Enable-UserSMTPAuth {
    param([string]$UserEmail = "procurement@freshthreadsllc.com")

    Write-Log "Enabling SMTP auth for user: $UserEmail" "INFO"

    try {
        # Check current user SMTP auth status
        $mailbox = Get-CASMailbox -Identity $UserEmail | Select-Object SmtpClientAuthenticationDisabled
        Write-Log "Current user SMTP Auth Disabled: $($mailbox.SmtpClientAuthenticationDisabled)" "INFO"

        if ($mailbox.SmtpClientAuthenticationDisabled -eq $true) {
            Write-Log "User SMTP Authentication is DISABLED. Enabling it..." "WARNING"

            # Enable SMTP auth for the user
            Set-CASMailbox -Identity $UserEmail -SmtpClientAuthenticationDisabled $false

            Write-Log "✅ SMTP Authentication enabled for user: $UserEmail" "SUCCESS"
        } else {
            Write-Log "✅ SMTP Authentication is already enabled for user: $UserEmail" "SUCCESS"
        }

        return $true
    } catch {
        Write-Log "❌ Failed to enable SMTP auth for user: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-SMTPStatus {
    Write-Log "Checking SMTP Authentication status..." "INFO"

    try {
        # Tenant-wide status
        $transportConfig = Get-TransportConfig | Select-Object SmtpClientAuthenticationDisabled
        Write-Host ""
        Write-Host "=== SMTP Authentication Status ===" -ForegroundColor Cyan
        Write-Host "Tenant-wide SMTP Auth Disabled: $($transportConfig.SmtpClientAuthenticationDisabled)" -ForegroundColor White

        # User-specific status
        $userEmail = "procurement@freshthreadsllc.com"
        $casMailbox = Get-CASMailbox -Identity $userEmail | Select-Object SmtpClientAuthenticationDisabled
        Write-Host "User ($userEmail) SMTP Auth Disabled: $($casMailbox.SmtpClientAuthenticationDisabled)" -ForegroundColor White
        Write-Host ""

        if ($transportConfig.SmtpClientAuthenticationDisabled -eq $false -and $casMailbox.SmtpClientAuthenticationDisabled -eq $false) {
            Write-Host "✅ SMTP Authentication is ENABLED for both tenant and user" -ForegroundColor Green
        } else {
            Write-Host "❌ SMTP Authentication needs to be enabled" -ForegroundColor Red
        }

    } catch {
        Write-Log "❌ Failed to check SMTP status: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "Starting SMTP Authentication enablement..." "INFO"

    # Install Exchange module
    if (-not (Install-ExchangeModule)) {
        Write-Log "❌ Failed to install Exchange module" "ERROR"
        return
    }

    # Connect to Exchange Online
    if (-not (Connect-ExchangeOnline)) {
        Write-Log "❌ Failed to connect to Exchange Online" "ERROR"
        return
    }

    # Enable SMTP auth tenant-wide
    Enable-SMTPAuthentication

    # Enable SMTP auth for specific user
    Enable-UserSMTPAuth -UserEmail "procurement@freshthreadsllc.com"

    # Show final status
    Show-SMTPStatus

    Write-Host ""
    Write-Host "=== Next Steps ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. 🔑 Create an app password:" -ForegroundColor Yellow
    Write-Host "   - Go to: https://account.microsoft.com/security" -ForegroundColor White
    Write-Host "   - Sign in with: procurement@freshthreadsllc.com" -ForegroundColor White
    Write-Host "   - Go to: Advanced security options" -ForegroundColor White
    Write-Host "   - Add: App password" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 📝 Update configuration with app password:" -ForegroundColor Yellow
    Write-Host "   ./scripts/update-smtp-config.sh YOUR_NEW_APP_PASSWORD" -ForegroundColor White
    Write-Host ""
    Write-Host "3. 🧪 Test email functionality:" -ForegroundColor Yellow
    Write-Host "   python scripts/o365_email_handler.py send" -ForegroundColor White
    Write-Host ""

    # Disconnect
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

    Write-Log "SMTP Authentication enablement completed" "SUCCESS"
}

# Run the main function
Main
