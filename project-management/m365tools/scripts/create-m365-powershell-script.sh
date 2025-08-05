#!/bin/bash

# Creates PowerShell script for Microsoft Graph email alias automation

echo "🔧 Creating PowerShell Script for Microsoft Graph..."

cat > ./m365tools/scripts/m365-alias-automation.ps1 << 'EOF'
# 📧 Fresh Threads LLC - Microsoft 365 Email Alias Automation
# PowerShell script using Microsoft Graph to create email aliases
# Run this script with administrative privileges

# Check if Microsoft Graph PowerShell module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "❌ Microsoft Graph PowerShell module not found"
    Write-Host "Installing Microsoft Graph module..."
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Import required modules
Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph
Write-Host "🔐 Connecting to Microsoft Graph..."
Write-Host "Please sign in with your Microsoft 365 admin account (bryan@freshthreadsllc.com)"
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Configuration
$Domain = "freshthreadsllc.com"
$PrimaryUser = "bryan@freshthreadsllc.com"

# Get the user object
try {
    $User = Get-MgUser -UserId $PrimaryUser
    Write-Host "✅ Found user: $($User.DisplayName)"
} catch {
    Write-Host "❌ Error finding user $PrimaryUser"
    Write-Host $_.Exception.Message
    exit 1
}

# Define all aliases with descriptions
$AllAliases = @{
    # Phase 1: Essential
    "info@$Domain" = "General inquiries, first contact"
    "support@$Domain" = "Customer service, order issues"
    "orders@$Domain" = "Order confirmations, shipping updates"
    "procurement@$Domain" = "Supplier communications, vendor management"

    # Phase 2: Business Growth
    "sales@$Domain" = "Sales inquiries, bulk orders"
    "marketing@$Domain" = "Partnerships, influencer outreach"
    "billing@$Domain" = "Payment issues, invoicing"
    "admin@$Domain" = "Administrative tasks, legal notices"
    "returns@$Domain" = "Return requests, exchanges"
    "accounting@$Domain" = "Financial records, tax documents"

    # Phase 3: Professional Polish
    "press@$Domain" = "Media inquiries, PR opportunities"
    "partnerships@$Domain" = "Business collaborations"
    "legal@$Domain" = "Legal inquiries, DMCA notices"
    "privacy@$Domain" = "Privacy policy, GDPR requests"
    "security@$Domain" = "Security reports, data breaches"
    "design@$Domain" = "Design submissions, creative feedback"
    "creative@$Domain" = "Creative partnerships, artist collaborations"
    "submissions@$Domain" = "Design contest entries"
    "inventory@$Domain" = "Stock management, supplier updates"
    "shipping@$Domain" = "Fulfillment, logistics"
    "quality@$Domain" = "Quality control, product feedback"
    "affiliate@$Domain" = "Affiliate program inquiries"
}

Write-Host ""
Write-Host "🚀 Creating $($AllAliases.Count) email aliases for Fresh Threads LLC..."
Write-Host ""

# Get current aliases to avoid duplicates
$CurrentAliases = $User.ProxyAddresses | Where-Object { $_ -like "smtp:*" } | ForEach-Object { $_.Substring(5) }

$CreatedCount = 0
$SkippedCount = 0

foreach ($Alias in $AllAliases.Keys) {
    $Description = $AllAliases[$Alias]

    if ($CurrentAliases -contains $Alias) {
        Write-Host "⏭️  Skipping $Alias (already exists) - $Description"
        $SkippedCount++
        continue
    }

    try {
        # Add the alias to the user's proxy addresses
        $NewProxyAddress = "smtp:$Alias"
        $UpdatedProxyAddresses = $User.ProxyAddresses + $NewProxyAddress

        # Update the user with new proxy addresses
        Update-MgUser -UserId $User.Id -ProxyAddresses $UpdatedProxyAddresses

        Write-Host "✅ Created: $Alias - $Description"
        $CreatedCount++

        # Small delay to avoid throttling
        Start-Sleep -Milliseconds 500

    } catch {
        Write-Host "❌ Failed to create $Alias"
        Write-Host "   Error: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "📊 Summary:"
Write-Host "   ✅ Created: $CreatedCount aliases"
Write-Host "   ⏭️  Skipped: $SkippedCount aliases (already existed)"
Write-Host ""

if ($CreatedCount -gt 0) {
    Write-Host "🎉 Success! Fresh Threads LLC now has professional email aliases!"
    Write-Host ""
    Write-Host "📋 Next Steps:"
    Write-Host "1. Configure Outlook signatures for each department"
    Write-Host "2. Set up email rules for auto-organization"
    Write-Host "3. Test sending from different aliases"
    Write-Host "4. Update website and business cards with new emails"
    Write-Host ""
    Write-Host "💡 Pro Tip: You can now send emails FROM any of these aliases"
    Write-Host "   in Outlook by changing the 'From' field when composing!"
}

Write-Host ""
Write-Host "🔐 Disconnecting from Microsoft Graph..."
Disconnect-MgGraph

Write-Host "✅ Script complete! Fresh Threads LLC is now professionally organized! 🏢"
EOF

echo "✅ Created PowerShell script: ./m365tools/scripts/m365-alias-automation.ps1"
echo ""
echo "📋 To run this script:"
echo "1. Open PowerShell as Administrator"
echo "2. Run: Set-ExecutionPolicy RemoteSigned (if needed)"
echo "3. Navigate to your project directory"
echo "4. Run: ./m365tools/scripts/m365-alias-automation.ps1"
echo "5. Sign in with bryan@freshthreadsllc.com when prompted"
echo ""
echo "⚡ This will automatically create ALL email aliases in one go!"
