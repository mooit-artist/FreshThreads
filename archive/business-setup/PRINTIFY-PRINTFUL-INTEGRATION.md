# Print-on-Demand Integration Guide

## Overview

This guide will help you integrate Printify and Printful with your FreshThreads website. Both are print-on-demand services that can automatically handle product creation, printing, and fulfillment.

## Getting Started

### 1. Set up Your Accounts

**Printify:**

1. Go to [https://printify.com](https://printify.com)
2. Create an account and verify your email
3. Set up a store (choose "API" as the platform)
4. Get your API key from Settings > API
5. Note your Shop ID (found in your dashboard URL)

**Printful:**

1. Go to [https://printful.com](https://printful.com)
2. Create an account and verify your email
3. Go to Settings > API and generate an API key
4. Set up your store details

### 2. Configure Your Environment

1. Copy `.env.example` to `.env`:

   ```bash
   cp docs/.env.example docs/.env
   ```

2. Edit `.env` and add your API keys:

   ```
   PRINTIFY_API_KEY=your_actual_printify_api_key
   PRINTIFY_SHOP_ID=your_shop_id_from_printify
   PRINTFUL_API_KEY=your_actual_printful_api_key
   ```

### 3. Test the Integration

1. Open `pod-admin.html` in your browser
2. Check that both providers show as "Connected"
3. Try fetching products from both providers
4. Create a test product to verify everything works

## How It Works

### Product Flow

1. **Local Products**: Your products are defined in `products-config.json`
2. **POD Sync**: Products are automatically synced to Printify/Printful
3. **Orders**: When customers order, orders are sent to the appropriate POD provider
4. **Fulfillment**: The POD provider prints and ships the product

### Architecture

- `print-on-demand.js`: Main API integration class
- `pod-templates.js`: Product templates and mappings
- `products.html`: Enhanced with POD integration
- `pod-admin.html`: Admin interface for managing POD integration

## API Integration Details

### Printify Integration

**Key Features:**

- Create products with designs
- Manage variants (sizes, colors)
- Submit orders for fulfillment
- Track order status
- Webhook support for updates

**Product Creation Example:**

```javascript
const productData = {
  title: 'Fresh Threads Logo Tee',
  description: 'Premium cotton t-shirt',
  blueprint_id: 5, // T-shirt blueprint
  print_provider_id: 1, // Provider ID
  variants: [
    {
      id: 1,
      price: 2499, // Price in cents
      is_enabled: true,
    },
  ],
};

const result = await podManager.createPrintifyProduct(productData);
```

### Printful Integration

**Key Features:**

- Sync products with your store
- Automatic order fulfillment
- Product mockup generation
- Shipping calculations
- Quality control

**Product Creation Example:**

```javascript
const productData = {
  sync_product: {
    name: 'Fresh Threads Logo Tee',
    thumbnail: 'https://example.com/image.jpg',
  },
  sync_variants: [
    {
      retail_price: '24.99',
      variant_id: 4011, // Printful product variant
      files: [
        {
          type: 'front',
          url: 'https://example.com/design.png',
        },
      ],
    },
  ],
};

const result = await podManager.createPrintfulProduct(productData);
```

## Product Templates

### Available Templates

**T-Shirts (Short Sleeve):**

- Printify Blueprint ID: 5
- Printful Product ID: 71 (Bella + Canvas 3001)
- Supported sizes: XS-XXL
- Common colors: Black, White, Navy, Gray

**Long Sleeve T-Shirts:**

- Printify Blueprint ID: 6
- Printful Product ID: 146 (Bella + Canvas 3501)
- Supported sizes: XS-XXL
- Common colors: Black, White, Navy, Gray

### Customizing Templates

Edit `pod-templates.js` to:

- Add new product types
- Modify size/color options
- Change pricing strategies
- Update design placement

## Order Management

### Order Flow

1. Customer places order on your website
2. Order data is sent to POD provider
3. Provider prints and ships the product
4. Tracking information is provided
5. Customer receives the product

### Order Status Tracking

Both providers offer webhooks for real-time order updates:

- Order received
- In production
- Shipped
- Delivered
- Issues/cancellations

## Design Management

### Image Requirements

**Printify:**

- Format: PNG, JPG, PDF
- Max size: 50MB
- DPI: 300+ recommended
- Color mode: RGB

**Printful:**

- Format: PNG, JPG, PDF
- Max size: 20MB
- DPI: 300 recommended
- Color mode: RGB

### Design Upload Process

1. Upload designs to your server
2. Reference design URLs in product creation
3. POD provider downloads and applies designs
4. Mockups are generated automatically

## Testing

### Test Mode

Both providers offer test modes:

- Create test products
- Submit test orders
- Verify integration works
- No actual printing/shipping

### Quality Assurance

1. Order test products for yourself
2. Check print quality and sizing
3. Verify shipping times
4. Test customer service experience

## Production Deployment

### Checklist

- [ ] API keys configured
- [ ] Products synced successfully
- [ ] Test orders completed
- [ ] Webhooks configured
- [ ] Payment processing integrated
- [ ] Customer notifications set up
- [ ] Error handling implemented

### Monitoring

- Set up logging for API calls
- Monitor order success rates
- Track customer satisfaction
- Review fulfillment times

## Common Issues & Solutions

### API Connection Issues

- Verify API keys are correct
- Check rate limiting (both providers have limits)
- Ensure proper error handling
- Monitor API status pages

### Product Sync Issues

- Validate product data before syncing
- Check image URLs are accessible
- Verify size/color mappings
- Review provider-specific requirements

### Order Issues

- Implement retry logic for failed orders
- Set up error notifications
- Have manual fallback process
- Monitor order status webhooks

## Cost Considerations

### Printify Costs

- No monthly fees
- Per-product base costs
- Shipping costs
- Optional premium features

### Printful Costs

- No setup fees
- Per-product base costs
- Shipping costs
- Optional services (faster production)

### Profit Margins

- Calculate base cost + shipping
- Add your desired profit margin
- Consider competitor pricing
- Factor in returns/exchanges

## Support Resources

### Documentation

- [Printify API Docs](https://developers.printify.com/)
- [Printful API Docs](https://developers.printful.com/)

### Community

- Printify Facebook groups
- Printful Discord community
- Reddit communities

### Professional Help

- Both providers offer customer support
- Consider hiring a developer for complex integrations
- FreshThreads support team available

## Next Steps

1. **Set up accounts** with both providers
2. **Configure API keys** in your .env file
3. **Test the integration** using the admin interface
4. **Create your first products** and sync them
5. **Place test orders** to verify everything works
6. **Go live** and start selling!

---

Need help? Check the admin interface at `pod-admin.html` for real-time status and debugging tools.
