# FreshThreads - Known Issues

_Last Updated: August 25, 2025_

## 🐛 Active Issues

### 1. T-shirt Images Not Displaying Correctly

**Status:** 🔴 Critical
**Location:** `docs/products.html` - Printify product rendering
**Description:**

- Printify API images are not rendering properly in product cards
- Image URLs from Printify may have CORS issues or incorrect formatting
- Currently falling back to Fresh Threads logo placeholder
- Product data shows image URLs but they don't load in browser

**Investigation Needed:**

- Check Printify CDN CORS configuration
- Verify image URL format from API response
- Test image loading with different approaches (proxy, direct, etc.)
- Review CSP settings for image sources

**Files Affected:**

- `docs/products.html` (lines ~940, product normalization)
- Image handling in renderProducts function

---

### 2. Shopping Cart Close But Not Ready

**Status:** 🟡 In Progress
**Location:** `docs/products.html` - Cart functionality
**Description:**

- Cart UI and basic functionality implemented with FreshThreadsCart
- Add to cart buttons exist but final integration needs testing
- Cart persistence, calculations, and checkout flow need verification
- Modal/sidebar behavior requires refinement

**TODO:**

- [ ] Test add to cart functionality with real products
- [ ] Verify cart persistence across page loads
- [ ] Test cart calculations and pricing
- [ ] Complete checkout flow integration
- [ ] Test cart modal/sidebar UX

**Files Affected:**

- `docs/products.html` (cart integration)
- `docs/assets/cart.js` (FreshThreadsCart implementation)
- `docs/cart.html` (dedicated cart page)

---

## ✅ Recently Fixed

### Product Filtering & Sorting

**Fixed:** August 25, 2025
**Issue:** Sort by price and price range filters not working
**Solution:** Normalized Printify product data structure to include proper numeric price fields for filtering

---

## 📋 Development Notes

### Working Features

- ✅ Product filtering by price range
- ✅ Product sorting by price/popularity
- ✅ Search functionality
- ✅ Responsive design
- ✅ Navigation and basic UI
- ✅ Printify API integration (data fetching)

### Architecture Notes

- Using FreshThreadsCart for cart management
- Printify products normalized to standard product structure
- Filtering works on unified product array regardless of source
- Fallback system for when API is unavailable

### Testing Checklist

- [ ] Printify image display
- [ ] Complete cart workflow
- [ ] Checkout integration
- [ ] Mobile responsiveness
- [ ] Performance optimization
- [ ] Error handling edge cases
