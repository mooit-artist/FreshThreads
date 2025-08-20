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

Write-Information "=== Microsoft 365 Email Alias Automation ===" -InformationAction Continue

try {
    # Connect to Exchange Online
    Write-Information "Connecting to Exchange Online..." -InformationAction Continue
    Connect-ExchangeOnline -ShowBanner:$false

    switch ($Action.ToLower()) {
        "list" {
            Write-Information "Listing all email aliases..." -InformationAction Continue
            Get-Mailbox | Select-Object DisplayName, UserPrincipalName, EmailAddresses | Format-Table -AutoSize
        }

        "check" {
            Write-Information "Checking user: $UserEmail" -InformationAction Continue
            $mailbox = Get-Mailbox -Identity $UserEmail -ErrorAction SilentlyContinue
            if ($mailbox) {
                Write-Information "✅ User found: $($mailbox.DisplayName)" -InformationAction Continue
                Write-Information "Email addresses:" -InformationAction Continue
                $mailbox.EmailAddresses | ForEach-Object { Write-Information "  - $_" -InformationAction Continue }
            }
            else {
                Write-Error "❌ User not found: $UserEmail"
            }
        }

        "add" {
            if ($AliasToAdd -eq "") {
                Write-Error "❌ Please provide an alias to add"
                exit 1
            }
            Write-Information "Adding alias $AliasToAdd to $UserEmail..." -InformationAction Continue
            Set-Mailbox -Identity $UserEmail -EmailAddresses @{Add = "$AliasToAdd" }
            Write-Information "✅ Alias added successfully" -InformationAction Continue
        }

        default {
            Write-Information "Available actions: list, check, add" -InformationAction Continue
        }
    }
}
catch {
    Write-Error "❌ Error: $($_.Exception.Message)"
    exit 1
}
finally {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
