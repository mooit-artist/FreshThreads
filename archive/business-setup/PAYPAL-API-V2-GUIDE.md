# PayPal API v2 Integration Guide - FreshThreads LLC

## 🚀 Using Your PayPal Developer ID with Latest API Specifications

Based on the official PayPal REST API specifications from:

- 📋 **Repository**: <https://github.com/paypal/paypal-rest-api-specifications>
- 🔐 **Authentication**: <https://developer.paypal.com/api/rest/authentication/>
- 📚 **Developer Docs**: <https://developer.paypal.com/api/rest/>

---

## 🔑 Quick Setup with Your Developer ID

### Step 1: Interactive Configuration

```bash
python3 scripts/paypal_developer_setup.py
```

This will guide you through:

- ✅ **OAuth 2.0 Setup** - Latest authentication standard
- ✅ **API v2 Configuration** - Orders, Payments, Webhooks
- ✅ **Real Credential Testing** - Verify your Developer ID works
- ✅ **Business Settings** - FreshThreads LLC configuration

### Step 2: Test Latest API v2 Integration

```bash
python3 scripts/paypal_v2_api_integration.py --action test
```

### Step 3: Create Test Order (Orders API v2)

```bash
python3 scripts/paypal_v2_api_integration.py --action create-order
```

---

## 📋 What's New in API v2

### 🔐 OAuth 2.0 Authentication

- **Bearer Token**: More secure than previous methods
- **Base64 Encoding**: `CLIENT_ID:CLIENT_SECRET` encoded properly
- **Auto Token Refresh**: Handles expiration automatically
- **Endpoint**: `https://api-m.sandbox.paypal.com/v1/oauth2/token`

### 📦 Orders API v2

- **Enhanced Order Creation**: Better item handling
- **Real-time Status**: Immediate order tracking
- **Mobile Optimized**: Perfect mobile checkout
- **Endpoint**: `https://api-m.sandbox.paypal.com/v2/checkout/orders`

### 💳 Payments API v2

- **Advanced Capture**: Improved payment processing
- **Refund Management**: Better refund handling
- **Fraud Protection**: Enhanced security
- **Endpoint**: `https://api-m.sandbox.paypal.com/v2/payments/captures`

### 🔗 Webhooks Management v1

- **Real-time Events**: Instant notifications
- **Event Types**: Latest webhook events
- **Signature Verification**: Enhanced security
- **Endpoint**: `https://api-m.sandbox.paypal.com/v1/notifications/webhooks`

---

## 🏪 FreshThreads Business Configuration

### Your Business Details

```bash
Business Name: FreshThreads LLC
Business Email: bryan@freshthreadsllc.com
Website: https://freshthreadsllc.com
Environment: Sandbox → Live (when ready)
```

### API v2 Endpoints (Sandbox)

```bash
Auth: https://api-m.sandbox.paypal.com/v1/oauth2/token
Orders: https://api-m.sandbox.paypal.com/v2/checkout/orders
Payments: https://api-m.sandbox.paypal.com/v2/payments/captures
Webhooks: https://api-m.sandbox.paypal.com/v1/notifications/webhooks
```

---

## 🧪 Testing Your Developer ID

### 1. Authentication Test

```bash
# Tests OAuth 2.0 Bearer token generation
python3 scripts/paypal_v2_api_integration.py --environment sandbox --action test
```

**Expected Output:**

```
✅ PayPal API v2 connection test passed
Environment: sandbox
Base URL: https://api-m.sandbox.paypal.com
Business: FreshThreads LLC
```

### 2. Order Creation Test

```bash
# Tests Orders API v2 with FreshThreads products
python3 scripts/paypal_v2_api_integration.py --environment sandbox --action create-order
```

**Expected Output:**

```
✅ Order created successfully!
Order ID: 8AB12345CD678901E
Total: $139.97 USD
Approval URL: https://www.sandbox.paypal.com/checkoutnow?token=...
```

### 3. Webhook Test

```bash
# Tests Webhooks Management v1 API
python3 scripts/paypal_v2_api_integration.py --environment sandbox --action webhook
```

---

## 🔗 Developer Dashboard Setup

### 1. Get Your Credentials

1. **Visit**: <https://developer.paypal.com/developer/applications/>
2. **Sign in** with your PayPal Developer account
3. **Select** your FreshThreads application (or create new)
4. **Copy** your Client ID and Client Secret

### 2. Webhook Configuration

1. **Click** "Add Webhook" in your app dashboard
2. **URL**: `https://freshthreadsllc.com/api/paypal/webhook`
3. **Select Events**:
   - `CHECKOUT.ORDER.APPROVED`
   - `CHECKOUT.ORDER.COMPLETED`
   - `PAYMENT.CAPTURE.COMPLETED`
   - `PAYMENT.CAPTURE.DENIED`
   - `CHECKOUT.ORDER.VOIDED`
4. **Save** and copy the Webhook ID

---

## 🛍️ Customer Experience

### Professional Checkout

- **FreshThreads Branding**: Your business name and logo
- **Mobile Optimized**: Perfect on all devices
- **Secure Processing**: PayPal's fraud protection
- **International**: Accept payments worldwide

### Order Flow

1. **Customer** adds FreshThreads items to cart
2. **PayPal** handles secure payment processing
3. **Webhooks** notify you in real-time
4. **Email** confirmations sent automatically
5. **Dashboard** updates with order details

---

## 🚀 Production Deployment

### Sandbox to Live Migration

1. **Test thoroughly** in sandbox environment
2. **Update config**: `PAYPAL_ENVIRONMENT=live`
3. **Get live credentials** from PayPal Developer Dashboard
4. **Update webhook URL** to your live domain
5. **Enable SSL** certificates for security
6. **Monitor transactions** in PayPal Business account

### Security Checklist

- ✅ **SSL Certificates** - HTTPS everywhere
- ✅ **Webhook Verification** - Signature validation
- ✅ **Token Security** - Never expose Client Secret
- ✅ **Environment Variables** - Secure credential storage
- ✅ **Error Handling** - Graceful failure management

---

## 📊 Business Benefits

### For FreshThreads LLC

- 🛡️ **PayPal Protection** - Seller and buyer protection
- 🌍 **Global Reach** - Accept international payments
- 📱 **Mobile Ready** - Perfect mobile experience
- 📈 **Analytics** - Detailed transaction reporting
- ⚡ **Real-time** - Instant payment notifications
- 🔒 **Security** - Industry-leading fraud protection

### Customer Trust

- 💳 **Trusted Brand** - PayPal recognition
- 🔐 **Secure Checkout** - No credit card data stored
- 📱 **Easy Mobile** - One-touch payments
- 🌐 **Global Access** - Pay from anywhere
- 🛡️ **Buyer Protection** - PayPal guarantees

---

## 📞 Support & Resources

### PayPal Developer Support

- 📚 **Documentation**: <https://developer.paypal.com/api/rest/>
- 🔧 **API Reference**: <https://developer.paypal.com/reference/>
- 🐛 **Issues**: <https://github.com/paypal/paypal-rest-api-specifications/issues>
- 💬 **Community**: PayPal Developer Community

### FreshThreads Integration

- 📁 **Config**: `config/paypal-config.env`
- 📝 **Logs**: `logs/paypal/paypal-v2-*.log`
- 🔧 **Scripts**: `scripts/paypal_v2_api_integration.py`
- 🌐 **Checkout**: `docs/paypal-checkout.html`

---

**🎉 Ready to accept payments for FreshThreads LLC!**

Your PayPal Developer ID + Latest API v2 = Professional e-commerce solution!
