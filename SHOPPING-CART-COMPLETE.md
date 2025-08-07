# FreshThreads Shopping Cart System 🛒

## Overview

A complete shopping cart system integrated with PayPal Express Checkout for the FreshThreads LLC website. The system provides a seamless e-commerce experience with secure payment processing.

## Features ✨

### 🛒 Shopping Cart Functionality

- **Persistent Cart**: Items saved in localStorage across sessions
- **Real-time Updates**: Live cart badge and totals
- **Quantity Management**: Increase/decrease item quantities
- **Item Removal**: Easy product removal from cart
- **Size & Color Options**: Product variations support
- **Responsive Design**: Works on all devices

### 💳 PayPal Integration

- **Express Checkout**: Quick PayPal payment processing
- **Real PayPal Credentials**: Production-ready with sandbox/live switching
- **Order Tracking**: Complete order management
- **Secure Processing**: PCI-compliant payment handling

### 🎨 User Experience

- **Slide-out Cart**: Elegant sidebar cart interface
- **Add to Cart Animations**: Visual feedback for user actions
- **Toast Notifications**: Success messages for cart updates
- **Empty Cart State**: Helpful messaging when cart is empty
- **Loading States**: Smooth transitions and feedback

## File Structure 📁

```
docs/
├── cart.html                 # Dedicated cart page
├── order-success.html        # Order confirmation page
├── styles/
│   └── cart.css              # Shopping cart styles
├── assets/
│   └── cart.js               # Shopping cart JavaScript
└── index.html                # Updated with cart integration
└── products.html             # Updated with cart integration
```

## Implementation Details 🔧

### Cart.js - Main Cart System

```javascript
class FreshThreadsCart {
  constructor() {
    this.items = this.loadCart();
    this.isOpen = false;
    this.paypalLoaded = false;
    this.init();
  }
}
```

**Key Methods:**

- `addToCart(product, quantity)` - Add items to cart
- `removeFromCart(itemId, size, color)` - Remove items
- `updateQuantity(itemId, size, color, newQuantity)` - Update quantities
- `toggleCart()` - Open/close cart sidebar
- `updatePayPalButton()` - Refresh PayPal integration

### Product Integration

Products automatically get "Add to Cart" buttons with proper data attributes:

```html
<button
  class="add-to-cart-btn"
  data-product-id="product-123"
  data-product-name="Premium T-Shirt"
  data-product-price="25.99"
  data-product-image="path/to/image.jpg"
>
  🛒 Add to Cart
</button>
```

### PayPal Configuration

Using real PayPal credentials from GitHub Secrets:

- **Client ID**: Production PayPal app ID
- **Environment**: Sandbox for testing, Live for production
- **Currency**: USD
- **Intent**: Capture (immediate payment)

## Pages 📄

### 1. Main Site (index.html, products.html)

- Cart icon in header with item count badge
- Product cards with "Add to Cart" buttons
- Sliding cart sidebar
- Quick add notifications

### 2. Dedicated Cart Page (cart.html)

- Full cart review interface
- Item management (quantity, removal)
- Order summary with shipping calculation
- PayPal checkout integration
- Responsive design for mobile

### 3. Order Success Page (order-success.html)

- Order confirmation display
- Payment success messaging
- Order details from localStorage
- Next steps information
- Cart clearing functionality

## Styling 🎨

### CSS Variables

```css
:root {
  --primary-color: #1a1a1a;
  --secondary-color: #ff6b35;
  --accent-color: #4a90e2;
  --success-color: #28a745;
  --border-radius: 8px;
  --box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  --transition: all 0.3s ease;
}
```

### Key Components

- **Cart Sidebar**: Fixed position slide-out interface
- **Cart Badge**: Animated notification bubble
- **Product Cards**: Enhanced with cart buttons
- **Notifications**: Toast-style success messages
- **Mobile Responsive**: Optimized for all screen sizes

## Usage 🚀

### For Developers

1. **Include Cart Assets**:

   ```html
   <link rel="stylesheet" href="styles/cart.css" />
   <script src="assets/cart.js"></script>
   ```

2. **Initialize Cart**:

   ```javascript
   // Cart initializes automatically on DOMContentLoaded
   window.freshThreadsCart = new FreshThreadsCart();
   ```

3. **Add Products**:
   ```javascript
   // Manual addition
   freshThreadsCart.addToCart({
     id: 'product-123',
     name: 'Premium T-Shirt',
     price: 25.99,
     image: 'path/to/image.jpg',
     size: 'M',
     color: 'Black',
   });
   ```

### For Content Creators

1. **Product Setup**: Ensure products have proper data attributes
2. **Image URLs**: Use relative paths from docs/ directory
3. **Pricing**: Use decimal format (25.99, not $25.99)
4. **Sizes**: Provide array of available sizes

## PayPal Integration 💰

### Credentials Setup

PayPal credentials are managed via GitHub Secrets:

```bash
PAYPAL_CLIENT_ID=AUIlZ3WG9CHyHlQVfHRaZKr2RvzJFw35h4A6LN-7iYS8_k-U88n8rh-BLqCQa2XGv8v1LZQj8I8bKxVi
PAYPAL_CLIENT_SECRET=<secret>
PAYPAL_ENVIRONMENT=sandbox  # or 'live' for production
```

### Order Flow

