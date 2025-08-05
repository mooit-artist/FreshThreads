#!/bin/bash

# M365 Security Assessment Script for Fresh Threads LLC
# Purpose: Quick security posture check and actionable recommendations

echo "🔒 Microsoft 365 Security Assessment for Fresh Threads LLC"
echo "=========================================================="
echo ""

# Check if we're connected to M365
echo "📋 Pre-Assessment Checklist:"
echo "1. Are you logged into admin.microsoft.com? (y/n)"
read -r admin_access

echo "2. Do you have Global Administrator rights? (y/n)"
read -r admin_rights

echo "3. Have you enabled MFA on your account? (y/n)"
read -r mfa_enabled

echo ""
echo "🔍 Current Security Status Assessment:"
echo "======================================"

# MFA Status
if [[ $mfa_enabled == "y" || $mfa_enabled == "Y" ]]; then
    echo "✅ MFA: ENABLED (GOOD)"
else
    echo "❌ MFA: DISABLED (CRITICAL - Fix immediately!)"
    echo "   → Go to admin.microsoft.com → Users → Active Users → Multi-factor authentication"
fi

# Generate security checklist based on current status
echo ""
echo "🎯 Immediate Action Items (Next 15 minutes):"
echo "============================================"

if [[ $mfa_enabled != "y" && $mfa_enabled != "Y" ]]; then
    echo "🚨 CRITICAL: Enable MFA RIGHT NOW"
    echo "   1. Go to: https://admin.microsoft.com"
    echo "   2. Users → Active Users → bryan@freshthreadsllc.com"
    echo "   3. Multi-factor authentication → Enable"
    echo "   4. Download backup codes!"
    echo ""
fi

echo "📧 Email Security Setup (Next 30 minutes):"
echo "==========================================="
echo "1. Configure Anti-spam policies"
echo "   → Security & Compliance Center → Threat Management → Policy → Anti-spam"
echo ""
echo "2. Enable Safe Attachments"
echo "   → Security Center → Threat Management → Policy → Safe Attachments"
echo ""
echo "3. Set up Safe Links"
echo "   → Security Center → Threat Management → Policy → Safe Links"
echo ""

echo "🔗 DNS Security Records (Add to your domain registrar):"
echo "======================================================="
echo "Add these TXT records to freshthreadsllc.com:"
echo ""
echo "SPF Record:"
echo "   Name: @ (or blank)"
echo "   Value: v=spf1 include:spf.protection.outlook.com -all"
echo ""
echo "DMARC Record:"
echo "   Name: _dmarc"
echo "   Value: v=DMARC1; p=quarantine; rua=mailto:bryan@freshthreadsllc.com"
echo ""

echo "📊 Security Monitoring Setup:"
echo "============================="
echo "1. Enable Audit Logging"
echo "   → Security & Compliance Center → Search & Investigation → Audit log search"
echo ""
echo "2. Set up Alert Policies"
echo "   → Security Center → Alerts → Alert policies"
echo ""
echo "3. Review Sign-in Activity"
echo "   → Azure AD → Sign-ins (check for suspicious activity)"
echo ""

echo "💡 Recommended Upgrades for Better Security:"
echo "==========================================="
echo "Current Plan: Microsoft 365 Business Basic ($6/month)"
echo ""
echo "Consider upgrading to:"
echo "• Microsoft 365 Business Premium ($22/month)"
echo "  - Advanced Threat Protection"
echo "  - Conditional Access"
echo "  - Device Management"
echo "  - Data Loss Prevention"
echo ""
echo "• Azure AD Premium P1 ($6/month additional)"
echo "  - Enhanced Conditional Access"
echo "  - Risk-based authentication"
echo "  - Advanced reporting"
echo ""

echo "🚨 Security Incident Response:"
echo "============================="
echo "If you suspect a security issue:"
echo "1. Change admin password immediately"
echo "2. Review recent sign-ins: Azure AD → Sign-ins"
echo "3. Check email rules: Outlook → Settings → Mail → Rules"
echo "4. Contact Microsoft Support: 1-800-642-7676"
echo ""

echo "📅 Next Steps Schedule:"
echo "======================"
echo "Today (next 2 hours):"
echo "• Enable MFA if not done"
echo "• Configure basic email security"
echo "• Add DNS security records"
echo ""
echo "This Week:"
echo "• Enable audit logging"
echo "• Set up security alerts"
echo "• Review and lock down admin permissions"
echo ""
echo "Next Month:"
echo "• Consider upgrading to Business Premium"
echo "• Implement device management policies"
echo "• Set up data loss prevention"
echo ""

echo "✅ Assessment Complete!"
echo ""
echo "📖 Full Documentation: See M365-SECURITY-LOCKDOWN.md"
echo "🆘 Emergency Contact: Microsoft Support 1-800-642-7676"
echo ""
echo "🔒 Remember: Security is ongoing - review monthly!"

# Create a simple status file
cat > "/tmp/m365-security-status.txt" << EOF
M365 Security Assessment - $(date)
=====================================

Account: bryan@freshthreadsllc.com
Plan: Microsoft 365 Business Basic

Security Status:
- MFA Enabled: $mfa_enabled
- Admin Access: $admin_rights
- Admin Portal Access: $admin_access

Next Actions:
1. $(if [[ $mfa_enabled != "y" && $mfa_enabled != "Y" ]]; then echo "ENABLE MFA IMMEDIATELY"; else echo "MFA is enabled ✅"; fi)
2. Configure email security policies
3. Add DNS security records
4. Enable audit logging
5. Set up security monitoring

Assessment completed: $(date)
EOF

echo "📄 Assessment saved to: /tmp/m365-security-status.txt"
