/**
 * FreshThreads Shopping Cart System
 * Integrated with PayPal Express Checkout
 */

class FreshThreadsCart {
    constructor() {
        this.items = this.loadCart();
        this.isOpen = false;
        this.paypalLoaded = false;
        this.init();
    }

    init() {
        this.createCartHTML();
        this.bindEvents();
        this.updateCartDisplay();
        this.loadPayPalSDK();
    }

    createCartHTML() {
        // Create cart icon in header
        const header = document.querySelector('header') || document.querySelector('nav') || document.body;
        const cartContainer = document.createElement('div');
        cartContainer.className = 'cart-container';
        cartContainer.innerHTML = `
            <button class="cart-icon" aria-label="Shopping Cart">
                🛒
                <span class="cart-badge" style="display: none;">0</span>
            </button>
        `;
        header.appendChild(cartContainer);

        // Create cart sidebar
        const cartSidebar = document.createElement('div');
        cartSidebar.className = 'cart-sidebar';
        cartSidebar.innerHTML = `
            <div class="cart-header">
                <h3 class="cart-title">Shopping Cart</h3>
                <button class="cart-close">&times;</button>
            </div>
            <div class="cart-items"></div>
            <div class="cart-footer">
                <div class="cart-summary">
                    <div class="cart-summary-row">
                        <span>Subtotal:</span>
                        <span class="cart-subtotal">$0.00</span>
                    </div>
                    <div class="cart-summary-row">
                        <span>Shipping:</span>
                        <span class="cart-shipping">$5.99</span>
                    </div>
                    <div class="cart-summary-row total">
                        <span>Total:</span>
                        <span class="cart-total">$5.99</span>
                    </div>
                </div>
                <div class="cart-actions">
                    <div class="paypal-button-container loading"></div>
                    <a href="#" class="cart-btn cart-btn-secondary" id="continue-shopping">Continue Shopping</a>
                </div>
            </div>
        `;
        document.body.appendChild(cartSidebar);

        // Create overlay
        const overlay = document.createElement('div');
        overlay.className = 'cart-overlay';
        document.body.appendChild(overlay);

        // Store references
        this.cartIcon = cartContainer.querySelector('.cart-icon');
        this.cartBadge = cartContainer.querySelector('.cart-badge');
        this.cartSidebar = cartSidebar;
        this.cartOverlay = overlay;
        this.cartItems = cartSidebar.querySelector('.cart-items');
        this.cartSubtotal = cartSidebar.querySelector('.cart-subtotal');
        this.cartShipping = cartSidebar.querySelector('.cart-shipping');
        this.cartTotal = cartSidebar.querySelector('.cart-total');
        this.paypalContainer = cartSidebar.querySelector('.paypal-button-container');
    }

