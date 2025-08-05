# Fresh Threads LLC - Hybrid Email Alias Automation
# Designed for dual-account setup: bryan@ + procurement@

# Connect to Microsoft Graph
Write-Host "🚀 Fresh Threads LLC - Hybrid Email Alias Setup" -ForegroundColor Green
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow

try {
    Connect-MgGraph -Scopes "Mail.ReadWrite", "Directory.ReadWrite.All"
    Write-Host "✅ Connected to Microsoft Graph successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect to Microsoft Graph. Please install Microsoft.Graph module:" -ForegroundColor Red
    Write-Host "Install-Module Microsoft.Graph -Force" -ForegroundColor Yellow
    exit 1
}

# Check current setup
Write-Host "`n🔍 Checking current email setup..." -ForegroundColor Cyan
$domain = "freshthreadsllc.com"

# Verify both accounts exist
$bryanAccount = Get-MgUser -Filter "startswith(mail,'bryan@$domain')" -ErrorAction SilentlyContinue
$procurementAccount = Get-MgUser -Filter "startswith(mail,'procurement@$domain')" -ErrorAction SilentlyContinue

if ($procurementAccount) {
    Write-Host "✅ Found: procurement@$domain (Admin Account)" -ForegroundColor Green
} else {
    Write-Host "❌ procurement@$domain not found" -ForegroundColor Red
}

if ($bryanAccount) {
    Write-Host "✅ Found: bryan@$domain (Personal Business)" -ForegroundColor Green
} else {
    Write-Host "⚠️  bryan@$domain not found - will create as alias" -ForegroundColor Yellow
}

# Define alias routing strategy
Write-Host "`n📋 Hybrid Alias Routing Strategy:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Aliases that forward to bryan@freshthreadsllc.com (Customer-facing)
$bryanAliases = @(
    @{name="bryan"; desc="Personal business communications"},
    @{name="info"; desc="General inquiries, first contact"},
    @{name="support"; desc="Customer service, order issues"},
    @{name="orders"; desc="Order confirmations, shipping updates"},
    @{name="sales"; desc="Sales inquiries, bulk orders"},
    @{name="marketing"; desc="Partnerships, influencer outreach"},
    @{name="billing"; desc="Payment issues, invoicing"},
    @{name="returns"; desc="Return requests, exchanges"},
    @{name="press"; desc="Media inquiries, PR opportunities"},
    @{name="partnerships"; desc="Business collaborations"},
    @{name="design"; desc="Design submissions, creative feedback"},
    @{name="creative"; desc="Creative partnerships, artist collaborations"},
    @{name="submissions"; desc="Design contest entries"},
    @{name="shipping"; desc="Fulfillment, logistics"},
    @{name="quality"; desc="Quality control, product feedback"},
    @{name="affiliate"; desc="Affiliate program inquiries"}
)

# Aliases that forward to procurement@freshthreadsllc.com (Business ops)
$procurementAliases = @(
    @{name="admin"; desc="Administrative tasks, legal notices"},
    @{name="accounting"; desc="Financial records, tax documents"},
    @{name="legal"; desc="Legal inquiries, DMCA notices"},
    @{name="privacy"; desc="Privacy policy, GDPR requests"},
    @{name="security"; desc="Security reports, data breaches"},
    @{name="inventory"; desc="Stock management, supplier updates"}
)

Write-Host "📧 BRYAN@ ALIASES (Customer & Public-facing):" -ForegroundColor Blue
foreach ($alias in $bryanAliases) {
    Write-Host "  • $($alias.name)@$domain → bryan@$domain" -ForegroundColor White
    Write-Host "    $($alias.desc)" -ForegroundColor Gray
}

Write-Host "`n🏢 PROCUREMENT@ ALIASES (Admin & Operations):" -ForegroundColor Magenta
foreach ($alias in $procurementAliases) {
    Write-Host "  • $($alias.name)@$domain → procurement@$domain" -ForegroundColor White
    Write-Host "    $($alias.desc)" -ForegroundColor Gray
}

# Confirm setup
Write-Host "`n❓ Proceed with hybrid alias creation? (y/n): " -ForegroundColor Yellow -NoNewline
$confirm = Read-Host

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "❌ Setup cancelled by user." -ForegroundColor Red
    exit 0
}

Write-Host "`n🔧 Creating aliases..." -ForegroundColor Green

# Function to create alias
function New-EmailAlias {
    param($aliasName, $targetEmail, $description)

    try {
        $alias = "$aliasName@$domain"
        Write-Host "🔧 Creating: $alias → $targetEmail" -ForegroundColor Yellow
        Write-Host "   Purpose: $description" -ForegroundColor Gray

        # Get the target user
        $targetUser = Get-MgUser -Filter "mail eq '$targetEmail'" -ErrorAction Stop

        if ($targetUser) {
            # Add the alias as an additional email address
            $currentAddresses = $targetUser.ProxyAddresses
            $newAddress = "smtp:$alias"

            # Check if alias already exists
            if ($currentAddresses -contains $newAddress) {
                Write-Host "⚠️  Alias already exists: $alias" -ForegroundColor Yellow
            } else {
                # Add the new alias
                $updatedAddresses = $currentAddresses + $newAddress
                Update-MgUser -UserId $targetUser.Id -ProxyAddresses $updatedAddresses
                Write-Host "✅ Created: $alias → $targetEmail" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ Target user not found: $targetEmail" -ForegroundColor Red
        }

    } catch {
        Write-Host "❌ Failed to create: $alias" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}# Create bryan@ aliases (customer-facing)
Write-Host "`n📧 Creating BRYAN@ aliases..." -ForegroundColor Blue
foreach ($alias in $bryanAliases) {
    New-EmailAlias -aliasName $alias.name -targetEmail "bryan@$domain" -description $alias.desc
    Start-Sleep -Milliseconds 500
}

# Create procurement@ aliases (admin/ops)
Write-Host "`n🏢 Creating PROCUREMENT@ aliases..." -ForegroundColor Magenta
foreach ($alias in $procurementAliases) {
    New-EmailAlias -aliasName $alias.name -targetEmail "procurement@$domain" -description $alias.desc
    Start-Sleep -Milliseconds 500
}

Write-Host "`n🎉 HYBRID EMAIL SYSTEM COMPLETE!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

Write-Host "`n📋 Your Email Management Strategy:" -ForegroundColor Cyan
Write-Host "👤 BRYAN@: Check for customer emails, sales, support, marketing" -ForegroundColor Blue
Write-Host "🏢 PROCUREMENT@: Check for admin, legal, accounting, security" -ForegroundColor Magenta
Write-Host "📱 You can check both inboxes or set up forwarding rules!" -ForegroundColor White

Write-Host "`n✅ Fresh Threads LLC now has professional email infrastructure!" -ForegroundColor Green
Write-Host "🚀 Ready to impress customers AND manage business operations!" -ForegroundColor Yellow

# Disconnect from Microsoft Graph
Disconnect-MgGraph
Write-Host "`n✅ Disconnected from Microsoft Graph. Setup complete!" -ForegroundColor Green
