#!/usr/bin/env powershell
# Find and Verify Azure App Registrations for FreshThreads
# Helps locate existing app registrations and their details

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName = "FreshThreads",

    [Parameter(Mandatory=$false)]
    [switch]$ListAll = $false
)

Write-Host "=== Azure App Registration Finder ===" -ForegroundColor Green
Write-Host "Searching for: $AppName" -ForegroundColor Yellow
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

function Install-RequiredModules {
    Write-Log "Checking required PowerShell modules..." "INFO"

    $modules = @(
        "AzureAD",
        "Az.Accounts",
        "Az.Resources"
    )

    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Log "Installing $module..." "WARNING"
            try {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
                Write-Log "✅ $module installed successfully" "SUCCESS"
            } catch {
                Write-Log "❌ Failed to install $module" "ERROR"
                return $false
            }
        } else {
            Write-Log "✅ $module already installed" "SUCCESS"
        }
    }
    return $true
}

function Connect-AzureServices {
    Write-Log "Connecting to Azure services..." "INFO"

    try {
        # Connect to Azure AD
        Write-Log "Connecting to Azure AD..." "INFO"
        Connect-AzureAD
        Write-Log "✅ Connected to Azure AD" "SUCCESS"

        # Get tenant info
        $tenantInfo = Get-AzureADTenantDetail
        Write-Log "Tenant: $($tenantInfo.DisplayName)" "INFO"
        Write-Log "Tenant ID: $($tenantInfo.ObjectId)" "INFO"

        return $true
    } catch {
        Write-Log "❌ Failed to connect to Azure: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Find-AppRegistrations {
    param([string]$SearchTerm)

    Write-Log "Searching for app registrations..." "INFO"

    try {
        if ($ListAll) {
            Write-Log "Listing ALL app registrations..." "INFO"
            $apps = Get-AzureADApplication
        } else {
            Write-Log "Searching for apps containing '$SearchTerm'..." "INFO"
            $apps = Get-AzureADApplication -Filter "startswith(displayName,'$SearchTerm')" -ErrorAction SilentlyContinue

            if (-not $apps) {
                # Try a broader search
                $apps = Get-AzureADApplication | Where-Object { $_.DisplayName -like "*$SearchTerm*" }
            }
        }

        if ($apps) {
            Write-Log "Found $($apps.Count) app registration(s)" "SUCCESS"

            foreach ($app in $apps) {
                Write-Host ""
                Write-Host "=== App Registration Details ===" -ForegroundColor Cyan
                Write-Host "Name: $($app.DisplayName)" -ForegroundColor White
                Write-Host "Application ID (Client ID): $($app.AppId)" -ForegroundColor Green
                Write-Host "Object ID: $($app.ObjectId)" -ForegroundColor Yellow
                Write-Host "Created: $($app.CreatedDateTime)" -ForegroundColor Gray

                # Check for API permissions
                $permissions = Get-AzureADApplication -ObjectId $app.ObjectId | Select-Object -ExpandProperty RequiredResourceAccess
                if ($permissions) {
                    Write-Host "API Permissions:" -ForegroundColor Cyan
                    foreach ($permission in $permissions) {
                        $resourceApp = Get-AzureADServicePrincipal -Filter "AppId eq '$($permission.ResourceAppId)'" -ErrorAction SilentlyContinue
                        if ($resourceApp) {
                            Write-Host "  - $($resourceApp.DisplayName)" -ForegroundColor White
                        }
                    }
                }

                # Check for client secrets
                Write-Host "Client Secrets:" -ForegroundColor Cyan
                $secrets = Get-AzureADApplication -ObjectId $app.ObjectId | Select-Object -ExpandProperty PasswordCredentials
                if ($secrets) {
                    foreach ($secret in $secrets) {
                        $status = if ($secret.EndDate -gt (Get-Date)) { "Active" } else { "Expired" }
                        $color = if ($status -eq "Active") { "Green" } else { "Red" }
                        Write-Host "  - Secret ID: $($secret.KeyId) ($status)" -ForegroundColor $color
                        Write-Host "    Expires: $($secret.EndDate)" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "  - No client secrets found" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Log "No app registrations found matching '$SearchTerm'" "WARNING"
            Write-Log "Try running with -ListAll to see all app registrations" "INFO"
        }

        return $apps
    } catch {
        Write-Log "❌ Failed to search app registrations: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Show-ConfigurationHelp {
    param($Apps)

    if ($Apps -and $Apps.Count -gt 0) {
        Write-Host ""
        Write-Host "=== Configuration Help ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "To update your O365 configuration, use these values:" -ForegroundColor Yellow

        $app = $Apps[0]  # Use the first app found

        Write-Host ""
        Write-Host "O365_CLIENT_ID=$($app.AppId)" -ForegroundColor Cyan
        Write-Host "O365_TENANT_ID=[Your Tenant ID from above]" -ForegroundColor Cyan
        Write-Host "O365_CLIENT_SECRET=[Generate new secret if needed]" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Update command:" -ForegroundColor Green
        Write-Host "sed -i '' 's/O365_CLIENT_ID=.*/O365_CLIENT_ID=$($app.AppId)/' config/o365-config.env" -ForegroundColor White
        Write-Host ""
        Write-Host "If you need to create a new client secret:" -ForegroundColor Yellow
        Write-Host "1. Go to: https://portal.azure.com" -ForegroundColor White
        Write-Host "2. Navigate to: Azure Active Directory > App registrations" -ForegroundColor White
        Write-Host "3. Find: $($app.DisplayName)" -ForegroundColor White
        Write-Host "4. Go to: Certificates & secrets" -ForegroundColor White
        Write-Host "5. Create new client secret" -ForegroundColor White
    }
}

function Main {
    Write-Log "Starting Azure App Registration search..." "INFO"

    # Install required modules
    if (-not (Install-RequiredModules)) {
        Write-Log "❌ Failed to install required modules" "ERROR"
        return
    }

    # Connect to Azure
    if (-not (Connect-AzureServices)) {
        Write-Log "❌ Failed to connect to Azure services" "ERROR"
        return
    }

    # Find app registrations
    $apps = Find-AppRegistrations -SearchTerm $AppName

    # Show configuration help
    Show-ConfigurationHelp -Apps $apps

    Write-Log "App registration search completed" "SUCCESS"
}

# Run the main function
Main