    bindEvents() {
        // Cart icon click
        this.cartIcon.addEventListener('click', () => this.toggleCart());

        // Close cart
        this.cartSidebar.querySelector('.cart-close').addEventListener('click', () => this.closeCart());
        this.cartOverlay.addEventListener('click', () => this.closeCart());

        // Continue shopping
        document.getElementById('continue-shopping').addEventListener('click', (e) => {
            e.preventDefault();
            this.closeCart();
        });

        // Add to cart buttons
        this.bindAddToCartButtons();

        // Escape key to close cart
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isOpen) {
                this.closeCart();
            }
        });
    }

    bindAddToCartButtons() {
        // Find all existing add to cart buttons
        document.querySelectorAll('.add-to-cart-btn, [data-add-to-cart]').forEach(button => {
            if (!button.hasAttribute('data-cart-bound')) {
                button.addEventListener('click', (e) => this.handleAddToCart(e));
                button.setAttribute('data-cart-bound', 'true');
            }
        });

        // Add buttons to product cards if they don't exist
        document.querySelectorAll('.product-card, .product-item').forEach(productCard => {
            if (!productCard.querySelector('.add-to-cart-btn') && !productCard.querySelector('[data-add-to-cart]')) {
                this.addCartButtonToProduct(productCard);
            }
        });
    }

    addCartButtonToProduct(productCard) {
        // Extract product data
        const productData = this.extractProductData(productCard);

        if (productData.id && productData.name && productData.price) {
            const button = document.createElement('button');
            button.className = 'add-to-cart-btn';
            button.innerHTML = '🛒 Add to Cart';
            button.setAttribute('data-add-to-cart', 'true');
            button.setAttribute('data-product-id', productData.id);
            button.setAttribute('data-product-name', productData.name);
            button.setAttribute('data-product-price', productData.price);
            button.setAttribute('data-product-image', productData.image || '');

            // Add to product card
            const actionsContainer = productCard.querySelector('.product-actions') ||
                                   productCard.querySelector('.product-info') ||
                                   productCard;
            actionsContainer.appendChild(button);

            // Bind event
            button.addEventListener('click', (e) => this.handleAddToCart(e));
            button.setAttribute('data-cart-bound', 'true');
        }
    }

    extractProductData(productCard) {
        // Try to extract product data from various sources
        const data = {
            id: productCard.getAttribute('data-product-id') ||
                productCard.querySelector('[data-product-id]')?.getAttribute('data-product-id') ||
                Math.random().toString(36).substr(2, 9),
            name: productCard.getAttribute('data-product-name') ||
                  productCard.querySelector('h3, .product-name, .product-title')?.textContent?.trim() ||
                  'Product',
            price: this.extractPrice(productCard),
            image: productCard.getAttribute('data-product-image') ||
                   productCard.querySelector('img')?.src ||
                   'assets/Fresh_ThreadsLLCLogo.png'
        };

        return data;
    }

    extractPrice(element) {
        // Look for price in various formats
        const priceSelectors = [
            '[data-product-price]',
            '.price',
            '.product-price',
            '.cost'
        ];

        for (const selector of priceSelectors) {
            const priceElement = element.querySelector(selector);
            if (priceElement) {
                const priceText = priceElement.getAttribute('data-product-price') ||
                                priceElement.textContent;
                const match = priceText.match(/[\d,]+\.?\d*/);
                if (match) {
                    return parseFloat(match[0].replace(',', ''));
                }
            }
        }

        return 25.99; // Default price
    }

    handleAddToCart(e) {
        e.preventDefault();
        e.stopPropagation();

        const button = e.target;
        const productData = {
            id: button.getAttribute('data-product-id') ||
                button.closest('[data-product-id]')?.getAttribute('data-product-id') ||
                Math.random().toString(36).substr(2, 9),
            name: button.getAttribute('data-product-name') ||
                  button.closest('.product-card, .product-item')?.querySelector('h3, .product-name')?.textContent?.trim() ||
                  'Product',
            price: parseFloat(button.getAttribute('data-product-price')) ||
                   this.extractPrice(button.closest('.product-card, .product-item')) ||
                   25.99,
            image: button.getAttribute('data-product-image') ||
                   button.closest('.product-card, .product-item')?.querySelector('img')?.src ||
                   'assets/Fresh_ThreadsLLCLogo.png',
            size: button.getAttribute('data-product-size') || 'M',
            color: button.getAttribute('data-product-color') || 'Black'
        };

        this.addToCart(productData);
        this.showAddToCartNotification(productData);

        // Visual feedback
        button.classList.add('added');
        button.innerHTML = '✅ Added!';
        setTimeout(() => {
            button.classList.remove('added');
            button.innerHTML = '🛒 Add to Cart';
        }, 2000);
    }

    addToCart(product, quantity = 1) {
        const existingItem = this.items.find(item =>
            item.id === product.id &&
            item.size === product.size &&
            item.color === product.color
        );

        if (existingItem) {
            existingItem.quantity += quantity;
        } else {
            this.items.push({
                ...product,
                quantity: quantity,
                addedAt: Date.now()
            });
        }

        this.saveCart();
        this.updateCartDisplay();
        this.updatePayPalButton();
    }

    removeFromCart(itemId, size, color) {
        this.items = this.items.filter(item =>
            !(item.id === itemId && item.size === size && item.color === color)
        );
        this.saveCart();
        this.updateCartDisplay();
        this.updatePayPalButton();
    }

    updateQuantity(itemId, size, color, newQuantity) {
        const item = this.items.find(item =>
            item.id === itemId && item.size === size && item.color === color
        );

        if (item) {
            if (newQuantity <= 0) {
                this.removeFromCart(itemId, size, color);
            } else {
                item.quantity = newQuantity;
                this.saveCart();
                this.updateCartDisplay();
                this.updatePayPalButton();
            }
        }
    }

    updateCartDisplay() {
        const itemCount = this.items.reduce((sum, item) => sum + item.quantity, 0);
        const subtotal = this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const shipping = subtotal > 0 ? 5.99 : 0;
        const total = subtotal + shipping;

        // Update badge
        if (itemCount > 0) {
            this.cartBadge.textContent = itemCount;
            this.cartBadge.style.display = 'flex';
        } else {
            this.cartBadge.style.display = 'none';
        }

        // Update totals
        this.cartSubtotal.textContent = `$${subtotal.toFixed(2)}`;
        this.cartShipping.textContent = subtotal > 0 ? `$${shipping.toFixed(2)}` : 'FREE';
        this.cartTotal.textContent = `$${total.toFixed(2)}`;

        // Render items
        this.renderCartItems();
    }

    renderCartItems() {
        if (this.items.length === 0) {
            this.cartItems.innerHTML = `
                <div class="cart-empty">
                    <div class="cart-empty-icon">🛒</div>
                    <div class="cart-empty-text">Your cart is empty</div>
                    <button class="cart-empty-cta" onclick="freshThreadsCart.closeCart()">
                        Continue Shopping
                    </button>
                </div>
            `;
        } else {
            this.cartItems.innerHTML = this.items.map(item => `
                <div class="cart-item" data-item-id="${item.id}-${item.size}-${item.color}">
                    <img src="${item.image}" alt="${item.name}" class="cart-item-image" loading="lazy">
                    <div class="cart-item-details">
                        <div class="cart-item-name">${item.name}</div>
                        <div class="cart-item-options">Size: ${item.size}, Color: ${item.color}</div>
                        <div class="cart-item-price">$${(item.price * item.quantity).toFixed(2)}</div>
                        <div class="cart-item-controls">
                            <div class="quantity-controls">
                                <button class="quantity-btn" onclick="freshThreadsCart.updateQuantity('${item.id}', '${item.size}', '${item.color}', ${item.quantity - 1})" ${item.quantity <= 1 ? 'disabled' : ''}>-</button>
                                <span class="quantity-display">${item.quantity}</span>
                                <button class="quantity-btn" onclick="freshThreadsCart.updateQuantity('${item.id}', '${item.size}', '${item.color}', ${item.quantity + 1})">+</button>
                            </div>
                            <button class="remove-item" onclick="freshThreadsCart.removeFromCart('${item.id}', '${item.size}', '${item.color}')" title="Remove item">🗑️</button>
                        </div>
                    </div>
                </div>
            `).join('');
        }
    }

    toggleCart() {
        if (this.isOpen) {
            this.closeCart();
        } else {
            this.openCart();
        }
    }

    openCart() {
        this.isOpen = true;
        this.cartSidebar.classList.add('open');
        this.cartOverlay.classList.add('active');
        document.body.style.overflow = 'hidden';

        // Re-render PayPal button when cart opens
        setTimeout(() => this.updatePayPalButton(), 100);
    }

    closeCart() {
        this.isOpen = false;
        this.cartSidebar.classList.remove('open');
        this.cartOverlay.classList.remove('active');
        document.body.style.overflow = '';
    }

    showAddToCartNotification(product) {
        // Remove existing notifications
        document.querySelectorAll('.cart-notification').forEach(n => n.remove());

        const notification = document.createElement('div');
        notification.className = 'cart-notification';
        notification.innerHTML = `
            <span class="cart-notification-icon">✅</span>
            <span class="cart-notification-text">${product.name} added to cart!</span>
            <button class="cart-notification-close">&times;</button>
        `;

        document.body.appendChild(notification);

        // Show notification
        setTimeout(() => notification.classList.add('show'), 100);

        // Auto hide after 3 seconds
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 3000);

        // Close button
        notification.querySelector('.cart-notification-close').addEventListener('click', () => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        });
    }

    loadPayPalSDK() {
        if (window.paypal || this.paypalLoaded) return;

        const script = document.createElement('script');
        script.src = 'https://www.paypal.com/sdk/js?client-id=AUIlZ3WG9CHyHlQVfHRaZKr2RvzJFw35h4A6LN-7iYS8_k-U88n8rh-BLqCQa2XGv8v1LZQj8I8bKxVi&currency=USD&intent=capture';
        script.onload = () => {
            this.paypalLoaded = true;
            this.updatePayPalButton();
        };
        script.onerror = () => {
            console.error('Failed to load PayPal SDK');
            this.paypalContainer.innerHTML = `
                <button class="cart-btn cart-btn-primary">
                    Checkout (PayPal Unavailable)
                </button>
            `;
        };
        document.head.appendChild(script);
    }

    updatePayPalButton() {
        if (!window.paypal || this.items.length === 0) {
            this.paypalContainer.innerHTML = '';
            this.paypalContainer.classList.add('loading');
            return;
        }

        this.paypalContainer.classList.remove('loading');
        this.paypalContainer.innerHTML = '';

        const total = this.getCartTotal();

        window.paypal.Buttons({
            style: {
                layout: 'vertical',
                color: 'gold',
                shape: 'rect',
                label: 'paypal'
            },
            createOrder: (data, actions) => {
                return actions.order.create({
                    purchase_units: [{
                        amount: {
                            value: total.toFixed(2),
                            currency_code: 'USD',
                            breakdown: {
                                item_total: {
                                    currency_code: 'USD',
                                    value: this.getSubtotal().toFixed(2)
                                },
                                shipping: {
                                    currency_code: 'USD',
                                    value: this.getShipping().toFixed(2)
                                }
                            }
                        },
                        items: this.items.map(item => ({
                            name: `${item.name} (${item.size}, ${item.color})`,
                            unit_amount: {
                                currency_code: 'USD',
                                value: item.price.toFixed(2)
                            },
                            quantity: item.quantity.toString(),
                            category: 'PHYSICAL_GOODS'
                        })),
                        shipping: {
                            name: {
                                full_name: 'Customer'
                            },
                            address: {
                                address_line_1: '1 Main St',
                                admin_area_2: 'San Jose',
                                admin_area_1: 'CA',
                                postal_code: '95131',
                                country_code: 'US'
                            }
                        }
                    }],
                    application_context: {
                        shipping_preference: 'GET_FROM_FILE'
                    }
                });
            },
            onApprove: (data, actions) => {
                return actions.order.capture().then((details) => {
                    this.handlePayPalSuccess(details);
                });
            },
            onError: (err) => {
                console.error('PayPal error:', err);
                alert('Payment failed. Please try again.');
            },
            onCancel: (data) => {
                console.log('PayPal payment cancelled:', data);
            }
        }).render(this.paypalContainer);
    }

    handlePayPalSuccess(details) {
        console.log('Payment successful:', details);

        // Clear cart
        this.items = [];
        this.saveCart();
        this.updateCartDisplay();

        // Show success message
        alert(`Payment successful! Transaction ID: ${details.id}`);

        // Redirect to success page or close cart
        this.closeCart();

        // Optional: redirect to order confirmation
        // window.location.href = `/order-success.html?id=${details.id}`;
    }

    getSubtotal() {
        return this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }

    getShipping() {
        return this.getSubtotal() > 0 ? 5.99 : 0;
    }

    getCartTotal() {
        return this.getSubtotal() + this.getShipping();
    }

    saveCart() {
        localStorage.setItem('freshthreads_cart', JSON.stringify(this.items));
    }

    loadCart() {
        try {
            const saved = localStorage.getItem('freshthreads_cart');
            return saved ? JSON.parse(saved) : [];
        } catch (e) {
            console.error('Error loading cart:', e);
            return [];
        }
    }

    clearCart() {
        this.items = [];
        this.saveCart();
        this.updateCartDisplay();
        this.updatePayPalButton();
    }

    // Public API for external use
    getCart() {
        return [...this.items];
    }

    getItemCount() {
        return this.items.reduce((sum, item) => sum + item.quantity, 0);
    }
}

// Initialize cart when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.freshThreadsCart = new FreshThreadsCart();

    // Re-bind buttons when new content is added
    const observer = new MutationObserver(() => {
        window.freshThreadsCart.bindAddToCartButtons();
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
});

// Export for module use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FreshThreadsCart;
}
