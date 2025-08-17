#!/usr/bin/env powershell
# Update SMTP Password in O365 Configuration
# Updates the config file with the generated app password

param(
    [Parameter(Mandatory=$true)]
    [string]$Password,

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "../config/o365-config.env",

    [Parameter(Mandatory=$false)]
    [switch]$TestConnection = $false
)

Write-Host "=== Update SMTP Password ===" -ForegroundColor Green

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

function Update-ConfigFile {
    param(
        [string]$FilePath,
        [string]$AppPassword
    )

    Write-Log "Updating configuration file: $FilePath..." "INFO"

    try {
        if (-not (Test-Path $FilePath)) {
            Write-Log "❌ Configuration file not found: $FilePath" "ERROR"
            return $false
        }

        $content = Get-Content $FilePath

        # Update SMTP password
        $updated = $false
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match "^O365_SMTP_PASSWORD=") {
                $content[$i] = "O365_SMTP_PASSWORD=$AppPassword"
                $updated = $true
                break
            }
        }

        if (-not $updated) {
            Write-Log "❌ Could not find O365_SMTP_PASSWORD in config file" "ERROR"
            return $false
        }

        # Write updated content
        $content | Set-Content $FilePath
        Write-Log "✅ Configuration file updated successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "❌ Failed to update configuration file: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-SMTPConnection {
    param([string]$ConfigPath)

    Write-Log "Testing SMTP connection..." "INFO"

    try {
        # Change to the project directory
        $projectDir = Split-Path (Split-Path $PSScriptRoot)
        Set-Location $projectDir

        # Run the Python test with virtual environment
        Write-Log "Running Python email test..." "INFO"
        if (Test-Path ".venv/bin/python") {
            $result = & .venv/bin/python scripts/o365_email_handler.py send
        } elseif (Test-Path ".venv/Scripts/python.exe") {
            $result = & .venv/Scripts/python.exe scripts/o365_email_handler.py send
        } else {
            $result = & python3 scripts/o365_email_handler.py send
        }        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Email test completed successfully" "SUCCESS"
        } else {
            Write-Log "⚠️  Email test completed with warnings (check output above)" "WARNING"
        }
    } catch {
        Write-Log "❌ Failed to run email test: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "Starting SMTP password update..." "INFO"

    # Resolve config file path
    $configPath = Resolve-Path $ConfigFile -ErrorAction SilentlyContinue
    if (-not $configPath) {
        $configPath = Join-Path $PSScriptRoot $ConfigFile
    }

    Write-Log "Using config file: $configPath" "INFO"

    # Update the configuration file
    if (-not (Update-ConfigFile -FilePath $configPath -AppPassword $Password)) {
        Write-Log "❌ Failed to update configuration" "ERROR"
        return
    }

    # Test connection if requested
    if ($TestConnection) {
        Test-SMTPConnection -ConfigPath $configPath
    }

    Write-Log "SMTP password update completed successfully" "SUCCESS"
    Write-Log "You can now test the email integration with:" "INFO"
    Write-Log "  python scripts/o365_email_handler.py test" "INFO"
    Write-Log "  python scripts/o365_email_handler.py send" "INFO"
}

# Run the main function
Main
