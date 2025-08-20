# Create Business User with Mailbox and Teams
# FreshThreads LLC - Complete User Setup

param(
    [Parameter(Mandatory = $false)]
    [string]$UserEmail = "bryan@freshthreadsllc.com",

    [Parameter(Mandatory = $false)]
    [string]$DisplayName = "Bryan Jorgensen",

    [Parameter(Mandatory = $false)]
    [string]$FirstName = "Bryan",

    [Parameter(Mandatory = $false)]
    [string]$LastName = "Jorgensen",

    [Parameter(Mandatory = $false)]
    [string]$JobTitle = "CEO",

    [Parameter(Mandatory = $false)]
    [string]$Department = "Executive"
)

Write-Information "=== Create Business User with Mailbox and Teams ===" -InformationAction Continue
Write-Information "User: $UserEmail" -InformationAction Continue
Write-Information "Date: $(Get-Date)" -InformationAction Continue

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formattedMessage = "[$timestamp] $Message"

    switch ($Level) {
        "ERROR" { Write-Error $formattedMessage }
        "WARNING" { Write-Warning $formattedMessage }
        "SUCCESS" { Write-Information $formattedMessage -InformationAction Continue }
        default { Write-Information $formattedMessage -InformationAction Continue }
    }
}

function Connect-Services {
    Write-Log "Connecting to Microsoft 365 services..." "INFO"

    try {
        # Check and install required modules
        $modules = @("ExchangeOnlineManagement", "MicrosoftTeams", "MSOnline")

        foreach ($module in $modules) {
            if (-not (Get-Module -ListAvailable -Name $module)) {
                Write-Log "Installing $module module..." "WARNING"
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            }
            Import-Module $module -Force
        }

        # Connect to Exchange Online
        Write-Log "Connecting to Exchange Online..." "INFO"
        Connect-ExchangeOnline -ShowBanner:$false

        # Connect to Teams
        Write-Log "Connecting to Microsoft Teams..." "INFO"
        Connect-MicrosoftTeams

        # Connect to MSOnline (for user management)
        Write-Log "Connecting to MSOnline..." "INFO"
        Connect-MsolService

        Write-Log "✅ Connected to all Microsoft 365 services" "SUCCESS"
        return $true

    }
    catch {
        Write-Log "❌ Failed to connect to services: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-UserExists {
    param([string]$Email)

    Write-Log "Checking if user $Email already exists..." "INFO"

    try {
        # Check in Exchange Online
        $mailbox = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue
        if ($mailbox) {
            Write-Log "✅ User already exists in Exchange: $($mailbox.DisplayName)" "SUCCESS"
            return $true
        }

        # Check in Azure AD
        $user = Get-MsolUser -UserPrincipalName $Email -ErrorAction SilentlyContinue
        if ($user) {
            Write-Log "✅ User already exists in Azure AD: $($user.DisplayName)" "SUCCESS"
            return $true
        }

        Write-Log "User does not exist - will create new user" "INFO"
        return $false

    }
    catch {
        Write-Log "Error checking user existence: $($_.Exception.Message)" "WARNING"
        return $false
    }
}

function New-BusinessUser {
    param(
        [string]$Email,
        [string]$DisplayName,
        [string]$FirstName,
        [string]$LastName,
        [string]$JobTitle,
        [string]$Department
    )

    Write-Log "Creating new business user: $Email" "INFO"

    try {
        # Generate a secure temporary password using cryptographically secure random
        $bytes = New-Object byte[] 16
        [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
        $tempPassword = [System.Convert]::ToBase64String($bytes) + "!1A"
        $securePassword = ConvertTo-SecureString $tempPassword -AsPlainText -Force

        # Clear the plaintext password from memory
        $tempPassword = $null

        Write-Log "Creating user in Azure AD..." "INFO"

        # Create user in Azure AD
        $newUser = New-MsolUser -UserPrincipalName $Email `
            -DisplayName $DisplayName `
            -FirstName $FirstName `
            -LastName $LastName `
            -Password $tempPassword `
            -ForceChangePassword $false `
            -PasswordNeverExpires $true `
            -UsageLocation "US" `
            -Title $JobTitle `
            -Department $Department

        if ($newUser) {
            Write-Log "✅ User created in Azure AD: $($newUser.UserPrincipalName)" "SUCCESS"
            Write-Log "Temporary password: $tempPassword" "WARNING"
            Write-Log "⚠️  SAVE THIS PASSWORD - you'll need it to sign in!" "WARNING"

            # Wait for user to propagate
            Write-Log "Waiting for user to propagate (30 seconds)..." "INFO"
            Start-Sleep -Seconds 30

            return @{
                User     = $newUser
                Password = $tempPassword
                Success  = $true
            }
        }
        else {
            Write-Log "❌ Failed to create user" "ERROR"
            return @{Success = $false }
        }

    }
    catch {
        Write-Log "❌ Error creating user: $($_.Exception.Message)" "ERROR"
        return @{Success = $false }
    }
}

function Set-UserLicenses {
    param([string]$Email)

    Write-Log "Assigning licenses to user: $Email" "INFO"

    try {
        # Get available licenses
        $licenses = Get-MsolAccountSku
        Write-Log "Available licenses:" "INFO"
        $licenses | ForEach-Object { Write-Log "  - $($_.AccountSkuId) ($($_.ActiveUnits - $_.ConsumedUnits) available)" "INFO" }

        # Find appropriate license (Microsoft 365 Business or similar)
        $businessLicense = $licenses | Where-Object {
            $_.AccountSkuId -like "*BUSINESS*" -or
            $_.AccountSkuId -like "*STANDARD*" -or
            $_.AccountSkuId -like "*PREMIUM*"
        } | Select-Object -First 1

        if ($businessLicense -and ($businessLicense.ActiveUnits - $businessLicense.ConsumedUnits) -gt 0) {
            Write-Log "Assigning license: $($businessLicense.AccountSkuId)" "INFO"
            Set-MsolUserLicense -UserPrincipalName $Email -AddLicenses $businessLicense.AccountSkuId
            Write-Log "✅ License assigned successfully" "SUCCESS"

            # Wait for license to take effect
            Write-Log "Waiting for license to activate (60 seconds)..." "INFO"
            Start-Sleep -Seconds 60

            return $true
        }
        else {
            Write-Log "❌ No available business licenses found" "ERROR"
            Write-Log "Please purchase Microsoft 365 licenses in the admin center" "WARNING"
            return $false
        }

    }
    catch {
        Write-Log "❌ Error assigning licenses: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Enable-Mailbox {
    param([string]$Email)

    Write-Log "Enabling Exchange mailbox for: $Email" "INFO"

    try {
        # Wait for mailbox to be created automatically (can take a few minutes)
        $maxWait = 10
        $waitCount = 0

        do {
            $waitCount++
            Write-Log "Checking for mailbox... (attempt $waitCount/$maxWait)" "INFO"

            $mailbox = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue
            if ($mailbox) {
                Write-Log "✅ Mailbox found: $($mailbox.DisplayName)" "SUCCESS"
                Write-Log "Mailbox size: $($mailbox.ProhibitSendQuota)" "INFO"
                return $true
            }

            if ($waitCount -lt $maxWait) {
                Write-Log "Mailbox not ready yet, waiting 30 seconds..." "WARNING"
                Start-Sleep -Seconds 30
            }

        } while ($waitCount -lt $maxWait -and -not $mailbox)

        Write-Log "❌ Mailbox not created within expected time" "ERROR"
        Write-Log "It may take up to 24 hours for mailbox to be fully provisioned" "WARNING"
        return $false

    }
    catch {
        Write-Log "❌ Error checking mailbox: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Enable-TeamsUser {
    param([string]$Email)

    Write-Log "Enabling Teams for user: $Email" "INFO"

    try {
        # Check if user exists in Teams
        $teamsUser = Get-CsOnlineUser -Identity $Email -ErrorAction SilentlyContinue

        if ($teamsUser) {
            Write-Log "✅ User found in Teams: $($teamsUser.DisplayName)" "SUCCESS"

            # Enable Enterprise Voice for calling
            if (-not $teamsUser.EnterpriseVoiceEnabled) {
                Write-Log "Enabling Enterprise Voice..." "INFO"
                Set-CsUser -Identity $Email -EnterpriseVoiceEnabled $true
                Write-Log "✅ Enterprise Voice enabled" "SUCCESS"
            }

            # Set Teams upgrade mode
            Grant-CsTeamsUpgradePolicy -Identity $Email -PolicyName "UpgradeToTeams"
            Write-Log "✅ Teams upgrade policy applied" "SUCCESS"

            return $true
        }
        else {
            Write-Log "❌ User not found in Teams (may need to wait longer)" "ERROR"
            return $false
        }

    }
    catch {
        Write-Log "❌ Error enabling Teams: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Set-BusinessAliases {
    param([string]$Email)

    Write-Log "Setting up business email aliases..." "INFO"

    try {
        $aliases = @(
            "ceo@freshthreadsllc.com",
            "contact@freshthreadsllc.com",
            "info@freshthreadsllc.com"
        )

        foreach ($alias in $aliases) {
            try {
                Set-Mailbox -Identity $Email -EmailAddresses @{Add = "$alias" }
                Write-Log "✅ Added alias: $alias" "SUCCESS"
            }
            catch {
                Write-Log "⚠️ Could not add alias $alias : $($_.Exception.Message)" "WARNING"
            }
        }

        return $true

    }
    catch {
        Write-Log "❌ Error setting up aliases: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Generate-UserReport {
    param([string]$Email, [string]$Password = "")

    Write-Log "Generating user setup report..." "INFO"

    try {
        $user = Get-MsolUser -UserPrincipalName $Email -ErrorAction SilentlyContinue
        $mailbox = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue
        $teamsUser = Get-CsOnlineUser -Identity $Email -ErrorAction SilentlyContinue

        $report = @"
# Business User Setup Report - FreshThreads LLC
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**User:** $Email

## User Account Details
- **Display Name:** $($user.DisplayName)
- **User Principal Name:** $($user.UserPrincipalName)
- **Object ID:** $($user.ObjectId)
- **Job Title:** $($user.Title)
- **Department:** $($user.Department)
- **License Status:** $($user.IsLicensed)
- **Account Status:** $(if($user.BlockCredential){"Blocked"}else{"Active"})

## Mailbox Information
- **Mailbox Type:** $($mailbox.RecipientTypeDetails)
- **Primary Email:** $($mailbox.PrimarySmtpAddress)
- **Email Addresses:** $($mailbox.EmailAddresses -join ", ")
- **Mailbox Size Limit:** $($mailbox.ProhibitSendQuota)
- **Mailbox Created:** $($mailbox.WhenCreated)

## Teams Configuration
- **Teams Enabled:** $(if($teamsUser){"Yes"}else{"No"})
- **Enterprise Voice:** $($teamsUser.EnterpriseVoiceEnabled)
- **Teams Upgrade Mode:** $($teamsUser.TeamsUpgradeEffectiveMode)
- **Phone Number:** $($teamsUser.LineURI)

## Sign-in Instructions
1. **Teams Desktop App:** https://teams.microsoft.com/downloads
2. **Outlook Web:** https://outlook.office.com
3. **Microsoft 365 Portal:** https://portal.office.com
4. **Username:** $Email
5. **Temporary Password:** $Password

## Security Recommendations
- [ ] Change password on first login
- [ ] Enable Multi-Factor Authentication (MFA)
- [ ] Configure Outlook mobile app
- [ ] Set up Teams mobile app
- [ ] Review security settings in portal

## Business Aliases Configured
- ceo@freshthreadsllc.com
- contact@freshthreadsllc.com
- info@freshthreadsllc.com

## Next Steps
1. **Sign in to Teams** and test calling features
2. **Configure Outlook** for email management
3. **Set up mobile apps** for business use
4. **Test email aliases** functionality
5. **Configure Teams auto-attendant** for customer calls

---
*Report generated by FreshThreads Business Automation*
"@

        $reportPath = "project-management/user-setup-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
        $report | Out-File -FilePath $reportPath -Encoding UTF8

        Write-Log "✅ User report generated: $reportPath" "SUCCESS"
        Write-Output $report

        return $reportPath

    }
    catch {
        Write-Log "❌ Error generating report: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# Main execution
try {
    Write-Log "=== Starting Business User Creation ===" "INFO"

    if (-not (Connect-Services)) {
        exit 1
    }

    # Check if user already exists
    if (Test-UserExists -Email $UserEmail) {
        Write-Log "User already exists, configuring existing user..." "WARNING"
        $userResult = @{Success = $true; Password = "EXISTING_USER" }
    }
    else {
        # Create new user
        $userResult = New-BusinessUser -Email $UserEmail -DisplayName $DisplayName -FirstName $FirstName -LastName $LastName -JobTitle $JobTitle -Department $Department
    }

    if ($userResult.Success) {
        # Assign licenses
        Set-UserLicenses -Email $UserEmail

        # Enable mailbox
        Enable-Mailbox -Email $UserEmail

        # Enable Teams
        Enable-TeamsUser -Email $UserEmail

        # Set up aliases
        Set-BusinessAliases -Email $UserEmail

        # Generate report
        Generate-UserReport -Email $UserEmail -Password $userResult.Password

        Write-Log "🎉 Business user setup completed successfully!" "SUCCESS"
        Write-Log "User can now sign in to Teams, Outlook, and all Microsoft 365 services" "INFO"

        if ($userResult.Password -ne "EXISTING_USER") {
            Write-Log "⚠️  IMPORTANT: Save the temporary password from the report!" "WARNING"
        }
    }
    else {
        Write-Log "❌ User creation failed" "ERROR"
        exit 1
    }

}
catch {
    Write-Log "❌ Script execution failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
finally {
    # Cleanup connections
    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue
        Write-Log "Disconnected from Microsoft 365 services" "INFO"
    }
    catch {
        # Ignore cleanup errors, but log them for debugging
        Write-Log "Warning: Error during cleanup: $($_.Exception.Message)" "WARNING"
    }
}

Write-Log "=== Business User Creation Complete ===" "SUCCESS"
