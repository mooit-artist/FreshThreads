#!/usr/bin/env pwsh
# Grant Admin Consent for Azure App Registration
# Automatically grants consent for required Graph API permissions

param(
    [Parameter(Mandatory=$false)]
    [string]$AppId = "26ac87e1-fbd0-4efc-9465-ae5bbc5cb911"
)

Write-Host "=== Azure App Admin Consent Granter ===" -ForegroundColor Green
Write-Host "App ID: $AppId" -ForegroundColor Yellow
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
        Import-Module Microsoft.Graph.Identity.SignIns -Force

        $scopes = @(
            "Application.ReadWrite.All",
            "Directory.ReadWrite.All",
            "DelegatedPermissionGrant.ReadWrite.All"
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

function Grant-AdminConsent {
    param([string]$ApplicationId)

    Write-Log "Granting admin consent for app: $ApplicationId" "INFO"

    try {
        # Get the application
        $app = Get-MgApplication -Filter "AppId eq '$ApplicationId'"
        if (-not $app) {
            Write-Log "❌ Application not found: $ApplicationId" "ERROR"
            return $false
        }

        Write-Log "Found app: $($app.DisplayName)" "INFO"

        # Get the service principal for the app
        $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$ApplicationId'" -ErrorAction SilentlyContinue

        if (-not $servicePrincipal) {
            Write-Log "Creating service principal..." "INFO"
            $servicePrincipal = New-MgServicePrincipal -AppId $ApplicationId
        }

        Write-Log "Service Principal ID: $($servicePrincipal.Id)" "INFO"

        # Get Microsoft Graph service principal
        $graphServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq 'Microsoft Graph'"

        if (-not $graphServicePrincipal) {
            Write-Log "❌ Microsoft Graph service principal not found" "ERROR"
            return $false
        }

        Write-Log "Microsoft Graph SP ID: $($graphServicePrincipal.Id)" "INFO"

        # Grant consent for application permissions (roles)
        $requiredRoles = @(
            "Mail.Send"  # Application permission for sending emails
        )

        foreach ($roleName in $requiredRoles) {
            Write-Log "Granting consent for role: $roleName" "INFO"

            # Find the role in Graph service principal
            $role = $graphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $roleName }

            if ($role) {
                try {
                    # Check if consent already exists
                    $existingGrant = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $servicePrincipal.Id | Where-Object { $_.AppRoleId -eq $role.Id }

                    if (-not $existingGrant) {
                        $appRoleAssignment = @{
                            PrincipalId = $servicePrincipal.Id
                            ResourceId = $graphServicePrincipal.Id
                            AppRoleId = $role.Id
                        }

                        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $servicePrincipal.Id -BodyParameter $appRoleAssignment
                        Write-Log "✅ Granted consent for $roleName" "SUCCESS"
                    } else {
                        Write-Log "✅ Consent already granted for $roleName" "SUCCESS"
                    }
                } catch {
                    Write-Log "❌ Failed to grant consent for $roleName`: $($_.Exception.Message)" "ERROR"
                }
            } else {
                Write-Log "❌ Role not found: $roleName" "ERROR"
            }
        }

        Write-Log "✅ Admin consent process completed" "SUCCESS"
        return $true

    } catch {
        Write-Log "❌ Failed to grant admin consent: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-ConsentStatus {
    param([string]$ApplicationId)

    Write-Log "Checking consent status..." "INFO"

    try {
        $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$ApplicationId'"

        if ($servicePrincipal) {
            $assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $servicePrincipal.Id

            Write-Host ""
            Write-Host "=== Consent Status ===" -ForegroundColor Cyan
            Write-Host "App: $($servicePrincipal.DisplayName)" -ForegroundColor White
            Write-Host "Service Principal ID: $($servicePrincipal.Id)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Granted Permissions:" -ForegroundColor Yellow

            if ($assignments) {
                foreach ($assignment in $assignments) {
                    $resource = Get-MgServicePrincipal -ServicePrincipalId $assignment.ResourceId
                    $role = $resource.AppRoles | Where-Object { $_.Id -eq $assignment.AppRoleId }
                    Write-Host "  ✅ $($resource.DisplayName): $($role.Value)" -ForegroundColor Green
                }
            } else {
                Write-Host "  ❌ No permissions granted" -ForegroundColor Red
            }
        }

    } catch {
        Write-Log "❌ Failed to check consent status: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "Starting admin consent process..." "INFO"

    # Connect to Graph
    $context = Connect-GraphService
    if (-not $context) {
        Write-Log "❌ Failed to connect to Microsoft Graph" "ERROR"
        return
    }

    # Grant admin consent
    $success = Grant-AdminConsent -ApplicationId $AppId

    if ($success) {
        Write-Log "✅ Admin consent granted successfully" "SUCCESS"
    } else {
        Write-Log "❌ Failed to grant admin consent" "ERROR"
    }

    # Show consent status
    Show-ConsentStatus -ApplicationId $AppId

    Write-Host ""
    Write-Host "=== Next Steps ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. 🧪 Test the configuration again:" -ForegroundColor Yellow
    Write-Host "   python scripts/o365_email_handler.py send" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 📧 If still failing, enable SMTP authentication:" -ForegroundColor Yellow
    Write-Host "   - Go to: https://admin.microsoft.com" -ForegroundColor White
    Write-Host "   - Settings > Org settings > Mail" -ForegroundColor White
    Write-Host "   - Enable 'Authenticated SMTP'" -ForegroundColor White
    Write-Host ""

    # Disconnect
    Disconnect-MgGraph -ErrorAction SilentlyContinue

    Write-Log "Admin consent process completed" "SUCCESS"
}

# Run the main function
Main
