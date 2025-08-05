#!/bin/bash
# Fresh Threads LLC - Email System Testing Script
# Test all 22 professional email aliases

echo "🚀 Fresh Threads LLC - Email System Test"
echo "========================================"
echo ""
echo "Testing your new professional email aliases..."
echo "All emails will arrive in: procurement@freshthreadsllc.com"
echo ""

# Define test aliases to try
aliases=(
    "info@freshthreadsllc.com"
    "support@freshthreadsllc.com"
    "sales@freshthreadsllc.com"
    "orders@freshthreadsllc.com"
    "marketing@freshthreadsllc.com"
    "bryan@freshthreadsllc.com"
)

echo "📧 Quick Test Aliases:"
echo "====================="
for alias in "${aliases[@]}"; do
    echo "  • $alias"
done

echo ""
echo "🔧 Testing Methods:"
echo "=================="
echo "1. 📱 iPhone/Android Mail App:"
echo "   → Compose new email"
echo "   → To: info@freshthreadsllc.com"
echo "   → Subject: Test - Info Department"
echo "   → Body: Testing Fresh Threads LLC professional email system!"
echo ""

echo "2. 🌐 Web Email (Gmail, Yahoo, etc.):"
echo "   → Open your personal email"
echo "   → Send test email to: support@freshthreadsllc.com"
echo "   → Subject: Test - Customer Support"
echo ""

echo "3. 💻 macOS Mail App:"
echo "   → Open Mail app"
echo "   → New Message"
echo "   → To: sales@freshthreadsllc.com"
echo "   → Subject: Test - Sales Inquiry"
echo ""

echo "📬 Where to Check Results:"
echo "========================="
echo "1. 🌐 Outlook Web App:"
echo "   → Go to: outlook.office.com"
echo "   → Sign in with: procurement@freshthreadsllc.com"
echo "   → Check inbox for test emails"
echo ""

echo "2. 📱 Outlook Mobile App:"
echo "   → Download Outlook app"
echo "   → Add account: procurement@freshthreadsllc.com"
echo "   → Check for incoming test emails"
echo ""

echo "✨ What You Should See:"
echo "======================"
echo "• Emails sent to different aliases arrive in procurement@ inbox"
echo "• Email headers show which alias was used"
echo "• You can reply FROM the alias address (maintains professionalism)"
echo "• Everything organized in one clean inbox"
echo ""

echo "🎯 Test Scenarios:"
echo "=================="
echo "1. Send to info@ - General inquiry test"
echo "2. Send to support@ - Customer service test"
echo "3. Send to sales@ - Sales inquiry test"
echo "4. Send to bryan@ - Personal business test"
echo "5. Send to orders@ - Order management test"
echo ""

echo "📊 Success Criteria:"
echo "==================="
echo "✅ All test emails arrive in procurement@freshthreadsllc.com"
echo "✅ Email headers show correct alias recipients"
echo "✅ You can reply FROM the alias addresses"
echo "✅ Professional appearance maintained"
echo ""

echo "🚀 Ready to test? Pick any method above and send a few test emails!"
echo "Then check your procurement@freshthreadsllc.com inbox to see the magic! ✨"
