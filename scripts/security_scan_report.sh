#!/bin/bash

# 🔍 FreshThreads Repository Security Scan Report
# Generated: $(date)

cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 SECURITY SCAN REPORT - FreshThreads Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ CRITICAL: EXPOSED SENSITIVE DATA FOUND

🚨 HIGH PRIORITY ITEMS TO SECURE:

1. PayPal Sandbox Credentials (EXPOSED in multiple locations):
   • File: scripts/paypaldev.params
     - PayPal ClientID: AZbRplh_y2EwYlajHo_dT2mSYHHq--QBddpGBOGFvz-JreFuepdh_NAkL9DW7PajXFSX-L8TndhMNFfh
     - PayPal Secret: ENQfUMv05oy2mrmiXCDM7ZcDCXaiSQooiUN-jFUhg0hfJrR094X9uhaAV0ELTZ_gTu4vkSUtaXzurtAI

   • File: config/paypal-config.env
     - Same credentials duplicated

   • File: docs/paypal-checkout.html
     - Client ID hardcoded in JavaScript SDK URL

2. Business Email Addresses (EXPOSED):
   • bryan@freshthreadsllc.com (CEO email)
   • procurement@freshthreadsllc.com (admin email)
   • Multiple business aliases exposed in documentation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ IMMEDIATE ACTION REQUIRED:

1. Move PayPal credentials to GitHub Secrets
2. Remove hardcoded credentials from repository files
3. Update HTML files to use environment variables
4. Add sensitive files to .gitignore
5. Rotate any exposed production credentials

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛡️ AUTOMATED REMEDIATION AVAILABLE:

Run the following scripts to secure your repository:

1. Upload secrets to GitHub:
   ./scripts/upload_secrets_to_github.sh

2. Set up environment protection:
   ./scripts/setup_environment_protection.sh

3. Remove sensitive files:
   ./scripts/secure_repository.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
