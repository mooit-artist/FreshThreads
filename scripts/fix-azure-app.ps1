#!/usr/bin/env pwsh
# Fix Azure App Registration - Add Redirect URI
# Fixes AADSTS500113: No reply address is registered for the application

param(
    [Parameter(Mandatory=$false)]
    [string]$AppId = "26ac87e1-fbd0-4efc-9465-ae5bbc5cb911",

    [Parameter(Mandatory=$false)]
    [string]$RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
)

Write-Host "=== Fix Azure App Registration ===" -ForegroundColor Green
Write-Host "App ID: $AppId" -ForegroundColor Yellow
Write-Host "Adding Redirect URI: $RedirectUri" -ForegroundColor Yellow
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

function Connect-GraphService {
    Write-Log "Connecting to Microsoft Graph..." "INFO"

    try {
        Import-Module Microsoft.Graph.Applications -Force

        $scopes = @(
            "Application.ReadWrite.All",
            "Directory.ReadWrite.All"
        )

        Connect-MgGraph -Scopes $scopes -NoWelcome

        $context = Get-MgContext
        Write-Log "✅ Connected to Microsoft Graph" "SUCCESS"
        Write-Log "Account: $($context.Account)" "INFO"
        Write-Log "Tenant: $($context.TenantId)" "INFO"

        return $context
    } catch {
        Write-Log "❌ Failed to connect to Microsoft Graph: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Add-RedirectUri {
    param(
        [string]$ApplicationId,
        [string]$RedirectUri
    )

    Write-Log "Adding redirect URI to app registration..." "INFO"

    try {
        # Get the application
        $app = Get-MgApplication -Filter "AppId eq '$ApplicationId'"
        if (-not $app) {
            Write-Log "❌ Application not found: $ApplicationId" "ERROR"
            return $false
        }

        Write-Log "Found app: $($app.DisplayName)" "INFO"
        Write-Log "Current redirect URIs:" "INFO"

        # Show current redirect URIs
        if ($app.PublicClient -and $app.PublicClient.RedirectUris) {
            foreach ($uri in $app.PublicClient.RedirectUris) {
                Write-Log "  - $uri" "INFO"
            }
        } else {
            Write-Log "  - No redirect URIs configured" "WARNING"
        }

        # Prepare redirect URIs list
        $redirectUris = @()
        if ($app.PublicClient -and $app.PublicClient.RedirectUris) {
            $redirectUris = $app.PublicClient.RedirectUris
        }

        # Add new redirect URI if not already present
        if ($redirectUris -notcontains $RedirectUri) {
            $redirectUris += $RedirectUri
            Write-Log "Adding new redirect URI: $RedirectUri" "INFO"
        } else {
            Write-Log "Redirect URI already exists: $RedirectUri" "INFO"
            return $true
        }

        # Also add web redirect URIs for admin consent
        $webRedirectUris = @()
        if ($app.Web -and $app.Web.RedirectUris) {
            $webRedirectUris = $app.Web.RedirectUris
        }

        # Common admin consent redirect URIs
        $adminConsentUris = @(
            "https://login.microsoftonline.com/common/adminconsent",
            "urn:ietf:wg:oauth:2.0:oob"
        )

        foreach ($uri in $adminConsentUris) {
            if ($webRedirectUris -notcontains $uri) {
                $webRedirectUris += $uri
                Write-Log "Adding web redirect URI: $uri" "INFO"
            }
        }

        # Update the application
        $updateParams = @{
            ApplicationId = $app.Id
            PublicClient = @{
                RedirectUris = $redirectUris
            }
            Web = @{
                RedirectUris = $webRedirectUris
            }
        }

        Update-MgApplication @updateParams

        Write-Log "✅ Application updated successfully" "SUCCESS"

        # Verify the update
        Start-Sleep -Seconds 2
        $updatedApp = Get-MgApplication -ApplicationId $app.Id

        Write-Log "Updated redirect URIs:" "SUCCESS"
        if ($updatedApp.PublicClient -and $updatedApp.PublicClient.RedirectUris) {
            foreach ($uri in $updatedApp.PublicClient.RedirectUris) {
                Write-Log "  Public Client: $uri" "SUCCESS"
            }
        }
        if ($updatedApp.Web -and $updatedApp.Web.RedirectUris) {
            foreach ($uri in $updatedApp.Web.RedirectUris) {
                Write-Log "  Web: $uri" "SUCCESS"
            }
        }

        return $true

    } catch {
        Write-Log "❌ Failed to add redirect URI: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-NewConsentUrl {
    param([string]$ApplicationId, [string]$TenantId)

    Write-Host ""
    Write-Host "=== Updated Admin Consent URL ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now try this admin consent link:" -ForegroundColor Yellow
    Write-Host "https://login.microsoftonline.com/$TenantId/adminconsent?client_id=$ApplicationId" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Alternative URLs to try:" -ForegroundColor Yellow
    Write-Host "https://login.microsoftonline.com/common/adminconsent?client_id=$ApplicationId" -ForegroundColor White
    Write-Host "https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$ApplicationId" -ForegroundColor White
    Write-Host ""
}

function Main {
    Write-Log "Starting Azure App Registration fix..." "INFO"

    # Connect to Graph
    $context = Connect-GraphService
    if (-not $context) {
        Write-Log "❌ Failed to connect to Microsoft Graph" "ERROR"
        return
    }

    # Add redirect URI
    $success = Add-RedirectUri -ApplicationId $AppId -RedirectUri $RedirectUri

    if ($success) {
        Write-Log "✅ App registration fixed successfully" "SUCCESS"
        Show-NewConsentUrl -ApplicationId $AppId -TenantId $context.TenantId
    } else {
        Write-Log "❌ Failed to fix app registration" "ERROR"
    }

    Write-Host ""
    Write-Host "=== Next Steps ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. 🔒 Try the admin consent link above" -ForegroundColor Yellow
    Write-Host "2. 🧪 After consent, test email:" -ForegroundColor Yellow
    Write-Host "   python scripts/o365_email_handler.py send" -ForegroundColor White
    Write-Host ""

    # Disconnect
    Disconnect-MgGraph -ErrorAction SilentlyContinue

    Write-Log "App registration fix completed" "SUCCESS"
}

# Run the main function
Main
