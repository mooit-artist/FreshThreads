#!/usr/bin/env pwsh
# Modern Azure App Registration Finder using Microsoft Graph PowerShell
# Compatible with ARM64 architecture

param(
    [Parameter(Mandatory=$false)]
    [string]$SearchTerm = "FreshThreads",

    [Parameter(Mandatory=$false)]
    [switch]$ListAll = $false
)

Write-Host "=== Modern Azure App Registration Finder ===" -ForegroundColor Green
Write-Host "Searching for: $SearchTerm" -ForegroundColor Yellow
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

function Install-GraphModule {
    Write-Log "Checking Microsoft Graph PowerShell module..." "INFO"

    if (-not (Get-Module -ListAvailable -Name "Microsoft.Graph")) {
        Write-Log "Installing Microsoft.Graph module..." "WARNING"
        try {
            Install-Module -Name Microsoft.Graph -Force -AllowClobber -Scope CurrentUser
            Write-Log "✅ Microsoft.Graph installed successfully" "SUCCESS"
        } catch {
            Write-Log "❌ Failed to install Microsoft.Graph: $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-Log "✅ Microsoft.Graph already installed" "SUCCESS"
    }
    return $true
}

function Connect-GraphService {
    Write-Log "Connecting to Microsoft Graph..." "INFO"

    try {
        # Import the module
        Import-Module Microsoft.Graph.Applications -Force

        # Connect with required scopes
        $scopes = @(
            "Application.Read.All",
            "Directory.Read.All"
        )

        Connect-MgGraph -Scopes $scopes -NoWelcome

        # Get context info
        $context = Get-MgContext
        Write-Log "✅ Connected to Microsoft Graph" "SUCCESS"
        Write-Log "Account: $($context.Account)" "INFO"
        Write-Log "Tenant: $($context.TenantId)" "INFO"

        return $true
    } catch {
        Write-Log "❌ Failed to connect to Microsoft Graph: $($_.Exception.Message)" "ERROR"
        Write-Log "Please ensure you have the required permissions" "WARNING"
        return $false
    }
}

function Find-GraphApplications {
    param([string]$SearchTerm)

    Write-Log "Searching for applications..." "INFO"

    try {
        if ($ListAll) {
            Write-Log "Listing ALL applications..." "INFO"
            $apps = Get-MgApplication -All
        } else {
            Write-Log "Searching for apps containing '$SearchTerm'..." "INFO"
            # Try different search approaches
            $apps = @()

            # Search by display name
            $searchFilter = "startswith(displayName,'$SearchTerm')"
            $foundApps = Get-MgApplication -Filter $searchFilter -ErrorAction SilentlyContinue
            if ($foundApps) { $apps += $foundApps }

            # Search with contains (if startswith didn't work)
            if (-not $apps) {
                $allApps = Get-MgApplication -All
                $apps = $allApps | Where-Object { $_.DisplayName -like "*$SearchTerm*" }
            }
        }

        if ($apps) {
            Write-Log "Found $($apps.Count) application(s)" "SUCCESS"

            foreach ($app in $apps) {
                Write-Host ""
                Write-Host "=== Application Details ===" -ForegroundColor Cyan
                Write-Host "Name: $($app.DisplayName)" -ForegroundColor White
                Write-Host "Application ID (Client ID): $($app.AppId)" -ForegroundColor Green
                Write-Host "Object ID: $($app.Id)" -ForegroundColor Yellow
                Write-Host "Created: $($app.CreatedDateTime)" -ForegroundColor Gray

                # Check for API permissions
                if ($app.RequiredResourceAccess) {
                    Write-Host "API Permissions:" -ForegroundColor Cyan
                    foreach ($resource in $app.RequiredResourceAccess) {
                        # Try to get resource name
                        try {
                            $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$($resource.ResourceAppId)'" -ErrorAction SilentlyContinue
                            $resourceName = if ($servicePrincipal) { $servicePrincipal.DisplayName } else { $resource.ResourceAppId }
                            Write-Host "  - $resourceName" -ForegroundColor White
                        } catch {
                            Write-Host "  - $($resource.ResourceAppId)" -ForegroundColor White
                        }
                    }
                }

                # Check for client secrets
                Write-Host "Client Secrets:" -ForegroundColor Cyan
                if ($app.PasswordCredentials) {
                    foreach ($secret in $app.PasswordCredentials) {
                        $status = if ($secret.EndDateTime -gt (Get-Date)) { "Active" } else { "Expired" }
                        $color = if ($status -eq "Active") { "Green" } else { "Red" }
                        Write-Host "  - Secret ID: $($secret.KeyId) ($status)" -ForegroundColor $color
                        Write-Host "    Expires: $($secret.EndDateTime)" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "  - No client secrets found" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Log "No applications found matching '$SearchTerm'" "WARNING"
            Write-Log "Try running with -ListAll to see all applications" "INFO"
        }

        return $apps
    } catch {
        Write-Log "❌ Failed to search applications: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Show-ConfigurationUpdate {
    param($Apps)

    if ($Apps -and $Apps.Count -gt 0) {
        Write-Host ""
        Write-Host "=== Configuration Update Commands ===" -ForegroundColor Green

        $app = $Apps[0]  # Use the first app found
        $context = Get-MgContext

        Write-Host ""
        Write-Host "Found app: $($app.DisplayName)" -ForegroundColor Yellow
        Write-Host "Client ID: $($app.AppId)" -ForegroundColor Cyan
        Write-Host "Tenant ID: $($context.TenantId)" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "Update your config file:" -ForegroundColor Green
        Write-Host "sed -i '' 's/O365_CLIENT_ID=.*/O365_CLIENT_ID=$($app.AppId)/' config/o365-config.env" -ForegroundColor White
        Write-Host "sed -i '' 's/O365_TENANT_ID=.*/O365_TENANT_ID=$($context.TenantId)/' config/o365-config.env" -ForegroundColor White
        Write-Host ""

        Write-Host "Or manually edit config/o365-config.env:" -ForegroundColor Yellow
        Write-Host "O365_CLIENT_ID=$($app.AppId)" -ForegroundColor Cyan
        Write-Host "O365_TENANT_ID=$($context.TenantId)" -ForegroundColor Cyan
        Write-Host ""

        if (-not $app.PasswordCredentials -or $app.PasswordCredentials.Count -eq 0) {
            Write-Host "⚠️  No client secrets found. You may need to create one:" -ForegroundColor Yellow
            Write-Host "1. Go to: https://portal.azure.com" -ForegroundColor White
            Write-Host "2. Navigate: Azure Active Directory > App registrations" -ForegroundColor White
            Write-Host "3. Find: $($app.DisplayName)" -ForegroundColor White
            Write-Host "4. Go to: Certificates & secrets" -ForegroundColor White
            Write-Host "5. Create new client secret" -ForegroundColor White
        } else {
            $activeSecrets = $app.PasswordCredentials | Where-Object { $_.EndDateTime -gt (Get-Date) }
            if (-not $activeSecrets) {
                Write-Host "⚠️  All client secrets are expired. Create a new one." -ForegroundColor Red
            }
        }
    }
}

function Main {
    Write-Log "Starting Microsoft Graph app search..." "INFO"

    # Install Graph module if needed
    if (-not (Install-GraphModule)) {
        Write-Log "❌ Failed to install Microsoft Graph module" "ERROR"
        return
    }

    # Connect to Graph
    if (-not (Connect-GraphService)) {
        Write-Log "❌ Failed to connect to Microsoft Graph" "ERROR"
        return
    }

    # Find applications
    $apps = Find-GraphApplications -SearchTerm $SearchTerm

    # Show configuration help
    Show-ConfigurationUpdate -Apps $apps

    # Disconnect
    Disconnect-MgGraph -ErrorAction SilentlyContinue

    Write-Log "App search completed" "SUCCESS"
}

# Run the main function
Main
