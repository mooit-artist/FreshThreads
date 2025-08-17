const fs = require('fs');
const path = require('path');
const https = require('https');
const { URL } = require('url');
require('dotenv').config();

class PrintfulAPI {
  constructor() {
    this.apiKey = process.env.PRINTFUL_API_KEY;
    this.storeId = process.env.PRINTFUL_STORE_ID;
    this.baseUrl = 'https://api.printful.com';
    this.webhookSecret = process.env.PRINTFUL_WEBHOOK_SECRET;

    if (!this.apiKey) {
      throw new Error('PRINTFUL_API_KEY not found in environment variables');
    }

    this.headers = {
      'Authorization': `Bearer ${this.apiKey}`,
      'Content-Type': 'application/json',
      'User-Agent': 'FreshThreads/1.0 (Node.js)'
    };
  }

  async makeRequest(endpoint, options = {}) {
    const url = endpoint.startsWith('http') ? endpoint : `${this.baseUrl}${endpoint}`;

    try {
      const response = await this.httpRequest(url, {
        ...options,
        headers: { ...this.headers, ...options.headers }
      });

      if (response.statusCode && response.statusCode >= 400) {
        throw new Error(`Printful API Error ${response.statusCode}: ${response.data.error?.message || response.data.message || 'Unknown error'}`);
      }

      return response.data;
    } catch (error) {
      console.error('Printful API Request Failed:', error.message);
      throw error;
    }
  }

  httpRequest(url, options = {}) {
    return new Promise((resolve, reject) => {
      const urlObj = new URL(url);

      const requestOptions = {
        hostname: urlObj.hostname,
        port: urlObj.port || 443,
        path: urlObj.pathname + urlObj.search,
        method: options.method || 'GET',
        headers: options.headers || {}
      };

      const req = https.request(requestOptions, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const jsonData = data ? JSON.parse(data) : {};
            resolve({
              statusCode: res.statusCode,
              headers: res.headers,
              data: jsonData
            });
          } catch (parseError) {
            reject(new Error(`Failed to parse response: ${parseError.message}`));
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      if (options.body) {
        req.write(options.body);
      }

      req.end();
    });
  }  // STORE INFORMATION
  async getStoreInfo() {
    return this.makeRequest('/store');
  }

  // PRODUCTS
  async getProducts() {
    return this.makeRequest('/store/products');
  }

  async getProduct(productId) {
    return this.makeRequest(`/store/products/${productId}`);
  }

  async createProduct(productData) {
    return this.makeRequest('/store/products', {
      method: 'POST',
      body: JSON.stringify(productData)
    });
  }

  async updateProduct(productId, productData) {
    return this.makeRequest(`/store/products/${productId}`, {
      method: 'PUT',
      body: JSON.stringify(productData)
    });
  }

  async deleteProduct(productId) {
    return this.makeRequest(`/store/products/${productId}`, {
      method: 'DELETE'
    });
  }

  // ORDERS
  async getOrders(params = {}) {
    const query = new URLSearchParams(params).toString();
    return this.makeRequest(`/orders${query ? '?' + query : ''}`);
  }

  async getOrder(orderId) {
    return this.makeRequest(`/orders/${orderId}`);
  }

  async createOrder(orderData) {
    return this.makeRequest('/orders', {
      method: 'POST',
      body: JSON.stringify(orderData)
    });
  }

  async confirmOrder(orderId) {
    return this.makeRequest(`/orders/${orderId}/confirm`, {
      method: 'POST'
    });
  }

  async cancelOrder(orderId) {
    return this.makeRequest(`/orders/${orderId}`, {
      method: 'DELETE'
    });
  }

  // CATALOG
  async getCatalogProducts() {
    return this.makeRequest('/products');
  }

  async getProductDetails(productId) {
    return this.makeRequest(`/products/${productId}`);
  }

  async getProductVariants(productId) {
    return this.makeRequest(`/products/${productId}/variants`);
  }

  // SHIPPING
  async calculateShipping(orderData) {
    return this.makeRequest('/shipping/rates', {
      method: 'POST',
      body: JSON.stringify(orderData)
    });
  }

  // FILE MANAGEMENT
  async uploadFile(fileData) {
    return this.makeRequest('/files', {
      method: 'POST',
      body: JSON.stringify(fileData)
    });
  }

  async getFile(fileId) {
    return this.makeRequest(`/files/${fileId}`);
  }

  // MOCKUPS
  async generateMockup(mockupData) {
    return this.makeRequest('/mockup-generator/create-task/71', {
      method: 'POST',
      body: JSON.stringify(mockupData)
    });
  }

  async getMockupTask(taskKey) {
    return this.makeRequest(`/mockup-generator/task?task_key=${taskKey}`);
  }

  // WEBHOOKS
  async setupWebhooks(webhookData) {
    return this.makeRequest('/webhooks', {
      method: 'POST',
      body: JSON.stringify(webhookData)
    });
  }

  async getWebhooks() {
    return this.makeRequest('/webhooks');
  }

  // UTILITY METHODS
  async isConnected() {
    try {
      const response = await this.getStoreInfo();
      return Boolean(response.result);
    } catch (error) {
      console.log('Connection test failed:', error.message);
      return false;
    }
  }

  // PRODUCT TEMPLATES
  createTShirtProduct(design, options = {}) {
    return {
      sync_product: {
        name: options.name || 'Fresh Threads T-Shirt',
        thumbnail: design.thumbnail || design.url,
        ...options.productOptions
      },
      sync_variants: [
        {
          retail_price: options.price || '24.99',
          variant_id: options.variantId || 4011, // Bella Canvas 3001 - Black - S
          files: [
            {
              type: 'front',
              url: design.url
            }
          ]
        }
      ]
    };
  }

  // FRESH THREADS SPECIFIC METHODS
  async createFreshThreadsProduct(designPath, productInfo) {
    const productData = this.createTShirtProduct(
      { url: designPath },
      {
        name: `Fresh Threads - ${productInfo.name}`,
        price: productInfo.price || '24.99',
        variantId: productInfo.variantId || 4011
      }
    );

    return this.createProduct(productData);
  }

  async syncBannerToProduct() {
    const bannerPath = 'docs/assets/Etsy Logos/etsyorderbanner.png';
    const absolutePath = path.resolve(bannerPath);

    if (!fs.existsSync(absolutePath)) {
      throw new Error('Banner file not found. Run: npm run render:etsy-banner first');
    }

    // For demo purposes - in production you'd upload to a CDN
    const designUrl = 'https://your-domain.com/assets/Etsy%20Logos/etsyorderbanner.png';

    return this.createFreshThreadsProduct(designUrl, {
      name: 'Fresh Threads Logo Tee',
      price: '24.99'
    });
  }
}

module.exports = PrintfulAPI;
