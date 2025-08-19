# Create Business User with Mailbox and Teams (Microsoft Graph)
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
    [string]$Department = "Executive",

    [Parameter(Mandatory = $false)]
    [string]$Action = "create"
)

Write-Host "=== Create Business User with Mailbox and Teams (Graph API) ===" -ForegroundColor Green
Write-Host "User: $UserEmail" -ForegroundColor Yellow
Write-Host "Action: $Action" -ForegroundColor Yellow
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

function Connect-GraphServices {
    Write-Log "Connecting to Microsoft Graph and services..." "INFO"

    try {
        # Check and install required modules
        $modules = @("Microsoft.Graph", "ExchangeOnlineManagement", "MicrosoftTeams")

        foreach ($module in $modules) {
            if (-not (Get-Module -ListAvailable -Name $module)) {
                Write-Log "Installing $module module..." "WARNING"
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            }
        }

        # Import Microsoft Graph
        Import-Module Microsoft.Graph.Users -Force
        Import-Module Microsoft.Graph.Authentication -Force
        Import-Module Microsoft.Graph.Identity.DirectoryManagement -Force

        # Connect to Microsoft Graph with required scopes
        $requiredScopes = @(
            "User.ReadWrite.All",
            "Directory.ReadWrite.All",
            "Mail.ReadWrite",
            "UserAuthenticationMethod.ReadWrite.All"
        )

        Write-Log "Connecting to Microsoft Graph..." "INFO"
        Connect-MgGraph -Scopes $requiredScopes -NoWelcome

        # Connect to Exchange Online
        Write-Log "Connecting to Exchange Online..." "INFO"
        Import-Module ExchangeOnlineManagement -Force
        Connect-ExchangeOnline -ShowBanner:$false

        # Connect to Teams
        Write-Log "Connecting to Microsoft Teams..." "INFO"
        Import-Module MicrosoftTeams -Force
        Connect-MicrosoftTeams

        Write-Log "✅ Connected to all Microsoft 365 services via Graph API" "SUCCESS"
        return $true

    }
    catch {
        Write-Log "❌ Failed to connect to services: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-GraphUser {
    param([string]$Email)

    Write-Log "Checking if user $Email already exists..." "INFO"

    try {
        # Check using Microsoft Graph
        $user = Get-MgUser -Filter "userPrincipalName eq '$Email'" -ErrorAction SilentlyContinue

        if ($user) {
            Write-Log "✅ User already exists: $($user.DisplayName)" "SUCCESS"
            Write-Log "User ID: $($user.Id)" "INFO"
            Write-Log "Job Title: $($user.JobTitle)" "INFO"
            return $user
        }

        Write-Log "User does not exist - will create new user" "INFO"
        return $null

    }
    catch {
        Write-Log "Error checking user existence: $($_.Exception.Message)" "WARNING"
        return $null
    }
}

function New-GraphBusinessUser {
    param(
        [string]$Email,
        [string]$DisplayName,
        [string]$FirstName,
        [string]$LastName,
        [string]$JobTitle,
        [string]$Department
    )

    Write-Log "Creating new business user via Microsoft Graph: $Email" "INFO"

    try {
        # Generate a secure temporary password
        $tempPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 12 | % { [char]$_ }) + "!A1"

        Write-Log "Creating user in Azure AD via Graph API..." "INFO"

        # Extract domain from email
        $domain = $Email.Split('@')[1]

        # Create user object
        $userParams = @{
            AccountEnabled    = $true
            DisplayName       = $DisplayName
            GivenName         = $FirstName
            Surname           = $LastName
            UserPrincipalName = $Email
            MailNickname      = $Email.Split('@')[0]
            JobTitle          = $JobTitle
            Department        = $Department
            UsageLocation     = "US"
            PasswordProfile   = @{
                ForceChangePasswordNextSignIn = $false
                Password                      = $tempPassword
            }
        }

        # Create the user
        $newUser = New-MgUser -BodyParameter $userParams

        if ($newUser) {
            Write-Log "✅ User created successfully: $($newUser.UserPrincipalName)" "SUCCESS"
            Write-Log "User ID: $($newUser.Id)" "INFO"
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
        Write-Log "Full error: $($_.Exception)" "ERROR"
        return @{Success = $false }
    }
}

function Set-GraphUserLicenses {
    param([string]$UserId)

    Write-Log "Assigning licenses to user: $UserId" "INFO"

    try {
        # Get organization to find available licenses
        $org = Get-MgOrganization
        $subscribedSkus = Get-MgSubscribedSku

        Write-Log "Available licenses:" "INFO"
        $subscribedSkus | ForEach-Object {
            $available = $_.PrepaidUnits.Enabled - $_.ConsumedUnits
            Write-Log "  - $($_.SkuPartNumber): $available available" "INFO"
        }

        # Find appropriate license (Microsoft 365 Business or similar)
        $businessLicense = $subscribedSkus | Where-Object {
            $_.SkuPartNumber -like "*BUSINESS*" -or
            $_.SkuPartNumber -like "*STANDARD*" -or
            $_.SkuPartNumber -like "*PREMIUM*" -or
            $_.SkuPartNumber -like "*ENTERPRISE*"
        } | Where-Object {
            ($_.PrepaidUnits.Enabled - $_.ConsumedUnits) -gt 0
        } | Select-Object -First 1

        if ($businessLicense) {
            Write-Log "Assigning license: $($businessLicense.SkuPartNumber)" "INFO"

            $licenseParams = @{
                AddLicenses    = @(
                    @{
                        SkuId = $businessLicense.SkuId
                    }
                )
                RemoveLicenses = @()
            }

            Set-MgUserLicense -UserId $UserId -BodyParameter $licenseParams
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

function Enable-ExchangeMailbox {
    param([string]$Email)

    Write-Log "Enabling Exchange mailbox for: $Email" "INFO"

    try {
        # Wait for mailbox to be created automatically
        $maxWait = 10
        $waitCount = 0

        do {
            $waitCount++
            Write-Log "Checking for mailbox... (attempt $waitCount/$maxWait)" "INFO"

            $mailbox = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue
            if ($mailbox) {
                Write-Log "✅ Mailbox found: $($mailbox.DisplayName)" "SUCCESS"
                Write-Log "Mailbox type: $($mailbox.RecipientTypeDetails)" "INFO"
                Write-Log "Primary SMTP: $($mailbox.PrimarySmtpAddress)" "INFO"
                return $mailbox
            }

            if ($waitCount -lt $maxWait) {
                Write-Log "Mailbox not ready yet, waiting 30 seconds..." "WARNING"
                Start-Sleep -Seconds 30
            }

        } while ($waitCount -lt $maxWait -and -not $mailbox)

        Write-Log "❌ Mailbox not created within expected time" "ERROR"
        Write-Log "It may take up to 24 hours for mailbox to be fully provisioned" "WARNING"
        return $null

    }
    catch {
        Write-Log "❌ Error checking mailbox: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Enable-TeamsForUser {
    param([string]$Email)

    Write-Log "Enabling Teams for user: $Email" "INFO"

    try {
        # Check if user exists in Teams (may take time to sync)
        $maxWait = 5
        $waitCount = 0

        do {
            $waitCount++
            Write-Log "Checking Teams user... (attempt $waitCount/$maxWait)" "INFO"

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

                return $teamsUser
            }

            if ($waitCount -lt $maxWait) {
                Write-Log "Teams user not ready yet, waiting 60 seconds..." "WARNING"
                Start-Sleep -Seconds 60
            }

        } while ($waitCount -lt $maxWait)

        Write-Log "❌ User not found in Teams (may need more time to sync)" "ERROR"
        Write-Log "Teams features may be available after full propagation" "WARNING"
        return $null

    }
    catch {
        Write-Log "❌ Error enabling Teams: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Set-BusinessEmailAliases {
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

function Generate-BusinessUserReport {
    param([string]$Email, [string]$Password = "", [object]$User = $null)

    Write-Log "Generating comprehensive user setup report..." "INFO"

    try {
        if (-not $User) {
            $User = Get-MgUser -Filter "userPrincipalName eq '$Email'"
        }

        $mailbox = Get-Mailbox -Identity $Email -ErrorAction SilentlyContinue
        $teamsUser = Get-CsOnlineUser -Identity $Email -ErrorAction SilentlyContinue

        $report = @"
# Business User Setup Report - FreshThreads LLC
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**User:** $Email
**Setup Method:** Microsoft Graph API

## ✅ User Account Details
- **Display Name:** $($User.DisplayName)
- **User Principal Name:** $($User.UserPrincipalName)
- **User ID:** $($User.Id)
- **Job Title:** $($User.JobTitle)
- **Department:** $($User.Department)
- **Account Enabled:** $($User.AccountEnabled)
- **Usage Location:** $($User.UsageLocation)

## 📧 Mailbox Information
$(if ($mailbox) {
"- **Mailbox Status:** ✅ Active
- **Mailbox Type:** $($mailbox.RecipientTypeDetails)
- **Primary Email:** $($mailbox.PrimarySmtpAddress)
- **Email Addresses:** $($mailbox.EmailAddresses -join ", ")
- **Mailbox Size Limit:** $($mailbox.ProhibitSendQuota)
- **Created:** $($mailbox.WhenCreated)"
} else {
"- **Mailbox Status:** ⏳ Provisioning (may take up to 24 hours)"
})

## 🎯 Teams Configuration
$(if ($teamsUser) {
"- **Teams Status:** ✅ Enabled
- **Display Name:** $($teamsUser.DisplayName)
- **Enterprise Voice:** $($teamsUser.EnterpriseVoiceEnabled)
- **Teams Upgrade Mode:** $($teamsUser.TeamsUpgradeEffectiveMode)
- **Phone Number:** $($teamsUser.LineURI)"
} else {
"- **Teams Status:** ⏳ Syncing (may take up to 1 hour)"
})

## 🔐 Sign-in Information
- **Username:** $Email
$(if ($Password) {"- **Temporary Password:** $Password"} else {"- **Password:** Use existing password"})
- **Microsoft 365 Portal:** https://portal.office.com
- **Teams Web:** https://teams.microsoft.com
- **Outlook Web:** https://outlook.office.com

## 📱 Download Apps
- **Teams Desktop:** https://teams.microsoft.com/downloads
- **Outlook Mobile:** App Store / Google Play
- **Teams Mobile:** App Store / Google Play
- **Microsoft 365 Mobile:** App Store / Google Play

## 📧 Business Email Aliases
- ceo@freshthreadsllc.com
- contact@freshthreadsllc.com
- info@freshthreadsllc.com

## ✅ Security Checklist
- [ ] Sign in for the first time
- [ ] Enable Multi-Factor Authentication (MFA)
- [ ] Download and configure Teams desktop app
- [ ] Download and configure Outlook mobile app
- [ ] Set up Teams mobile for business calls
- [ ] Test all email aliases
- [ ] Configure auto-attendant for business calls

## 📞 Business Phone Features
Once Teams is fully synced, the user will have:
- Business calling through Teams
- Voicemail integration
- Call forwarding and delegation
- Auto-attendant capabilities
- Conference calling for up to 250 participants

## 🚀 Next Steps
1. **Immediate:** Sign in to https://portal.office.com
2. **Setup Teams:** Download Teams app and test calling
3. **Configure Email:** Set up Outlook for business email
4. **Mobile Setup:** Install Teams and Outlook mobile apps
5. **Test Aliases:** Send test emails to business aliases
6. **Phone System:** Configure Teams phone features

## 🛠️ Support Information
- **Admin Portal:** https://admin.microsoft.com
- **Teams Admin:** https://admin.teams.microsoft.com
- **Exchange Admin:** https://admin.exchange.microsoft.com
- **Support:** contact@freshthreadsllc.com

---
*Report generated by FreshThreads Business Automation System*
*Microsoft Graph API Integration*
"@

        $reportPath = "project-management/user-setup-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
        $report | Out-File -FilePath $reportPath -Encoding UTF8

        Write-Log "✅ User report generated: $reportPath" "SUCCESS"
        Write-Host $report

        return $reportPath

    }
    catch {
        Write-Log "❌ Error generating report: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# Main execution
try {
    Write-Log "=== Starting Business User Creation via Microsoft Graph ===" "INFO"

    if (-not (Connect-GraphServices)) {
        exit 1
    }

    # Check if user already exists
    $existingUser = Test-GraphUser -Email $UserEmail

    if ($existingUser) {
        Write-Log "User already exists, configuring existing user..." "WARNING"
        $userResult = @{
            Success  = $true
            User     = $existingUser
            Password = "EXISTING_USER"
        }
    }
    else {
        # Create new user
        $userResult = New-GraphBusinessUser -Email $UserEmail -DisplayName $DisplayName -FirstName $FirstName -LastName $LastName -JobTitle $JobTitle -Department $Department
    }

    if ($userResult.Success) {
        Write-Log "✅ User account ready, configuring services..." "SUCCESS"

        # Assign licenses if user was just created
        if ($userResult.Password -ne "EXISTING_USER") {
            Set-GraphUserLicenses -UserId $userResult.User.Id
        }

        # Enable mailbox
        $mailbox = Enable-ExchangeMailbox -Email $UserEmail

        # Enable Teams
        $teamsUser = Enable-TeamsForUser -Email $UserEmail

        # Set up aliases (only if mailbox exists)
        if ($mailbox) {
            Set-BusinessEmailAliases -Email $UserEmail
        }

        # Generate comprehensive report
        Generate-BusinessUserReport -Email $UserEmail -Password $userResult.Password -User $userResult.User

        Write-Log "🎉 Business user setup completed successfully!" "SUCCESS"
        Write-Log "✅ Microsoft 365 account: Ready" "SUCCESS"
        Write-Log "$(if($mailbox){"✅"}else{"⏳"}) Exchange mailbox: $(if($mailbox){"Ready"}else{"Provisioning"})" $(if ($mailbox) { "SUCCESS" }else { "WARNING" })
        Write-Log "$(if($teamsUser){"✅"}else{"⏳"}) Teams integration: $(if($teamsUser){"Ready"}else{"Syncing"})" $(if ($teamsUser) { "SUCCESS" }else { "WARNING" })

        if ($userResult.Password -ne "EXISTING_USER") {
            Write-Log "⚠️  IMPORTANT: Save the temporary password from the report above!" "WARNING"
        }

        Write-Log "🚀 User can now sign in to: Teams, Outlook, Microsoft 365 Portal" "INFO"

    }
    else {
        Write-Log "❌ User creation failed" "ERROR"
        exit 1
    }

}
catch {
    Write-Log "❌ Script execution failed: $($_.Exception.Message)" "ERROR"
    Write-Log "Full error: $($_.Exception)" "ERROR"
    exit 1
}
finally {
    # Cleanup connections
    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        Write-Log "Disconnected from Microsoft 365 services" "INFO"
    }
    catch {
        # Ignore cleanup errors
    }
}

Write-Log "=== Business User Creation Complete ===" "SUCCESS"

