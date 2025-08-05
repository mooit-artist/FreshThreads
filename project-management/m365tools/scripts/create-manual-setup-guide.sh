#!/bin/bash

# Creates manual setup guide for Microsoft 365 Admin Center

echo "📋 Generating Manual Setup Instructions..."

cat > ./m365tools/MANUAL-EMAIL-SETUP.md << 'EOF'
# 📧 Manual Email Alias Setup Guide

**For:** Fresh Threads LLC
**Domain:** freshthreadsllc.com
**User:** bryan@freshthreadsllc.com

---

## 🚀 Microsoft 365 Admin Center Setup

### **Step 1: Access Admin Center**
1. Go to **admin.microsoft.com**
2. Sign in with **bryan@freshthreadsllc.com**
3. Navigate to **Users** → **Active users**

### **Step 2: Select User**
1. Click on **Bryan Jorgensen**
2. Go to **Mail** tab
3. Click **Manage email aliases**

### **Step 3: Add Aliases One by One**

#### **🔥 Phase 1: Essential (Add Today)**
```
info@freshthreadsllc.com
support@freshthreadsllc.com
orders@freshthreadsllc.com
procurement@freshthreadsllc.com
```

#### **📈 Phase 2: Business Growth (Add This Week)**
```
sales@freshthreadsllc.com
marketing@freshthreadsllc.com
billing@freshthreadsllc.com
admin@freshthreadsllc.com
returns@freshthreadsllc.com
accounting@freshthreadsllc.com
```

#### **🏢 Phase 3: Professional Polish (Add As Needed)**
```
press@freshthreadsllc.com
partnerships@freshthreadsllc.com
legal@freshthreadsllc.com
privacy@freshthreadsllc.com
security@freshthreadsllc.com
design@freshthreadsllc.com
creative@freshthreadsllc.com
submissions@freshthreadsllc.com
inventory@freshthreadsllc.com
shipping@freshthreadsllc.com
quality@freshthreadsllc.com
affiliate@freshthreadsllc.com
```

### **Step 4: For Each Alias**
1. Click **Add an alias**
2. Enter the alias name (e.g., "info")
3. Select domain: **freshthreadsllc.com**
4. Click **Save changes**

---

## ⚡ Quick Copy-Paste Method

**Phase 1 Aliases (copy these one by one):**
- info
- support
- orders
- procurement

**Phase 2 Aliases:**
- sales
- marketing
- billing
- admin
- returns
- accounting

**Phase 3 Aliases:**
- press
- partnerships
- legal
- privacy
- security
- design
- creative
- submissions
- inventory
- shipping
- quality
- affiliate

---

## 📧 Testing Your Setup

### **Send Test Email:**
1. Open Outlook (outlook.office.com)
2. Click **New message**
3. In **From** field, select any alias
4. Send to your personal email
5. Verify it works!

### **Receive Test Email:**
1. Send email TO any alias from personal account
2. Check if it arrives in bryan@freshthreadsllc.com inbox
3. Reply FROM the alias

---

## ✅ Verification Checklist

- [ ] All Phase 1 aliases created (4 aliases)
- [ ] Test sending FROM each alias
- [ ] Test receiving TO each alias
- [ ] Configure professional signatures
- [ ] Set up Outlook rules for organization
- [ ] Update website contact forms
- [ ] Add to business cards/marketing

---

## 💡 Pro Tips

1. **Professional Signatures:** Create different signatures for each department
2. **Email Rules:** Auto-categorize emails by alias
3. **Color Coding:** Assign colors to different departments
4. **Folders:** Create folders for each department

**Result:** Fresh Threads LLC looks like a professional, multi-department company! 🏢✨
EOF

echo "✅ Created manual setup guide: m365tools/MANUAL-EMAIL-SETUP.md"
echo ""
echo "📋 Manual Setup Instructions:"
echo "1. Follow the step-by-step guide in m365tools/MANUAL-EMAIL-SETUP.md"
echo "2. Start with Phase 1 aliases (4 essential emails)"
echo "3. Test each alias after creation"
echo "4. Add Phase 2 and 3 aliases as needed"
echo ""
echo "⏱️  Estimated time: 15-20 minutes for all aliases"
