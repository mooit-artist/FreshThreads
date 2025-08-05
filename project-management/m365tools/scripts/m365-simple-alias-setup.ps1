#!/usr/bin/env pwsh
# Fresh Threads LLC - Simple Email Alias Setup
# Routes all aliases to procurement@freshthreadsllc.com for now

Write-Host "🚀 Fresh Threads LLC - Email Alias Setup (Simplified)" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Gray

Write-Host "`n📋 Setting up 22 professional aliases..." -ForegroundColor Cyan
Write-Host "All aliases will route to: procurement@freshthreadsllc.com" -ForegroundColor Yellow
Write-Host "(You can reorganize later in Microsoft 365 Admin Center)" -ForegroundColor Gray

# Connect to Microsoft Graph
try {
    Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome
    Write-Host "`n✅ Connected to Microsoft Graph" -ForegroundColor Green
} catch {
    Write-Host "`n❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Get the procurement user
$procurementUser = Get-MgUser -Filter "mail eq 'procurement@freshthreadsllc.com'" -ErrorAction SilentlyContinue

if (-not $procurementUser) {
    Write-Host "`n❌ procurement@freshthreadsllc.com not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Found target user: $($procurementUser.Mail)" -ForegroundColor Green

# Define all aliases
$allAliases = @(
    "bryan", "info", "support", "orders", "sales", "marketing",
    "billing", "returns", "press", "partnerships", "design",
    "creative", "submissions", "shipping", "quality", "affiliate",
    "admin", "accounting", "legal", "privacy", "security", "inventory"
)

Write-Host "`n🔧 Creating aliases using Exchange Online PowerShell approach..." -ForegroundColor Yellow

# Since Graph API has limitations, let's create a manual setup script
$setupCommands = @()
$setupCommands += "# Connect to Exchange Online"
$setupCommands += "Connect-ExchangeOnline -UserPrincipalName procurement@freshthreadsllc.com"
$setupCommands += ""

foreach ($alias in $allAliases) {
    $aliasEmail = "$alias@freshthreadsllc.com"
    $setupCommands += "# Add alias: $aliasEmail"
    $setupCommands += "Set-Mailbox procurement@freshthreadsllc.com -EmailAddresses @{Add='$aliasEmail'}"
    Write-Host "📧 Prepared: $aliasEmail → procurement@freshthreadsllc.com" -ForegroundColor White
}

$setupCommands += ""
$setupCommands += "# Verify aliases"
$setupCommands += "Get-Mailbox procurement@freshthreadsllc.com | Select-Object EmailAddresses"
$setupCommands += ""
$setupCommands += "# Disconnect"
$setupCommands += "Disconnect-ExchangeOnline"

# Save the setup script
$scriptPath = "./m365tools/scripts/exchange-alias-setup.ps1"
$setupCommands | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host "`n✅ Created Exchange Online setup script: $scriptPath" -ForegroundColor Green

Write-Host "`n📋 TO COMPLETE SETUP:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "1. Install Exchange Online PowerShell:" -ForegroundColor White
Write-Host "   Install-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Run the setup script:" -ForegroundColor White
Write-Host "   pwsh ./m365tools/scripts/exchange-alias-setup.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. OR manually add aliases in Microsoft 365 Admin Center:" -ForegroundColor White
Write-Host "   → admin.microsoft.com → Users → procurement user → Mail tab → Aliases" -ForegroundColor Yellow

Write-Host "`n🎯 RESULT:" -ForegroundColor Cyan
Write-Host "All 22 professional aliases will forward to procurement@freshthreadsllc.com" -ForegroundColor Green
Write-Host "Later you can create bryan@freshthreadsllc.com and redistribute aliases" -ForegroundColor Gray

Disconnect-MgGraph -ErrorAction SilentlyContinue
Write-Host "`n✅ Setup preparation complete!" -ForegroundColor Green
