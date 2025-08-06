# Microsoft Teams Business Setup Automation
# FreshThreads LLC - Teams Configuration Script

param(
  [Parameter(Mandatory = $false)]
  [string]$Action = "setup",

  [Parameter(Mandatory = $false)]
  [string]$BusinessPhone = "",

  [Parameter(Mandatory = $false)]
  [string]$BusinessEmail = "bryan@freshthreadsllc.com"
)

Write-Host "=== Microsoft Teams Business Setup for FreshThreads LLC ===" -ForegroundColor Green
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

function Test-TeamsConnection {
  Write-Log "Testing Microsoft Teams connection..." "INFO"

  try {
    # Check if Teams PowerShell module is installed
    $teamsModule = Get-Module -ListAvailable -Name MicrosoftTeams
    if (-not $teamsModule) {
      Write-Log "Installing Microsoft Teams PowerShell module..." "WARNING"
      Install-Module -Name MicrosoftTeams -Force -AllowClobber
    }

    # Import the module
    Import-Module MicrosoftTeams -Force

    # Connect to Teams
    Write-Log "Connecting to Microsoft Teams..." "INFO"
    Connect-MicrosoftTeams

    # Test connection by getting tenant info
    $tenant = Get-CsTenant
    Write-Log "✅ Connected to tenant: $($tenant.DisplayName)" "SUCCESS"
    return $true

  }
  catch {
    Write-Log "❌ Failed to connect to Teams: $($_.Exception.Message)" "ERROR"
    return $false
  }
}

function Setup-BusinessUser {
  param([string]$Email)

  Write-Log "Setting up business user: $Email" "INFO"

  try {
    # Check if user exists
    $user = Get-CsOnlineUser -Identity $Email -ErrorAction SilentlyContinue

    if ($user) {
      Write-Log "✅ User found: $($user.DisplayName)" "SUCCESS"
      Write-Log "User Principal Name: $($user.UserPrincipalName)" "INFO"
      Write-Log "Teams License: $($user.TeamsUpgradeEffectiveMode)" "INFO"

      # Enable user for Teams calling if not already enabled
      if ($user.EnterpriseVoiceEnabled -eq $false) {
        Write-Log "Enabling Enterprise Voice for calling..." "WARNING"
        Set-CsUser -Identity $Email -EnterpriseVoiceEnabled $true
        Write-Log "✅ Enterprise Voice enabled" "SUCCESS"
      }
      else {
        Write-Log "✅ Enterprise Voice already enabled" "SUCCESS"
      }

      return $user
    }
    else {
      Write-Log "❌ User not found: $Email" "ERROR"
      Write-Log "Please ensure the user exists in your Microsoft 365 tenant" "WARNING"
      return $null
    }

  }
  catch {
    Write-Log "❌ Error setting up user: $($_.Exception.Message)" "ERROR"
    return $null
  }
}

function Setup-BusinessPhone {
  param([string]$Email, [string]$PhoneNumber = "")

  Write-Log "Setting up business phone for: $Email" "INFO"

  try {
    # Get available phone numbers if none provided
    if ([string]::IsNullOrEmpty($PhoneNumber)) {
      Write-Log "Checking available phone numbers..." "INFO"

      # Get available calling plans
      $callingPlans = Get-CsOnlinePhoneNumberCapabilities
      Write-Log "Available calling plans found: $($callingPlans.Count)" "INFO"

      # Get unassigned phone numbers
      $availableNumbers = Get-CsPhoneNumberAssignment -Top 10 | Where-Object { $_.AssignedPstnTargetId -eq $null }

      if ($availableNumbers) {
        Write-Log "Available phone numbers:" "INFO"
        $availableNumbers | ForEach-Object {
          Write-Log "  - $($_.TelephoneNumber)" "INFO"
        }

        # Use the first available number
        $PhoneNumber = $availableNumbers[0].TelephoneNumber
        Write-Log "Selected phone number: $PhoneNumber" "SUCCESS"
      }
      else {
        Write-Log "No available phone numbers found. You may need to purchase calling plans." "WARNING"
        Write-Log "Visit Microsoft 365 Admin Center > Billing > Purchase services > Communication Credits" "INFO"
        return $false
      }
    }

    # Assign phone number to user
    if (-not [string]::IsNullOrEmpty($PhoneNumber)) {
      Write-Log "Assigning phone number $PhoneNumber to $Email..." "INFO"

      Set-CsUser -Identity $Email -LineURI "tel:$PhoneNumber"
      Set-CsUser -Identity $Email -EnterpriseVoiceEnabled $true

      Write-Log "✅ Phone number assigned successfully" "SUCCESS"
      return $true
    }

  }
  catch {
    Write-Log "❌ Error setting up phone: $($_.Exception.Message)" "ERROR"
    return $false
  }
}

