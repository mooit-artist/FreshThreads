# 🔒 Microsoft 365 Security Lockdown Guide

**Business:** Fresh Threads LLC
**Current Plan:** Microsoft 365 Business Basic
**Primary Email:** bryan@freshthreadsllc.com
**Security Goal:** Enterprise-grade protection for small business

---

## 🚨 **IMMEDIATE SECURITY PRIORITIES** (Do These NOW)

### **Phase 1: Authentication & Access Control (Next 30 minutes)**

#### 1. **Enable Multi-Factor Authentication (MFA)**

```
🎯 CRITICAL: Do this first!

1. Go to: admin.microsoft.com
2. Sign in as bryan@freshthreadsllc.com
3. Go to Users → Active Users
4. Select your account → Multi-factor authentication
5. Enable: ✅ Required for all users
6. Methods: SMS + Authenticator App (Microsoft Authenticator)

⚠️ BACKUP CODES: Download and store securely!
```

#### 2. **Secure Admin Account**

```
1. Admin Center → Azure Active Directory → Users
2. Select bryan@freshthreadsllc.com
3. Assigned roles → Review permissions
4. Remove unnecessary admin rights
5. Create separate admin account if needed:
   - admin@freshthreadsllc.com (separate from daily use)
```

#### 3. **Review Sign-in Logs**

```
1. Azure AD → Sign-ins
2. Check for suspicious locations/devices
3. Look for failed sign-in attempts
4. Verify all recent activity is legitimate
```

---

## 🛡️ **SECURITY CONFIGURATION CHECKLIST**

### **Email Security (Exchange Online)**

#### **Anti-Spam & Anti-Malware**

- [ ] **Safe Attachments:** Enable for all users
- [ ] **Safe Links:** Enable URL scanning and rewriting
- [ ] **Anti-phishing policies:** Configure impersonation protection
- [ ] **Quarantine notifications:** Enable user notifications
- [ ] **SPF Records:** Configure for freshthreadsllc.com
- [ ] **DKIM:** Enable domain signing
- [ ] **DMARC:** Implement policy (start with p=none)

```bash
# DNS Records to Add (at your domain registrar):

# SPF Record:
TXT: v=spf1 include:spf.protection.outlook.com -all

# DKIM (after enabling in M365):
CNAME: selector1._domainkey → selector1-freshthreadsllc-com._domainkey.freshthreadsllc.onmicrosoft.com
CNAME: selector2._domainkey → selector2-freshthreadsllc-com._domainkey.freshthreadsllc.onmicrosoft.com

# DMARC Policy:
TXT: v=DMARC1; p=quarantine; rua=mailto:bryan@freshthreadsllc.com; ruf=mailto:bryan@freshthreadsllc.com
```

#### **Mailbox Protection**

- [ ] **Litigation Hold:** Enable for compliance
- [ ] **Audit Logging:** Enable mailbox auditing
- [ ] **External Sharing:** Restrict to authorized domains only
- [ ] **Calendar Sharing:** Limit external calendar access
- [ ] **Forwarding Rules:** Disable auto-forwarding to external addresses

### **Identity & Access Management**

#### **Conditional Access (Requires Azure AD P1 - consider upgrade)**

- [ ] **Location-based access:** Block sign-ins from risky locations
- [ ] **Device compliance:** Require managed devices
- [ ] **App-based protection:** Control access to business apps
- [ ] **Risk-based access:** Block high-risk sign-ins

#### **Password Policies**

- [ ] **Password complexity:** Enforce strong passwords
- [ ] **Password expiration:** Set appropriate expiration (90 days)
- [ ] **Password history:** Prevent reuse of last 12 passwords
- [ ] **Account lockout:** Configure after 5 failed attempts

#### **Guest Access Control**

- [ ] **Disable guest access** (unless specifically needed)
- [ ] **Guest permissions:** Limit to essential functions only
- [ ] **Guest review:** Regular access reviews if guests are allowed

---

## 🔍 **SECURITY MONITORING & COMPLIANCE**

### **Audit & Logging**

- [ ] **Unified Audit Log:** Enable comprehensive logging
- [ ] **Alert Policies:** Set up for suspicious activities
- [ ] **Data Loss Prevention (DLP):** Configure for sensitive data
- [ ] **Retention Policies:** Set appropriate data retention

### **Device Management**

- [ ] **Mobile Device Management (MDM):** Configure Intune basics
- [ ] **App Protection:** Control business apps on personal devices
- [ ] **Device Compliance:** Set minimum security requirements
- [ ] **Remote Wipe:** Enable for lost/stolen devices

### **Data Protection**

- [ ] **Sensitivity Labels:** Classify business documents
- [ ] **Information Rights Management:** Protect sensitive content
- [ ] **SharePoint External Sharing:** Configure appropriate restrictions
- [ ] **OneDrive Security:** Set sharing and access controls

---

## 🚨 **SECURITY INCIDENT RESPONSE PLAN**

### **If You Suspect a Breach:**

1. **Immediate Actions:**
   - Change admin password immediately
   - Review recent sign-in activity
   - Check for unauthorized forwarding rules
   - Scan for suspicious calendar items/meetings

