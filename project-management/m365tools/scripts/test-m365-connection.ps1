#!/usr/bin/env pwsh
# Test Microsoft 365 PowerShell Connection
# Fresh Threads LLC - Email Setup Testing

Write-Host "🚀 Fresh Threads LLC - M365 Connection Test" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Gray

# Check PowerShell version
Write-Host "`n✅ PowerShell Version:" -ForegroundColor Cyan
$PSVersionTable.PSVersion

# Check Microsoft Graph module
Write-Host "`n✅ Microsoft Graph Module:" -ForegroundColor Cyan
$graphModule = Get-Module Microsoft.Graph -ListAvailable | Select-Object Name, Version
if ($graphModule) {
    Write-Host "   📦 $($graphModule.Name) v$($graphModule.Version)" -ForegroundColor Green
} else {
    Write-Host "   ❌ Microsoft Graph module not found!" -ForegroundColor Red
    exit 1
}

# Test connection to Microsoft Graph
Write-Host "`n🔐 Testing Microsoft Graph Connection..." -ForegroundColor Yellow
Write-Host "   (This will open a browser for authentication)" -ForegroundColor Gray

try {
    # Connect with minimal permissions first
    Connect-MgGraph -Scopes "User.Read" -NoWelcome

    # Get current user info
    $currentUser = Get-MgContext
    Write-Host "`n✅ Successfully connected to Microsoft Graph!" -ForegroundColor Green
    Write-Host "   🆔 Account: $($currentUser.Account)" -ForegroundColor White
    Write-Host "   🏢 Tenant: $($currentUser.TenantId)" -ForegroundColor White
    Write-Host "   🎯 Scopes: $($currentUser.Scopes -join ', ')" -ForegroundColor White

    # Test getting user profile
    Write-Host "`n📧 Testing email access..." -ForegroundColor Cyan
    $profile = Get-MgUser -UserId $currentUser.Account -ErrorAction SilentlyContinue
    if ($profile) {
        Write-Host "   ✅ Email: $($profile.Mail)" -ForegroundColor Green
        Write-Host "   ✅ Display Name: $($profile.DisplayName)" -ForegroundColor Green
        Write-Host "   ✅ User Principal Name: $($profile.UserPrincipalName)" -ForegroundColor Green
    }

    Write-Host "`n🎉 Connection test successful!" -ForegroundColor Green
    Write-Host "   Ready to create email aliases!" -ForegroundColor Yellow

} catch {
    Write-Host "`n❌ Connection test failed:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n💡 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "   1. Make sure you're signing in with: procurement@freshthreadsllc.com" -ForegroundColor White
    Write-Host "   2. You need admin permissions in your M365 tenant" -ForegroundColor White
    Write-Host "   3. Check your internet connection" -ForegroundColor White
} finally {
    # Disconnect
    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        Write-Host "`n🔓 Disconnected from Microsoft Graph" -ForegroundColor Gray
    } catch {
        # Silent disconnect
    }
}

Write-Host "`n🏁 Test complete!" -ForegroundColor Cyan