1. **Add to Cart**: Customer adds items to shopping cart
2. **Review Cart**: Customer reviews items in cart.html
3. **PayPal Checkout**: Customer clicks PayPal button
4. **Payment Processing**: PayPal handles secure payment
5. **Order Confirmation**: Customer redirected to order-success.html
6. **Order Completion**: Cart cleared, confirmation displayed

### Order Structure

```javascript
{
  purchase_units: [
    {
      amount: {
        value: '31.98',
        currency_code: 'USD',
        breakdown: {
          item_total: { value: '25.99' },
          shipping: { value: '5.99' },
        },
      },
      items: [
        {
          name: 'Premium T-Shirt (M, Black)',
          unit_amount: { value: '25.99' },
          quantity: '1',
          category: 'PHYSICAL_GOODS',
        },
      ],
    },
  ];
}
```

## Security 🔒

### Content Security Policy

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self';
               script-src 'self' 'unsafe-inline' https://www.paypal.com;
               connect-src 'self' https://api-m.sandbox.paypal.com;"
/>
```

### Data Protection

- **No PCI Compliance Required**: PayPal handles all payment data
- **Local Storage Only**: Cart data stored locally, not transmitted
- **HTTPS Required**: All PayPal integrations require secure connections
- **Secret Management**: PayPal credentials in GitHub Secrets

## Testing 🧪

### Manual Testing

1. **Add Items**: Test adding products from products.html
2. **Cart Management**: Test quantity changes, removals
3. **Checkout Flow**: Complete PayPal sandbox transactions
4. **Mobile Experience**: Test responsive design
5. **Error Handling**: Test edge cases (empty cart, network issues)

### Test Credentials

- **Sandbox Account**: Use PayPal sandbox for testing
- **Test Cards**: PayPal provides test payment methods
- **Order IDs**: Test orders generate real PayPal order IDs

### Browser Testing

- **Chrome/Safari**: Primary testing browsers
- **Mobile Safari**: iOS testing
- **Chrome Mobile**: Android testing
- **Local Storage**: Cross-browser persistence testing

## Deployment 🚀

### Production Checklist

- [ ] Switch PayPal from sandbox to live environment
- [ ] Update PayPal Client ID in GitHub Secrets
- [ ] Test live payment processing
- [ ] Verify HTTPS certificate
- [ ] Test mobile responsiveness
- [ ] Validate CSP headers
- [ ] Monitor error tracking

### GitHub Actions Integration

The cart system works seamlessly with the existing GitHub Actions deployment:

```yaml
env:
  PAYPAL_CLIENT_ID: ${{ secrets.PAYPAL_CLIENT_ID }}
  PAYPAL_CLIENT_SECRET: ${{ secrets.PAYPAL_CLIENT_SECRET }}
  PAYPAL_ENVIRONMENT: ${{ secrets.PAYPAL_ENVIRONMENT }}
```

## Analytics & Tracking 📊

### Conversion Tracking

```javascript
// Google Analytics 4
gtag('event', 'purchase', {
  transaction_id: orderId,
  value: total,
  currency: 'USD',
  items: cartItems,
});

// Facebook Pixel
fbq('track', 'Purchase', {
  value: total,
  currency: 'USD',
});
```

### Key Metrics

- **Cart Abandonment Rate**: Track incomplete checkouts
- **Average Order Value**: Monitor cart totals
- **Conversion Rate**: Cart to purchase ratio
- **Popular Products**: Most added items

## Troubleshooting 🛠️

### Common Issues

1. **PayPal Button Not Loading**
   - Check internet connection
   - Verify CSP allows PayPal domains
   - Confirm client ID is correct

2. **Cart Not Persisting**
   - Check localStorage availability
   - Verify browser privacy settings
   - Clear corrupted cart data

3. **Mobile Cart Issues**
   - Test viewport meta tag
   - Verify touch interactions
   - Check responsive CSS

### Debug Mode

```javascript
// Enable cart debugging
localStorage.setItem('cart_debug', 'true');
// Check console for detailed logging
```

## Future Enhancements 🔮

### Planned Features

- **Guest Checkout**: Complete without account
- **Shipping Calculator**: Real-time shipping rates
- **Discount Codes**: Promotional pricing
- **Wishlist Integration**: Save for later functionality
- **Product Reviews**: Customer feedback system
- **Inventory Management**: Stock tracking
- **Email Notifications**: Order confirmations

### Advanced Features

- **Multi-currency Support**: International sales
- **Subscription Products**: Recurring payments
- **B2B Pricing**: Volume discounts
- **Advanced Analytics**: Conversion tracking
- **A/B Testing**: Cart optimization

## Support 📞

### Developer Support

- **Documentation**: This README file
- **Code Comments**: Inline documentation
- **Error Logging**: Console error tracking
- **GitHub Issues**: Bug reporting

### Customer Support

- **Order Issues**: orders@freshthreadsllc.com
- **Payment Problems**: Contact PayPal support
- **Website Issues**: Report via GitHub Issues

---

## Quick Start 🚀

1. **Clone Repository**
2. **Start Development Server**: `npm run dev` or use VS Code Live Server
3. **Visit Products**: Navigate to products.html
4. **Add Items**: Click "Add to Cart" on any product
5. **View Cart**: Click cart icon in header
6. **Test Checkout**: Use PayPal sandbox for testing

Your FreshThreads shopping cart is now ready for business! 🎉
