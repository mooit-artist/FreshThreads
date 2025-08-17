#!/usr/bin/env powershell
# Microsoft 365 App Password Generator for FreshThreads Contact Form
# Automates creation of app passwords for SMTP authentication

param(
    [Parameter(Mandatory=$false)]
    [string]$UserEmail = "procurement@freshthreadsllc.com",

    [Parameter(Mandatory=$false)]
    [string]$AppName = "FreshThreads Contact Form",

    [Parameter(Mandatory=$false)]
    [switch]$EnableSMTP = $false,

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "../config/o365-config.env"
)

Write-Host "=== Microsoft 365 App Password Generator ===" -ForegroundColor Green
Write-Host "User: $UserEmail" -ForegroundColor Yellow
Write-Host "App: $AppName" -ForegroundColor Yellow
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

function Test-ModuleInstalled {
    param([string]$ModuleName)
    return Get-Module -ListAvailable -Name $ModuleName
}

function Install-RequiredModules {
    Write-Log "Checking required PowerShell modules..." "INFO"

    $modules = @(
        "ExchangeOnlineManagement",
        "MSOnline",
        "AzureAD"
    )

    foreach ($module in $modules) {
        if (-not (Test-ModuleInstalled $module)) {
            Write-Log "Installing $module..." "WARNING"
            try {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
                Write-Log "✅ $module installed successfully" "SUCCESS"
            } catch {
                Write-Log "❌ Failed to install $module: $($_.Exception.Message)" "ERROR"
                return $false
            }
        } else {
            Write-Log "✅ $module already installed" "SUCCESS"
        }
    }
    return $true
}

function Connect-O365Services {
    Write-Log "Connecting to Office 365 services..." "INFO"

    try {
        # Connect to Exchange Online
        Write-Log "Connecting to Exchange Online..." "INFO"
        Connect-ExchangeOnline -ShowBanner:$false
        Write-Log "✅ Connected to Exchange Online" "SUCCESS"

        # Connect to MSOnline (for user management)
        Write-Log "Connecting to MSOnline..." "INFO"
        Connect-MsolService
        Write-Log "✅ Connected to MSOnline" "SUCCESS"

        return $true
    } catch {
        Write-Log "❌ Failed to connect to Office 365: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Enable-SMTPAuthentication {
    param([string]$Email)

    Write-Log "Enabling SMTP authentication for $Email..." "INFO"

    try {
        # Enable SMTP AUTH for the specific user
        Set-CASMailbox -Identity $Email -SmtpClientAuthenticationDisabled $false
        Write-Log "✅ SMTP authentication enabled for $Email" "SUCCESS"

        # Also enable at tenant level if needed
        Write-Log "Checking tenant-level SMTP authentication..." "INFO"
        $transportConfig = Get-TransportConfig
        if ($transportConfig.SmtpClientAuthenticationDisabled) {
            Write-Log "Enabling SMTP authentication at tenant level..." "WARNING"
            Set-TransportConfig -SmtpClientAuthenticationDisabled $false
            Write-Log "✅ Tenant-level SMTP authentication enabled" "SUCCESS"
        }

        return $true
    } catch {
        Write-Log "❌ Failed to enable SMTP authentication: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Enable-MultiFactorAuth {
    param([string]$Email)

    Write-Log "Checking MFA status for $Email..." "INFO"

    try {
        $user = Get-MsolUser -UserPrincipalName $Email

        if ($user.StrongAuthenticationRequirements.Count -eq 0) {
            Write-Log "Enabling MFA for $Email (required for app passwords)..." "WARNING"

            $auth = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
            $auth.RelyingParty = "*"
            $auth.State = "Enabled"

            Set-MsolUser -UserPrincipalName $Email -StrongAuthenticationRequirements $auth
            Write-Log "✅ MFA enabled for $Email" "SUCCESS"
            Write-Log "⚠️  User will need to complete MFA setup on next login" "WARNING"
        } else {
            Write-Log "✅ MFA already enabled for $Email" "SUCCESS"
        }

        return $true
    } catch {
        Write-Log "❌ Failed to configure MFA: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Update-ConfigFile {
    param(
        [string]$FilePath,
        [string]$Username,
        [string]$Password
    )

    Write-Log "Updating configuration file: $FilePath..." "INFO"

    try {
        if (Test-Path $FilePath) {
            $content = Get-Content $FilePath

            # Update SMTP username
            $content = $content -replace "O365_SMTP_USERNAME=.*", "O365_SMTP_USERNAME=$Username"

            # Update SMTP password
            $content = $content -replace "O365_SMTP_PASSWORD=.*", "O365_SMTP_PASSWORD=$Password"

            # Write updated content
            $content | Set-Content $FilePath
            Write-Log "✅ Configuration file updated successfully" "SUCCESS"
        } else {
            Write-Log "❌ Configuration file not found: $FilePath" "ERROR"
            return $false
        }

        return $true
    } catch {
        Write-Log "❌ Failed to update configuration file: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-AppPasswordInstructions {
    param([string]$Email)

    Write-Log "App password must be generated manually..." "WARNING"

    Write-Host ""
    Write-Host "=== MANUAL STEPS REQUIRED ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to: https://account.microsoft.com/security" -ForegroundColor Cyan
    Write-Host "2. Sign in with: $Email" -ForegroundColor Cyan
    Write-Host "3. Navigate to: 'App passwords'" -ForegroundColor Cyan
    Write-Host "4. Click: 'Create new app password'" -ForegroundColor Cyan
    Write-Host "5. Name it: '$AppName'" -ForegroundColor Cyan
    Write-Host "6. Copy the generated password" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then run this command to update the config:" -ForegroundColor Green
    Write-Host ".\scripts\update-smtp-password.ps1 -Password 'YOUR_APP_PASSWORD'" -ForegroundColor Green
    Write-Host ""
}

function Main {
    Write-Log "Starting app password generation process..." "INFO"

    # Install required modules
    if (-not (Install-RequiredModules)) {
        Write-Log "❌ Failed to install required modules" "ERROR"
        return
    }

    # Connect to Office 365
    if (-not (Connect-O365Services)) {
        Write-Log "❌ Failed to connect to Office 365" "ERROR"
        return
    }

    # Enable SMTP authentication if requested
    if ($EnableSMTP) {
        if (-not (Enable-SMTPAuthentication -Email $UserEmail)) {
            Write-Log "❌ Failed to enable SMTP authentication" "ERROR"
            return
        }
    }

    # Enable MFA (required for app passwords)
    if (-not (Enable-MultiFactorAuth -Email $UserEmail)) {
        Write-Log "❌ Failed to configure MFA" "ERROR"
        return
    }

    # Show manual instructions for app password generation
    Show-AppPasswordInstructions -Email $UserEmail

    Write-Log "App password setup process completed" "SUCCESS"
    Write-Log "Next steps: Follow the manual instructions above" "INFO"
}

# Run the main function
Main
