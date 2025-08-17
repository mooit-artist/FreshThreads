# PayPal Developer Setup Guide - FreshThreads LLC

## 🔑 Using Your PayPal Developer ID

Since you have a PayPal Developer ID, here's how to set up the real PayPal integration for FreshThreads:

### 1. 🚀 Quick Setup (Interactive)

```bash
python scripts/paypal_developer_setup.py
```

This interactive script will:

- Guide you through credential setup
- Configure your PayPal Developer credentials
- Update the web integration with your Client ID
- Test the connection
- Set up webhooks

### 2. 📋 Manual Configuration

If you prefer to configure manually, edit `config/paypal-config.env`:

```bash
# Your actual PayPal credentials
PAYPAL_CLIENT_ID=your_actual_client_id_from_developer_paypal_com
PAYPAL_CLIENT_SECRET=your_actual_client_secret_from_developer_paypal_com
PAYPAL_ENVIRONMENT=sandbox  # or "live" for production

# Your business details
PAYPAL_BUSINESS_EMAIL=bryan@freshthreadsllc.com
BUSINESS_NAME=FreshThreads LLC
BUSINESS_WEBSITE=https://freshthreadsllc.com
```

### 3. 🌐 Get Your PayPal Credentials

1. **Visit:** <https://developer.paypal.com/developer/applications/>
2. **Sign in** with your PayPal Developer account
3. **Create App** or select existing FreshThreads app
4. **Copy:**
   - Client ID
   - Client Secret
5. **Environment:** Choose Sandbox (testing) or Live (production)

### 4. 🔗 Set Up Webhooks

1. In your PayPal app dashboard, click **Add Webhook**
2. **Webhook URL:** `https://freshthreadsllc.com/api/paypal/webhook`
3. **Select Events:**
   - `PAYMENT.SALE.COMPLETED`
   - `PAYMENT.SALE.DENIED`
   - `INVOICING.INVOICE.PAID`
   - `INVOICING.INVOICE.CANCELLED`
4. **Save** and copy the Webhook ID

### 5. ✅ Test Your Integration

```bash
# Test with real credentials
python scripts/paypal_business_automation.py --action test

# Start webhook server
python scripts/paypal_webhook_handler.py

# View your checkout page
open docs/paypal-checkout.html
```

### 6. 🛍️ What You'll Get

With your PayPal Developer ID configured:

- **Real PayPal Integration** - Live payment processing
- **Professional Checkout** - FreshThreads branded experience
- **Real-time Notifications** - Instant order alerts
- **Business Dashboard** - PayPal business account integration
- **International Payments** - Accept payments worldwide
- **Mobile Optimized** - Perfect mobile checkout experience

### 7. 🔐 Security Notes

- Keep your Client Secret secure (never commit to git)
- Use Sandbox for testing, Live for production
- Webhook URL should be HTTPS in production
- Test thoroughly in sandbox before going live

### 8. 📊 Business Benefits

- **Professional Payment Processing** - PayPal's trusted platform
- **Fraud Protection** - Built-in security measures
- **Seller Protection** - PayPal business guarantees
- **Analytics** - Detailed transaction reporting
- **Customer Trust** - PayPal brand recognition

---

**Ready to accept real payments for FreshThreads! 💳🛍️**