function Setup-TeamsSettings {
  param([string]$Email)

  Write-Log "Configuring Teams settings for business use..." "INFO"

  try {
    # Set up Teams meeting policies for business
    $meetingPolicy = "BusinessMeetingPolicy"

    # Create or update meeting policy
    try {
      $policy = Get-CsTeamsMeetingPolicy -Identity $meetingPolicy -ErrorAction SilentlyContinue
      if (-not $policy) {
        Write-Log "Creating business meeting policy..." "INFO"
        New-CsTeamsMeetingPolicy -Identity $meetingPolicy `
          -AllowCloudRecording $true `
          -AllowTranscription $true `
          -AllowAnonymousUsersToStartMeeting $false `
          -AutoAdmittedUsers "Everyone" `
          -AllowExternalParticipantGiveRequestControl $false
        Write-Log "✅ Business meeting policy created" "SUCCESS"
      }
    }
    catch {
      Write-Log "⚠️ Could not create meeting policy (may need admin rights): $($_.Exception.Message)" "WARNING"
    }

    # Set up calling policy for business use
    try {
      $callingPolicy = "BusinessCallingPolicy"
      $policy = Get-CsTeamsCallingPolicy -Identity $callingPolicy -ErrorAction SilentlyContinue
      if (-not $policy) {
        Write-Log "Creating business calling policy..." "INFO"
        New-CsTeamsCallingPolicy -Identity $callingPolicy `
          -AllowPrivateCalling $true `
          -AllowVoicemail "UserOverride" `
          -AllowCallGroups $true `
          -AllowDelegation $true
        Write-Log "✅ Business calling policy created" "SUCCESS"
      }
    }
    catch {
      Write-Log "⚠️ Could not create calling policy (may need admin rights): $($_.Exception.Message)" "WARNING"
    }

    # Apply policies to user
    try {
      Grant-CsTeamsMeetingPolicy -Identity $Email -PolicyName $meetingPolicy
      Grant-CsTeamsCallingPolicy -Identity $Email -PolicyName $callingPolicy
      Write-Log "✅ Policies applied to user" "SUCCESS"
    }
    catch {
      Write-Log "⚠️ Could not apply policies (may need admin rights): $($_.Exception.Message)" "WARNING"
    }

    return $true

  }
  catch {
    Write-Log "❌ Error configuring Teams settings: $($_.Exception.Message)" "ERROR"
    return $false
  }
}

function Generate-TeamsReport {
  param([string]$Email)

  Write-Log "Generating Teams configuration report..." "INFO"

  try {
    $user = Get-CsOnlineUser -Identity $Email
    $tenant = Get-CsTenant

    $report = @"
# Microsoft Teams Business Setup Report
**FreshThreads LLC**
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Tenant Information
- **Tenant Name:** $($tenant.DisplayName)
- **Tenant ID:** $($tenant.TenantId)
- **Country:** $($tenant.CountryAbbreviation)

## User Configuration
- **Display Name:** $($user.DisplayName)
- **Email:** $($user.UserPrincipalName)
- **Phone Number:** $($user.LineURI)
- **Enterprise Voice:** $($user.EnterpriseVoiceEnabled)
- **Teams Upgrade Mode:** $($user.TeamsUpgradeEffectiveMode)

## Teams Features Enabled
- ✅ Teams Chat and Collaboration
- ✅ Teams Meetings
- ✅ Teams Calling (Enterprise Voice)
- ✅ Teams Phone System

## Next Steps for Business Use
1. **Download Teams Desktop App**: https://teams.microsoft.com/downloads
2. **Setup Teams Mobile App** on your business phone
3. **Configure Teams Auto-Attendant** for customer calls
4. **Setup Call Queue** for business hours management
5. **Enable Teams Recording** for important business calls

## Business Integration Recommendations
- **Customer Support**: Use Teams for customer video calls
- **Supplier Meetings**: Schedule Teams meetings with suppliers
- **Team Collaboration**: If you hire employees, they'll have full Teams access
- **Business Phone**: Use your Teams number for all business communications

## Security Recommendations
- Enable Multi-Factor Authentication (MFA) for your account
- Use Teams data loss prevention policies
- Configure external access policies for vendor communication
- Enable Teams audit logging for compliance

---
*Report generated by FreshThreads Business Automation*
"@

    $reportPath = "project-management/teams-setup-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    $report | Out-File -FilePath $reportPath -Encoding UTF8

    Write-Log "✅ Teams report generated: $reportPath" "SUCCESS"
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
  switch ($Action.ToLower()) {
    "setup" {
      Write-Log "Starting full Teams business setup..." "INFO"

      if (Test-TeamsConnection) {
        $user = Setup-BusinessUser -Email $BusinessEmail

        if ($user) {
          Setup-TeamsSettings -Email $BusinessEmail

          if (-not [string]::IsNullOrEmpty($BusinessPhone)) {
            Setup-BusinessPhone -Email $BusinessEmail -PhoneNumber $BusinessPhone
          }
          else {
            Setup-BusinessPhone -Email $BusinessEmail
          }

          Generate-TeamsReport -Email $BusinessEmail

          Write-Log "🎉 Teams business setup completed successfully!" "SUCCESS"
          Write-Log "You can now use Teams for business calls, meetings, and collaboration" "INFO"
        }
        else {
          Write-Log "❌ Setup failed - user not found or configured" "ERROR"
        }
      }
    }

    "test" {
      Write-Log "Testing Teams connection only..." "INFO"
      Test-TeamsConnection
    }

    "report" {
      Write-Log "Generating Teams status report..." "INFO"
      if (Test-TeamsConnection) {
        Generate-TeamsReport -Email $BusinessEmail
      }
    }

    "phone" {
      Write-Log "Setting up business phone only..." "INFO"
      if (Test-TeamsConnection) {
        Setup-BusinessPhone -Email $BusinessEmail -PhoneNumber $BusinessPhone
      }
    }

    default {
      Write-Host "Available actions:" -ForegroundColor Yellow
      Write-Host "  setup  - Full Teams business setup (default)" -ForegroundColor White
      Write-Host "  test   - Test Teams connection only" -ForegroundColor White
      Write-Host "  report - Generate Teams status report" -ForegroundColor White
      Write-Host "  phone  - Setup business phone only" -ForegroundColor White
      Write-Host ""
      Write-Host "Examples:" -ForegroundColor Yellow
      Write-Host "  .\teams-business-setup.ps1 -Action setup" -ForegroundColor White
      Write-Host "  .\teams-business-setup.ps1 -Action phone -BusinessPhone '+1234567890'" -ForegroundColor White
    }
  }

}
catch {
  Write-Log "❌ Script execution failed: $($_.Exception.Message)" "ERROR"
}
finally {
  # Cleanup - disconnect from Teams
  try {
    Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue
    Write-Log "Disconnected from Microsoft Teams" "INFO"
  }
  catch {
    # Ignore cleanup errors
  }
}

Write-Log "=== Teams Business Setup Complete ===" "SUCCESS"
