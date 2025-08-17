# 🏪 Printify Store Setup Guide

## Quick Answer: Can I Create Stores via API?

**No, you cannot create Printify stores via API.** You must create stores through the Printify dashboard first. However, once created, you can manage them fully via API.

## Complete Setup Process

### Step 1: Create Your Printify Account

1. Go to [printify.com](https://printify.com)
2. Click "Sign up" and create your account
3. Verify your email address
4. Complete your profile setup

### Step 2: Create an API Store

1. **Navigate to Store Management:**
   - Log into your Printify dashboard
   - Go to "My Stores" from the main menu
   - Click "Connect a new store"

2. **Select API Integration:**
   - You'll see options like Shopify, Etsy, WooCommerce, etc.
   - **Choose "API" from the list**
   - Click "Connect" on the API option

3. **Configure Your API Store:**
   - Give your store a meaningful name (e.g., "FreshThreads API Store")
   - This will be your main integration point

### Step 3: Get Your Shop ID

1. **From Store Dashboard:**
   - After creating the store, go to your store dashboard
   - Look at the URL in your browser
   - It will look like: `https://printify.com/app/stores/123456/products`
   - The number `123456` is your **Shop ID**

2. **Alternative Method:**
   - Use the API endpoint `/v1/shops.json` to list all your stores
   - Find the store you just created and note its `id` field

### Step 4: Generate API Key

1. **Access API Settings:**
   - Go to your Printify account settings
   - Find the "API" or "Developer" section
   - Click "Create Personal Access Token"

2. **Set Proper Scopes:**
   Select these permissions for your API key:
   - `shops:read` - View store information
   - `shops:write` - Manage store settings
   - `products:read` - View products
   - `products:write` - Create and modify products
   - `orders:read` - View orders
   - `orders:write` - Create and manage orders

3. **Save Your Token:**
   - Copy the generated token immediately
   - Store it securely (you won't see it again)

### Step 5: Configure Your Integration

1. **Update config.js:**

   ```javascript
   window.podConfig = {
     printifyApiKey: 'your_actual_api_key_here',
     printifyShopId: 'your_shop_id_here',
     // ... other settings
   };
   ```

2. **Test Your Connection:**
   - Open `pod-admin.html` in your browser
   - Click "Check Configuration"
   - Click "Test Connections"
   - Verify you see "Connected and Ready"

## Store Management via API

Once set up, you can manage your stores programmatically:

### List All Your Stores

```javascript
const stores = await podManager.getStores();
console.log(stores);
```

### Get Store Details

```javascript
const storeDetails = await podManager.getStoreDetails('your_shop_id');
console.log(`Store: ${storeDetails.title}`);
console.log(`Sales Channel: ${storeDetails.sales_channel}`);
```

### Disconnect a Store (Careful!)

```javascript
// This will disconnect the store from Printify
await podManager.disconnectStore('your_shop_id');
```

## Important API Limitations

### What You CAN Do

✅ Manage existing stores
✅ Create and manage products
✅ Process orders
✅ Upload images
✅ Set up webhooks
✅ Access catalog data

### What You CANNOT Do

❌ Create new stores
❌ Delete stores completely
❌ Change store ownership
❌ Access billing information

## Best Practices

### Security

- Never commit API keys to version control
- Use environment variables in production
- Rotate API keys periodically
- Limit API key scopes to what you need

### Development

- Test with a dedicated development store
- Use the POD admin interface for debugging
- Monitor API rate limits (600 requests/minute)
- Implement proper error handling

### Production

- Use HTTPS for all API calls
- Implement webhook validation
- Set up proper logging
- Have fallback strategies for API failures

## Troubleshooting Common Issues

### "Shop ID not found"

- Double-check the Shop ID from your store URL
- Ensure the store is an API store, not a connected sales channel
- Verify your API key has `shops:read` permission

### "Invalid API Key"

- Regenerate your API key with proper scopes
- Check for extra spaces or characters
- Ensure the key hasn't expired

### "Connection Failed"

- Check your internet connection
- Verify Printify's API status
- Confirm you're using the correct API URL (`https://api.printify.com/v1`)

### Rate Limiting

- Implement proper delays between requests
- Use exponential backoff for retries
- Monitor the rate limit headers in responses

## Multiple Stores Setup

You can have multiple stores in one Printify account:

1. **Create separate API stores** for different purposes:
   - Development store
   - Production store
   - Test store for experiments

2. **Manage multiple stores in code:**

   ```javascript
   const stores = {
     dev: { apiKey: 'dev_key', shopId: 'dev_shop_id' },
     prod: { apiKey: 'prod_key', shopId: 'prod_shop_id' },
   };

   const devManager = new PrintOnDemandManager(stores.dev);
   const prodManager = new PrintOnDemandManager(stores.prod);
   ```

## Next Steps

Once your store is set up:

1. **Test the integration** using the POD admin interface
2. **Create your first product** via API
3. **Set up webhooks** for real-time notifications
4. **Implement order processing** in your application
5. **Configure product templates** for different product types

## Support Resources

- **Printify Developer Docs:** <https://developers.printify.com>
- **API Postman Collection:** Available in the developer docs
- **Help Center:** <https://help.printify.com>
- **Community Forum:** Available through Printify dashboard

---

**Remember:** Store creation must be done manually through the Printify dashboard, but everything else can be automated via API! 🚀
