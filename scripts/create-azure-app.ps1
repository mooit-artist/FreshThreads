#!/usr/bin/env pwsh
# Create Azure App Registration for FreshThreads O365 Integration
# Automatically sets up the app with required permissions

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName = "FreshThreads O365 Integration",

    [Parameter(Mandatory=$false)]
    [string]$RedirectUri = "http://localhost:8080"
)

Write-Host "=== Azure App Registration Creator ===" -ForegroundColor Green
Write-Host "Creating app: $AppName" -ForegroundColor Yellow
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

function Create-AppRegistration {
    param(
        [string]$AppName,
        [string]$RedirectUri
    )

    Write-Log "Creating app registration: $AppName" "INFO"

    try {
        # Create the application
        $app = New-MgApplication -DisplayName $AppName -SignInAudience "AzureADMyOrg"

        Write-Log "✅ App registration created successfully" "SUCCESS"
        Write-Log "App ID: $($app.AppId)" "INFO"
        Write-Log "Object ID: $($app.Id)" "INFO"

        return $app
    } catch {
        Write-Log "❌ Failed to create app registration: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Add-ApiPermissions {
    param($App)

    Write-Log "Adding Microsoft Graph API permissions..." "INFO"

    try {
        # Microsoft Graph Resource App ID
        $graphResourceId = "00000003-0000-0000-c000-000000000000"

        # Required permissions for sending emails
        $requiredPermissions = @(
            @{
                Id = "b633e1c5-b582-4048-a93e-9f11b44c7e96"  # Mail.Send
                Type = "Role"  # Application permission
            },
            @{
                Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read
                Type = "Scope"  # Delegated permission
            }
        )

        $resourceAccess = @()
        foreach ($permission in $requiredPermissions) {
            $resourceAccess += @{
                Id = $permission.Id
                Type = $permission.Type
            }
        }

        $requiredResourceAccess = @{
            ResourceAppId = $graphResourceId
            ResourceAccess = $resourceAccess
        }

        # Update the application with required permissions
        Update-MgApplication -ApplicationId $App.Id -RequiredResourceAccess @($requiredResourceAccess)

        Write-Log "✅ API permissions added successfully" "SUCCESS"
        Write-Log "Added: Mail.Send (Application)" "INFO"
        Write-Log "Added: User.Read (Delegated)" "INFO"

    } catch {
        Write-Log "❌ Failed to add API permissions: $($_.Exception.Message)" "ERROR"
    }
}

function Create-ClientSecret {
    param($App)

    Write-Log "Creating client secret..." "INFO"

    try {
        $secretName = "FreshThreads O365 Integration Secret"
        $secretExpiry = (Get-Date).AddYears(2)  # 2 year expiry

        $passwordCredential = @{
            DisplayName = $secretName
            EndDateTime = $secretExpiry
        }

        $secret = Add-MgApplicationPassword -ApplicationId $App.Id -PasswordCredential $passwordCredential

        Write-Log "✅ Client secret created successfully" "SUCCESS"
        Write-Log "Secret ID: $($secret.KeyId)" "INFO"
        Write-Log "Expires: $($secret.EndDateTime)" "INFO"
        Write-Log "Secret Value: $($secret.SecretText)" "WARNING"
        Write-Host ""
        Write-Host "⚠️  IMPORTANT: Save this secret value now! You won't be able to see it again." -ForegroundColor Red
        Write-Host "Secret: $($secret.SecretText)" -ForegroundColor Yellow
        Write-Host ""

        return $secret
    } catch {
        Write-Log "❌ Failed to create client secret: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Update-ConfigFile {
    param($App, $Secret, $TenantId)

    Write-Log "Updating configuration file..." "INFO"

    try {
        $configPath = "config/o365-config.env"

        if (Test-Path $configPath) {
            # Read current config
            $content = Get-Content $configPath

            # Update values
            $content = $content -replace "O365_CLIENT_ID=.*", "O365_CLIENT_ID=$($App.AppId)"
            $content = $content -replace "O365_TENANT_ID=.*", "O365_TENANT_ID=$TenantId"
            if ($Secret) {
                $content = $content -replace "O365_CLIENT_SECRET=.*", "O365_CLIENT_SECRET=$($Secret.SecretText)"
            }

            # Write back to file
            $content | Set-Content $configPath

            Write-Log "✅ Configuration file updated successfully" "SUCCESS"
        } else {
            Write-Log "❌ Configuration file not found: $configPath" "ERROR"
        }
    } catch {
        Write-Log "❌ Failed to update configuration file: $($_.Exception.Message)" "ERROR"
    }
}

function Show-Summary {
    param($App, $Secret, $TenantId)

    Write-Host ""
    Write-Host "=== App Registration Summary ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "App Name: $($App.DisplayName)" -ForegroundColor White
    Write-Host "Application ID (Client ID): $($App.AppId)" -ForegroundColor Cyan
    Write-Host "Tenant ID: $TenantId" -ForegroundColor Cyan
    Write-Host "Object ID: $($App.Id)" -ForegroundColor Yellow
    if ($Secret) {
        Write-Host "Client Secret: $($Secret.SecretText)" -ForegroundColor Red
        Write-Host "Secret Expires: $($Secret.EndDateTime)" -ForegroundColor Gray
    }
    Write-Host ""

    Write-Host "=== Next Steps ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. 🔒 Grant admin consent for API permissions:" -ForegroundColor Yellow
    Write-Host "   https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$($App.AppId)" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 🧪 Test the updated configuration:" -ForegroundColor Yellow
    Write-Host "   python scripts/o365_email_handler.py test" -ForegroundColor White
    Write-Host "   python scripts/o365_email_handler.py send" -ForegroundColor White
    Write-Host ""
    Write-Host "3. 📧 If Graph API fails, enable SMTP authentication:" -ForegroundColor Yellow
    Write-Host "   - Go to Microsoft 365 Admin Center" -ForegroundColor White
    Write-Host "   - Settings > Mail > SMTP AUTH" -ForegroundColor White
    Write-Host "   - Enable for your account" -ForegroundColor White
    Write-Host ""
}

function Main {
    Write-Log "Starting Azure App Registration creation..." "INFO"

    # Connect to Graph
    $context = Connect-GraphService
    if (-not $context) {
        Write-Log "❌ Failed to connect to Microsoft Graph" "ERROR"
        return
    }

    # Create app registration
    $app = Create-AppRegistration -AppName $AppName -RedirectUri $RedirectUri
    if (-not $app) {
        Write-Log "❌ Failed to create app registration" "ERROR"
        return
    }

    # Add API permissions
    Add-ApiPermissions -App $app

    # Create client secret
    $secret = Create-ClientSecret -App $app

    # Update config file
    Update-ConfigFile -App $app -Secret $secret -TenantId $context.TenantId

    # Show summary
    Show-Summary -App $app -Secret $secret -TenantId $context.TenantId

    # Disconnect
    Disconnect-MgGraph -ErrorAction SilentlyContinue

    Write-Log "App registration creation completed" "SUCCESS"
}

# Run the main function
Main
