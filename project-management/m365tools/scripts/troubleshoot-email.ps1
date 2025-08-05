#!/usr/bin/env pwsh
# Fresh Threads LLC - Email Troubleshooting Script

Write-Host "🔍 Fresh Threads LLC - Email System Troubleshooting" -ForegroundColor Yellow
Write-Host "===================================================" -ForegroundColor Gray

Write-Host "`n📧 Checking email system status..." -ForegroundColor Cyan

try {
    Connect-ExchangeOnline -UserPrincipalName procurement@freshthreadsllc.com

    Write-Host "`n✅ Connected to Exchange Online" -ForegroundColor Green

    # Check mailbox details
    $mailbox = Get-Mailbox procurement@freshthreadsllc.com
    Write-Host "`n📬 Mailbox Status:" -ForegroundColor Cyan
    Write-Host "   Primary Email: $($mailbox.PrimarySmtpAddress)" -ForegroundColor White
    Write-Host "   Display Name: $($mailbox.DisplayName)" -ForegroundColor White
    Write-Host "   Mailbox Type: $($mailbox.RecipientTypeDetails)" -ForegroundColor White

    # Check message trace for recent emails
    Write-Host "`n🔍 Checking for recent emails (last 2 hours)..." -ForegroundColor Cyan
    $startDate = (Get-Date).AddHours(-2)
    $endDate = Get-Date

    $messages = Get-MessageTrace -RecipientAddress procurement@freshthreadsllc.com -StartDate $startDate -EndDate $endDate

    if ($messages) {
        Write-Host "   ✅ Found $($messages.Count) recent message(s):" -ForegroundColor Green
        foreach ($msg in $messages) {
            Write-Host "   📧 From: $($msg.SenderAddress)" -ForegroundColor White
            Write-Host "      To: $($msg.RecipientAddress)" -ForegroundColor White
            Write-Host "      Subject: $($msg.Subject)" -ForegroundColor White
            Write-Host "      Status: $($msg.Status)" -ForegroundColor White
            Write-Host "      Time: $($msg.Received)" -ForegroundColor Gray
            Write-Host "" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ⚠️  No messages found in the last 2 hours" -ForegroundColor Yellow
    }

    # Check mail flow rules
    Write-Host "`n📋 Checking mail flow rules..." -ForegroundColor Cyan
    $rules = Get-TransportRule
    if ($rules) {
        Write-Host "   📌 Found $($rules.Count) mail flow rule(s)" -ForegroundColor White
        foreach ($rule in $rules) {
            if ($rule.State -eq "Enabled") {
                Write-Host "   ✅ $($rule.Name) - Enabled" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  $($rule.Name) - Disabled" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "   ✅ No mail flow rules (this is normal)" -ForegroundColor Green
    }

    # Check if mailbox is receiving mail
    Write-Host "`n📥 Checking mailbox receive status..." -ForegroundColor Cyan
    $mailboxStats = Get-MailboxStatistics procurement@freshthreadsllc.com
    Write-Host "   Total Items: $($mailboxStats.ItemCount)" -ForegroundColor White
    Write-Host "   Mailbox Size: $($mailboxStats.TotalItemSize)" -ForegroundColor White
    Write-Host "   Last Logon: $($mailboxStats.LastLogonTime)" -ForegroundColor White

    Disconnect-ExchangeOnline -Confirm:$false

} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🛠️  TROUBLESHOOTING STEPS:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Gray
Write-Host "1. 📧 Send a test email from your personal email to:" -ForegroundColor White
Write-Host "   → info@freshthreadsllc.com" -ForegroundColor Cyan
Write-Host "   → Wait 2-3 minutes" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 🌐 Check Outlook Web App:" -ForegroundColor White
Write-Host "   → https://outlook.office.com" -ForegroundColor Cyan
Write-Host "   → Sign in: procurement@freshthreadsllc.com" -ForegroundColor Cyan
Write-Host "   → Check Inbox, Junk Email, and Deleted Items" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 📱 Check Outlook Mobile:" -ForegroundColor White
Write-Host "   → Download Outlook app" -ForegroundColor Cyan
Write-Host "   → Add procurement@freshthreadsllc.com account" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. 🔍 Check Message Trace:" -ForegroundColor White
Write-Host "   → admin.microsoft.com → Exchange → Mail flow → Message trace" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Common Issues:" -ForegroundColor Yellow
Write-Host "• Emails in Junk/Spam folder" -ForegroundColor White
Write-Host "• 5-10 minute delivery delay for new aliases" -ForegroundColor White
Write-Host "• Sending from same domain (won't work)" -ForegroundColor White
Write-Host "• Typos in email addresses" -ForegroundColor White

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green
Write-Host "1. Send test email from personal email (Gmail, Yahoo, etc.)" -ForegroundColor White
Write-Host "2. Wait 5 minutes" -ForegroundColor White
Write-Host "3. Check Outlook web app thoroughly" -ForegroundColor White
Write-Host "4. Run this script again to check message trace" -ForegroundColor White
