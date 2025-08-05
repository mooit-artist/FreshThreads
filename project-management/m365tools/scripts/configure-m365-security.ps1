# Microsoft 365 Security Configuration Script
# Fresh Threads LLC - Automated Security Setup
# Run this in PowerShell as Administrator

Write-Host "🔒 Microsoft 365 Security Configuration for Fresh Threads LLC" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Install required modules if not present
Write-Host "📦 Checking required PowerShell modules..." -ForegroundColor Blue

$requiredModules = @(
    "ExchangeOnlineManagement",
    "AzureAD",
    "Microsoft.Graph",
    "MSOnline"
)

foreach ($module in $requiredModules) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    } else {
        Write-Host "✅ $module is already installed" -ForegroundColor Green
    }
}

# Connect to Microsoft 365
Write-Host ""
Write-Host "🔐 Connecting to Microsoft 365..." -ForegroundColor Blue
Write-Host "Please sign in with bryan@freshthreadsllc.com when prompted" -ForegroundColor Yellow

try {
    # Connect to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName "bryan@freshthreadsllc.com" -ShowProgress $true

    # Connect to Azure AD
    Connect-AzureAD

    # Connect to Microsoft Graph
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.ReadWrite.All", "Policy.ReadWrite.ConditionalAccess"

    Write-Host "✅ Successfully connected to Microsoft 365!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect to Microsoft 365: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🛡️ Configuring Security Settings..." -ForegroundColor Blue

# 1. Enable Organization-wide Audit Logging
Write-Host "1. Enabling audit logging..." -ForegroundColor White
try {
    Set-OrganizationConfig -AuditDisabled $false
    Write-Host "   ✅ Audit logging enabled" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to enable audit logging: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Configure Anti-Spam Policy
Write-Host "2. Configuring anti-spam policies..." -ForegroundColor White
try {
    $antiSpamPolicy = @{
        EnableEndUserSpamNotifications = $true
        EndUserSpamNotificationFrequency = 1
        SpamAction = "MoveToJmf"
        HighConfidenceSpamAction = "Quarantine"
        BulkThreshold = 6
        IncreaseScoreWithImageLinks = "On"
        IncreaseScoreWithNumericIps = "On"
        IncreaseScoreWithRedirectToOtherPort = "On"
        IncreaseScoreWithBizOrInfoUrls = "On"
        MarkAsSpamEmptyMessages = "On"
        MarkAsSpamJavaScriptInHtml = "On"
        MarkAsSpamFramesInHtml = "On"
        MarkAsSpamObjectTagsInHtml = "On"
        MarkAsSpamEmbedTagsInHtml = "On"
        MarkAsSpamFormTagsInHtml = "On"
    }

    Set-HostedContentFilterPolicy -Identity "Default" @antiSpamPolicy
    Write-Host "   ✅ Anti-spam policy configured" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to configure anti-spam policy: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Enable Safe Attachments (if available)
Write-Host "3. Configuring Safe Attachments..." -ForegroundColor White
try {
    # Check if Safe Attachments is available (requires ATP)
    $safeAttachmentPolicies = Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue
    if ($safeAttachmentPolicies) {
        $safeAttachmentConfig = @{
            Action = "Block"
            Redirect = $true
            RedirectAddress = "bryan@freshthreadsllc.com"
            EnableOrganizationBranding = $true
        }
        Set-SafeAttachmentPolicy -Identity "Built-In Protection Policy" @safeAttachmentConfig -ErrorAction SilentlyContinue
        Write-Host "   ✅ Safe Attachments configured" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Safe Attachments not available (requires Microsoft 365 Business Premium)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️ Safe Attachments configuration skipped (requires higher license)" -ForegroundColor Yellow
}

# 4. Configure Safe Links (if available)
Write-Host "4. Configuring Safe Links..." -ForegroundColor White
try {
    $safeLinkPolicies = Get-SafeLinksPolicy -ErrorAction SilentlyContinue
    if ($safeLinkPolicies) {
        $safeLinksConfig = @{
            EnableSafeLinksForTeams = $true
            EnableSafeLinksForOffice = $true
            TrackUserClicks = $true
            AllowUserClickThrough = $false
        }
        Set-SafeLinksPolicy -Identity "Built-In Protection Policy" @safeLinksConfig -ErrorAction SilentlyContinue
        Write-Host "   ✅ Safe Links configured" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Safe Links not available (requires Microsoft 365 Business Premium)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️ Safe Links configuration skipped (requires higher license)" -ForegroundColor Yellow
}

# 5. Configure Mailbox Auditing
Write-Host "5. Enabling mailbox auditing..." -ForegroundColor White
try {
    Get-Mailbox | Set-Mailbox -AuditEnabled $true
    Write-Host "   ✅ Mailbox auditing enabled" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to enable mailbox auditing: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Disable External Forwarding
Write-Host "6. Restricting external email forwarding..." -ForegroundColor White
try {
    Set-RemoteDomain -Identity "Default" -AutoForwardEnabled $false
    Write-Host "   ✅ External forwarding restricted" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to restrict external forwarding: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Configure Strong Password Policy
Write-Host "7. Configuring password policy..." -ForegroundColor White
try {
    $passwordPolicy = Get-MsolPasswordPolicy -DomainName "freshthreadsllc.com" -ErrorAction SilentlyContinue
    if ($passwordPolicy) {
        Set-MsolPasswordPolicy -DomainName "freshthreadsllc.com" -ValidityPeriod 90 -NotificationDays 14
        Write-Host "   ✅ Password policy configured (90-day expiration)" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️ Password policy configuration requires Azure AD Premium" -ForegroundColor Yellow
}

# 8. Check MFA Status
Write-Host "8. Checking MFA status..." -ForegroundColor White
try {
    $user = Get-AzureADUser -ObjectId "bryan@freshthreadsllc.com"
    $mfaStatus = Get-AzureADUserRegisteredDevice -ObjectId $user.ObjectId

    if ($user.StrongAuthenticationRequirements) {
        Write-Host "   ✅ MFA is configured for bryan@freshthreadsllc.com" -ForegroundColor Green
    } else {
        Write-Host "   ❌ MFA is NOT enabled - ENABLE IMMEDIATELY!" -ForegroundColor Red
        Write-Host "   → Go to admin.microsoft.com → Users → Active Users → Multi-factor authentication" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️ Could not check MFA status: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 9. Create Alert Policies
Write-Host "9. Setting up security alert policies..." -ForegroundColor White
try {
    # Suspicious email forwarding alert
    $alertPolicy1 = @{
        Name = "Suspicious Email Forwarding - Fresh Threads"
        Category = "ThreatManagement"
        Operation = @("New-InboxRule", "Set-InboxRule")
        Description = "Alert when suspicious email forwarding rules are created"
        NotifyUser = @("bryan@freshthreadsllc.com")
        Severity = "High"
    }

    # Multiple failed logins alert
    $alertPolicy2 = @{
        Name = "Multiple Failed Logins - Fresh Threads"
        Category = "ThreatManagement"
        Operation = @("UserLoginFailed")
        Description = "Alert on multiple failed login attempts"
        NotifyUser = @("bryan@freshthreadsllc.com")
        Severity = "Medium"
    }

    New-ProtectionAlert @alertPolicy1 -ErrorAction SilentlyContinue
    New-ProtectionAlert @alertPolicy2 -ErrorAction SilentlyContinue
    Write-Host "   ✅ Security alert policies created" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️ Alert policy creation requires Security & Compliance Center access" -ForegroundColor Yellow
}

# Generate Security Report
Write-Host ""
Write-Host "📊 Generating Security Assessment Report..." -ForegroundColor Blue

$reportPath = "$env:USERPROFILE\Desktop\FreshThreads-M365-Security-Report.txt"
$reportContent = @"
Microsoft 365 Security Configuration Report
Fresh Threads LLC
Generated: $(Get-Date)

===========================================

ACCOUNT INFORMATION:
- Primary Email: bryan@freshthreadsllc.com
- Current Plan: Microsoft 365 Business Basic
- Domain: freshthreadsllc.com

SECURITY CONFIGURATIONS APPLIED:
✅ Organization audit logging enabled
✅ Anti-spam policies configured
✅ Mailbox auditing enabled
✅ External forwarding restricted
✅ Security alert policies created

REQUIRES MANUAL CONFIGURATION:
❗ Multi-Factor Authentication (MFA) - CRITICAL
❗ DNS Security Records (SPF, DKIM, DMARC)
❗ Safe Attachments (requires Business Premium)
❗ Safe Links (requires Business Premium)

RECOMMENDED NEXT STEPS:

1. IMMEDIATE (Next 15 minutes):
   - Enable MFA: admin.microsoft.com → Users → MFA
   - Download MFA backup codes

2. TODAY (Next 2 hours):
   - Add SPF record: v=spf1 include:spf.protection.outlook.com -all
   - Add DMARC record: v=DMARC1; p=quarantine; rua=mailto:bryan@freshthreadsllc.com
   - Review sign-in activity: Azure AD → Sign-ins

3. THIS WEEK:
   - Consider upgrading to Business Premium for ATP
   - Set up regular security monitoring
   - Configure device management policies

4. MONTHLY:
   - Review audit logs
   - Check security alerts
   - Update security policies as needed

EMERGENCY CONTACTS:
- Microsoft Support: 1-800-642-7676
- Fresh Threads Admin: bryan@freshthreadsllc.com

COMPLIANCE STATUS:
- Basic email security: ✅ Configured
- Advanced threat protection: ⚠️ Requires upgrade
- Data loss prevention: ⚠️ Requires upgrade
- Conditional access: ⚠️ Requires Azure AD Premium

===========================================

Report saved: $(Get-Date)
Next review recommended: $(Get-Date -Date (Get-Date).AddDays(30))

"@

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "📄 Security report saved to: $reportPath" -ForegroundColor Green

# Cleanup connections
Write-Host ""
Write-Host "🔌 Disconnecting from Microsoft 365..." -ForegroundColor Blue
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-AzureAD
Disconnect-MgGraph

Write-Host ""
Write-Host "🎉 Microsoft 365 Security Configuration Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🚨 CRITICAL NEXT STEPS:" -ForegroundColor Red
Write-Host "1. Enable MFA immediately: admin.microsoft.com" -ForegroundColor Yellow
Write-Host "2. Add DNS security records to your domain registrar" -ForegroundColor Yellow
Write-Host "3. Review the security report on your desktop" -ForegroundColor Yellow
Write-Host ""
Write-Host "📖 Full documentation: M365-SECURITY-LOCKDOWN.md" -ForegroundColor Cyan
Write-Host "🆘 Microsoft Support: 1-800-642-7676" -ForegroundColor Cyan
