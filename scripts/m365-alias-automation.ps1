# Microsoft 365 Email Alias Automation
# Connects to Exchange Online and manages email aliases

param(
    [Parameter(Mandatory = $false)]
    [string]$Action = "list",

    [Parameter(Mandatory = $false)]
    [string]$UserEmail = "bryan@freshthreadsllc.com",

    [Parameter(Mandatory = $false)]
    [string]$AliasToAdd = ""
)

Write-Host "=== Microsoft 365 Email Alias Automation ===" -ForegroundColor Green

try {
    # Connect to Exchange Online
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
    Connect-ExchangeOnline -ShowBanner:$false

    switch ($Action.ToLower()) {
        "list" {
            Write-Host "Listing all email aliases..." -ForegroundColor Blue
            Get-Mailbox | Select-Object DisplayName, UserPrincipalName, EmailAddresses | Format-Table -AutoSize
        }

        "check" {
            Write-Host "Checking user: $UserEmail" -ForegroundColor Blue
            $mailbox = Get-Mailbox -Identity $UserEmail -ErrorAction SilentlyContinue
            if ($mailbox) {
                Write-Host "✅ User found: $($mailbox.DisplayName)" -ForegroundColor Green
                Write-Host "Email addresses:" -ForegroundColor Yellow
                $mailbox.EmailAddresses | ForEach-Object { Write-Host "  - $_" }
            }
            else {
                Write-Host "❌ User not found: $UserEmail" -ForegroundColor Red
            }
        }

        "add" {
            if ($AliasToAdd -eq "") {
                Write-Host "❌ Please provide an alias to add" -ForegroundColor Red
                exit 1
            }
            Write-Host "Adding alias $AliasToAdd to $UserEmail..." -ForegroundColor Blue
            Set-Mailbox -Identity $UserEmail -EmailAddresses @{Add = "$AliasToAdd" }
            Write-Host "✅ Alias added successfully" -ForegroundColor Green
        }

        default {
            Write-Host "Available actions: list, check, add" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}