2. **Investigation Steps:**
   - Export audit logs from last 30 days
   - Review all email rules and delegations
   - Check for unauthorized applications
   - Verify all user accounts and permissions

3. **Recovery Actions:**
   - Reset passwords for all affected accounts
   - Revoke all active sessions
   - Remove suspicious applications/permissions
   - Enable enhanced monitoring

### **Emergency Contacts:**

- **Microsoft Support:** 1-800-642-7676
- **Your IT Support:** [Add contact info]
- **Cyber Insurance:** [Add if applicable]

---

## 📈 **RECOMMENDED UPGRADES FOR ENHANCED SECURITY**

### **Consider Upgrading From Business Basic ($6/month):**

#### **Microsoft 365 Business Premium ($22/month)**

✅ **Additional Security Features:**

- Advanced Threat Protection (ATP)
- Conditional Access policies
- Intune device management
- Advanced eDiscovery
- Data Loss Prevention (DLP)
- Azure Information Protection

#### **Azure AD Premium P1 ($6/month additional)**

✅ **Advanced Identity Features:**

- Conditional Access
- Self-service password reset
- Dynamic groups
- Advanced security reporting

### **Third-Party Security Tools (Optional):**

- **Password Manager:** Bitwarden Business ($3/user/month)
- **Email Security:** Proofpoint or Mimecast
- **Endpoint Protection:** CrowdStrike or SentinelOne
- **Security Awareness Training:** KnowBe4

---

## 🔧 **IMPLEMENTATION TIMELINE**

### **Week 1: Critical Security (DO NOW)**

- [x] Multi-Factor Authentication enabled
- [ ] Admin account secured
- [ ] Basic email security configured
- [ ] DNS security records added

### **Week 2: Enhanced Protection**

- [ ] Audit logging enabled
- [ ] DLP policies configured
- [ ] Device management setup
- [ ] Security monitoring alerts

### **Week 3: Optimization**

- [ ] Security training completed
- [ ] Incident response plan tested
- [ ] Regular security review scheduled
- [ ] Backup and recovery verified

---

## 📋 **DAILY SECURITY CHECKLIST**

### **Weekly Review (Every Monday):**

- [ ] Review sign-in reports for suspicious activity
- [ ] Check quarantined emails
- [ ] Verify no new administrative users added
- [ ] Review any security alerts or notifications

### **Monthly Review (First of month):**

- [ ] Full audit log review
- [ ] Password policy compliance check
- [ ] Device compliance status
- [ ] Security training progress (when implemented)

### **Quarterly Review (Every 3 months):**

- [ ] Full security assessment
- [ ] Access permissions audit
- [ ] Incident response plan update
- [ ] Consider security upgrades/improvements

---

## 🎯 **BUSINESS-SPECIFIC CONSIDERATIONS**

### **Fresh Threads LLC Security Priorities:**

1. **Financial Data Protection:**
   - Banking information security
   - Payment processor data
   - Tax document protection

2. **Intellectual Property:**
   - T-shirt design files
   - Business plans and strategies
   - Customer lists and data

3. **Supplier Communications:**
   - Secure vendor communications
   - Contract and pricing protection
   - Supply chain security

4. **Customer Data (Future):**
   - Order information
   - Payment details
   - Personal customer data (GDPR/CCPA compliance)

---

## ⚡ **QUICK START COMMANDS**

### **PowerShell Commands for M365 Security:**

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName bryan@freshthreadsllc.com

# Enable audit logging
Set-OrganizationConfig -AuditDisabled $false

# Check current admin roles
Get-RoleGroupMember "Organization Management"

# Review anti-spam policies
Get-HostedContentFilterPolicy

# Check safe attachments
Get-SafeAttachmentPolicy

# Disconnect when done
Disconnect-ExchangeOnline
```

### **Azure AD PowerShell:**

```powershell
# Connect to Azure AD
Connect-AzureAD

# Check MFA status
Get-AzureADUser -ObjectId bryan@freshthreadsllc.com | Select-Object UserPrincipalName,AccountEnabled,@{N="MFA Status";E={ if($_.StrongAuthenticationRequirements.State){$_.StrongAuthenticationRequirements.State} else {"Disabled"}}}

# Review conditional access policies
Get-AzureADMSConditionalAccessPolicy

# Disconnect
Disconnect-AzureAD
```

---

## 📞 **GETTING HELP**

### **Microsoft Support:**

- **Admin Center:** Help & Support ticket
- **Phone:** 1-800-642-7676
- **Community:** Microsoft Tech Community
- **Documentation:** docs.microsoft.com

### **Security Resources:**

- **Microsoft Security Blog:** security.microsoft.com
- **Threat Intelligence:** security.microsoft.com/threatanalytics
- **Security Scorecard:** Check in Microsoft 365 Security Center

---

**🔒 Remember: Security is an ongoing process, not a one-time setup. Review and update these settings regularly as your business grows!**

**Next Action:** Start with Phase 1 (MFA) immediately, then work through the checklist systematically.
