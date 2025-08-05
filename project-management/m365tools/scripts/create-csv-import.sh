#!/bin/bash

# Creates CSV file for bulk email alias import

echo "📊 Creating CSV for Bulk Import..."

cat > ./m365tools/email-aliases-import.csv << 'EOF'
Alias,Description,Department,Phase
info@freshthreadsllc.com,General inquiries and first contact,Customer Service,1
support@freshthreadsllc.com,Customer service and order issues,Customer Service,1
orders@freshthreadsllc.com,Order confirmations and shipping updates,Operations,1
procurement@freshthreadsllc.com,Supplier communications and vendor management,Operations,1
sales@freshthreadsllc.com,Sales inquiries and bulk orders,Sales,2
marketing@freshthreadsllc.com,Partnerships and influencer outreach,Marketing,2
billing@freshthreadsllc.com,Payment issues and invoicing,Finance,2
admin@freshthreadsllc.com,Administrative tasks and legal notices,Administration,2
returns@freshthreadsllc.com,Return requests and exchanges,Customer Service,2
accounting@freshthreadsllc.com,Financial records and tax documents,Finance,2
press@freshthreadsllc.com,Media inquiries and PR opportunities,Marketing,3
partnerships@freshthreadsllc.com,Business collaborations,Business Development,3
legal@freshthreadsllc.com,Legal inquiries and DMCA notices,Legal,3
privacy@freshthreadsllc.com,Privacy policy and GDPR requests,Legal,3
security@freshthreadsllc.com,Security reports and data breaches,IT Security,3
design@freshthreadsllc.com,Design submissions and creative feedback,Creative,3
creative@freshthreadsllc.com,Creative partnerships and artist collaborations,Creative,3
submissions@freshthreadsllc.com,Design contest entries,Creative,3
inventory@freshthreadsllc.com,Stock management and supplier updates,Operations,3
shipping@freshthreadsllc.com,Fulfillment and logistics,Operations,3
quality@freshthreadsllc.com,Quality control and product feedback,Quality Assurance,3
affiliate@freshthreadsllc.com,Affiliate program inquiries,Marketing,3
EOF

echo "✅ Created CSV file: m365tools/email-aliases-import.csv"
echo ""
echo "📋 CSV Import Instructions:"
echo "1. Log into Microsoft 365 Admin Center (admin.microsoft.com)"
echo "2. Go to Users > Active users"
echo "3. Click on Bryan Jorgensen"
echo "4. Go to Mail tab > Manage email aliases"
echo "5. Use 'Bulk add' option (if available)"
echo "6. Upload the m365tools/email-aliases-import.csv file"
echo ""
echo "💡 Alternative: Copy each alias from the CSV and add manually"
echo "   This ensures all aliases are properly configured"
