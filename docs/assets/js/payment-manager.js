// Payment Integration Setup - Fresh Threads LLC
// This file handles Stripe and PayPal payment processing

class PaymentManager {
  constructor(config = {}) {
    this.stripePublicKey = config.stripePublicKey || 'STRIPE_PUBLIC_KEY_PLACEHOLDER';
    this.paypalClientId = config.paypalClientId || 'PAYPAL_CLIENT_ID_PLACEHOLDER';
    this.currency = 'USD';
    this.businessEmail = 'bryan@freshthreadsllc.com';

    this.initializePaymentSystems();
  }

  initializePaymentSystems() {
    console.log('Initializing payment systems...');
    this.setupStripe();
    this.setupPayPal();
  }

  setupStripe() {
    if (this.stripePublicKey !== 'STRIPE_PUBLIC_KEY_PLACEHOLDER') {
      this.stripe = Stripe(this.stripePublicKey);
      console.log('✅ Stripe initialized');
    } else {
      console.warn('⚠️ Stripe public key not configured');
    }
  }

  setupPayPal() {
    if (this.paypalClientId !== 'PAYPAL_CLIENT_ID_PLACEHOLDER') {
      // PayPal SDK will be loaded via script tag
      console.log('✅ PayPal configured with client ID:', this.paypalClientId.substring(0, 20) + '...');
    } else {
      console.warn('⚠️ PayPal client ID not configured');
    }
  }

  async createStripeCheckout(items, customerInfo) {
    if (!this.stripe) {
      throw new Error('Stripe not initialized');
    }

    try {
      // Create line items for Stripe
      const lineItems = items.map(item => ({
        price_data: {
          currency: this.currency.toLowerCase(),
          product_data: {
            name: item.name,
            description: item.description,
            images: item.images || []
          },
          unit_amount: Math.round(item.price * 100) // Convert to cents
        },
        quantity: item.quantity
      }));

      // Call your backend to create checkout session
      const response = await fetch('/api/create-checkout-session', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          line_items: lineItems,
          customer_email: customerInfo.email,
          success_url: `${window.location.origin}/order-success.html?session_id={CHECKOUT_SESSION_ID}`,
          cancel_url: `${window.location.origin}/cart.html`
        })
      });

      const session = await response.json();

      if (session.error) {
        throw new Error(session.error);
      }

      // Redirect to Stripe Checkout
      const result = await this.stripe.redirectToCheckout({
        sessionId: session.id
      });

      if (result.error) {
        throw new Error(result.error.message);
      }

    } catch (error) {
      console.error('Stripe checkout error:', error);
      throw error;
    }
  }

  createPayPalCheckout(items, customerInfo) {
    return new Promise((resolve, reject) => {
      if (typeof paypal === 'undefined') {
        reject(new Error('PayPal SDK not loaded'));
        return;
      }

      // Calculate total
      const total = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

      paypal.Buttons({
        createOrder: (data, actions) => {
          return actions.order.create({
            purchase_units: [{
              amount: {
                value: total.toFixed(2),
                currency_code: this.currency
              },
              description: `Fresh Threads LLC - ${items.length} item(s)`,
              items: items.map(item => ({
                name: item.name,
                description: item.description,
                quantity: item.quantity.toString(),
                unit_amount: {
                  currency_code: this.currency,
                  value: item.price.toFixed(2)
                }
              }))
            }],
            application_context: {
              brand_name: 'Fresh Threads LLC',
              landing_page: 'BILLING',
              user_action: 'PAY_NOW'
            }
          });
        },
        onApprove: async (data, actions) => {
          try {
            const order = await actions.order.capture();
            console.log('PayPal payment completed:', order);

            // Send order details to your backend
            await this.processPayPalOrder(order, items, customerInfo);

            resolve(order);
          } catch (error) {
            console.error('PayPal approval error:', error);
            reject(error);
          }
        },
        onError: (err) => {
          console.error('PayPal error:', err);
          reject(err);
        },
        onCancel: (data) => {
          console.log('PayPal payment cancelled:', data);
          reject(new Error('Payment cancelled by user'));
        }
      }).render('#paypal-button-container');
    });
  }

  async processPayPalOrder(paypalOrder, items, customerInfo) {
    try {
      const response = await fetch('/api/process-paypal-order', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          paypal_order: paypalOrder,
          items: items,
          customer: customerInfo
        })
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Failed to process PayPal order');
      }

      return result;
    } catch (error) {
      console.error('PayPal order processing error:', error);
      throw error;
    }
  }

  async createPrintifyOrder(orderDetails) {
    try {
      const response = await fetch('/api/create-printify-order', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(orderDetails)
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Failed to create Printify order');
      }

      return result;
    } catch (error) {
      console.error('Printify order creation error:', error);
      throw error;
    }
  }

  // Utility method to format price for display
  formatPrice(price) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: this.currency
    }).format(price);
  }

  // Validate payment data
  validatePaymentData(items, customerInfo) {
    if (!items || items.length === 0) {
      throw new Error('No items to purchase');
    }

    if (!customerInfo.email) {
      throw new Error('Customer email is required');
    }

    // Validate each item
    items.forEach((item, index) => {
      if (!item.name || !item.price || !item.quantity) {
        throw new Error(`Invalid item at index ${index}`);
      }
      if (item.price <= 0 || item.quantity <= 0) {
        throw new Error(`Invalid price or quantity for item: ${item.name}`);
      }
    });

    return true;
  }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = PaymentManager;
} else {
  window.PaymentManager = PaymentManager;
}
