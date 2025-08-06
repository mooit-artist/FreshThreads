# Windows Setup Guide - FreshThreads Business Automation

**Date:** August 5, 2025
**Project:** FreshThreads LLC Business Automation Suite
**Target:** Windows Environment Setup

## 🚀 Quick Start on Windows

### 1. Prerequisites Installation

```powershell
# Install Windows Package Manager (if not already installed)
# Download from: https://aka.ms/getwinget

# Install PowerShell 7+ (recommended)
winget install Microsoft.PowerShell

# Install Git for Windows
winget install Git.Git

# Install Python
winget install Python.Python.3.12

# Install Node.js (for additional tools)
winget install OpenJS.NodeJS
```

### 2. Clone Repository

```powershell
# Navigate to your desired directory
cd C:\Users\$env:USERNAME\Documents\GitHub

# Clone the repository
git clone https://github.com/mooit-artist/FreshThreads.git
cd FreshThreads
```

### 3. Set Execution Policy

```powershell
# Allow PowerShell scripts to run (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🛠️ Business Automation Scripts Ready for Windows

### Available Scripts

| Script                                   | Purpose                     | Status            |
| ---------------------------------------- | --------------------------- | ----------------- |
| `scripts/business-automation-suite.sh`   | Master automation suite     | ✅ Cross-platform |
| `scripts/teams-business-setup.ps1`       | Teams configuration         | ✅ Windows native |
| `scripts/create-business-user-graph.ps1` | User creation (Graph API)   | ✅ Windows native |
| `scripts/paypal-business-automation.ps1` | PayPal business integration | ✅ Windows native |
| `scripts/setup-teams-business.sh`        | Teams setup launcher        | ✅ Cross-platform |
| `scripts/check-users.ps1`                | User verification           | ✅ Windows native |

### Environment Setup

1. **Copy Environment Template:**

```powershell
cp .env.template .env
```

2. **Edit `.env` file with your credentials:**
   - Microsoft 365 admin credentials
   - PayPal business account details
   - Stripe account information
   - Banking integration details

## 🎯 Continue Business Setup

### Option 1: Complete Business Suite

```powershell
# Run the full business automation suite
.\scripts\business-automation-suite.sh
```

### Option 2: Teams-Only Setup

```powershell
# Create bryan@freshthreadsllc.com with mailbox and Teams
.\scripts\create-business-user-graph.ps1
```

### Option 3: PayPal Business Setup

```powershell
# Complete PayPal business integration
.\scripts\paypal-business-automation.ps1 -Action setup -Environment sandbox

# Test PayPal payment processing
.\scripts\paypal-business-automation.ps1 -Action test

# Start PayPal webhook server
.\scripts\paypal-business-automation.ps1 -Action webhook
```

### Option 4: User Management

```powershell
# Check existing users first
.\scripts\check-users.ps1

# Then create the business user
.\scripts\create-business-user-graph.ps1 -UserEmail "bryan@freshthreadsllc.com" -DisplayName "Bryan Jorgensen" -JobTitle "CEO"
```

## 📋 Current Setup Status

### ✅ Completed on macOS

- [x] Business automation framework created
- [x] Microsoft Teams PowerShell integration
- [x] User creation scripts (Graph API)
- [x] Environment configuration templates
- [x] Project management structure
- [x] Security configurations

### 🔄 Ready for Windows

- [x] All PowerShell scripts are Windows-compatible
- [x] Microsoft Graph API integration
- [x] Cross-platform shell scripts
- [x] Environment templates configured
- [x] Git repository synchronized

### ⏳ Next Steps on Windows

- [ ] Install prerequisites
- [ ] Configure environment variables
- [ ] Run user creation script
- [ ] Complete Teams business setup
- [ ] Configure PayPal business integration
- [ ] Set up Stripe payments
- [ ] Deploy business phone system

## 🔐 Security Considerations

### Files to Keep Secure

- `.env` - Contains actual credentials (already in .gitignore)
- `project-management/*.md` - May contain temporary passwords
- PowerShell execution logs

### Authentication Required

- **Microsoft 365 Admin:** procurement@freshthreadsllc.com
- **Tenant ID:** b825802f-efc7-4824-85a4-95406ead69b1
- **Tenant Name:** Freshthreads LLC

## 🎯 Business User Creation Progress

### Current Status

- **Target User:** bryan@freshthreadsllc.com
- **Microsoft 365 Tenant:** ✅ Connected (Freshthreads LLC)
- **User Account:** ❌ Needs to be created
- **Mailbox:** ⏳ Will be auto-provisioned
- **Teams:** ⏳ Will be auto-configured
- **Phone System:** ⏳ Pending user creation

### Expected Outcome

After running the user creation script, bryan@freshthreadsllc.com will have:

- Microsoft 365 user account
- Exchange Online mailbox
- Teams calling capabilities
- Business email aliases (ceo@, contact@, info@)
- Enterprise Voice features
- Mobile and desktop app access

## 📱 Business Features Ready to Configure

### Teams Business Phone

- Auto-attendant for customer calls
- Voicemail integration
- Call forwarding and delegation
- Conference calling (up to 250 participants)
- Mobile and desktop calling apps

### Email System

- Primary: bryan@freshthreadsllc.com
- Aliases: ceo@, contact@, info@freshthreadsllc.com
- Outlook integration
- Mobile email access

### Payment Processing

- **PayPal Business integration** with automation
- **PayPal Express Checkout** for FreshThreads website
- **PayPal Webhooks** for order notifications
- **PayPal Invoicing** for B2B customers
- Stripe payment gateway (secondary)
- Banking automation
- Financial reporting and analytics

## 🚀 Quick Commands for Windows

```powershell
# Check current repository status
git status
git pull origin main

# Install PowerShell modules (if needed)
Install-Module -Name Microsoft.Graph -Force
Install-Module -Name ExchangeOnlineManagement -Force
Install-Module -Name MicrosoftTeams -Force

# Run business user creation
.\scripts\create-business-user-graph.ps1

# Check Teams connectivity
.\scripts\teams-business-setup.ps1 -Action test

# Generate user report
.\scripts\check-users.ps1
```

## 📞 Support Information

### If You Encounter Issues:

1. **PowerShell Execution Policy:** Run as Administrator and set execution policy
2. **Module Installation:** May require internet connection for first-time setup
3. **Microsoft 365 Authentication:** Use procurement@freshthreadsllc.com account
4. **Graph API Permissions:** May require admin consent in Azure portal

### Documentation References:

- Microsoft Graph PowerShell: https://docs.microsoft.com/graph/powershell/
- Teams PowerShell: https://docs.microsoft.com/microsoftteams/teams-powershell-overview
- Exchange Online: https://docs.microsoft.com/powershell/exchange/

---

**Ready to continue business setup on Windows! 🚀**

All scripts are cross-platform compatible and ready to run.
The bryan@freshthreadsllc.com user creation is the next priority task.
