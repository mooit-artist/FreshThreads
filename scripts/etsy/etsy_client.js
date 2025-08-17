const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');
require('dotenv').config();

class EtsyAPI {
  constructor() {
    this.clientId = process.env.ETSY_CLIENT_ID;
    this.clientSecret = process.env.ETSY_CLIENT_SECRET;
    this.tokenPath = path.resolve(process.env.ETSY_TOKEN_PATH || 'config/etsy_tokens.json');
    this.baseUrl = 'https://openapi.etsy.com/v3';
    this.shopUrl = process.env.ETSY_SHOP_URL;

    if (!this.clientId) {
      throw new Error('ETSY_CLIENT_ID not found in environment');
    }
  }

  async getTokens() {
    if (!fs.existsSync(this.tokenPath)) {
      throw new Error(`Token file not found: ${this.tokenPath}. Run 'npm run etsy:auth' first.`);
    }
    return JSON.parse(fs.readFileSync(this.tokenPath, 'utf8'));
  }

  async makeRequest(endpoint, options = {}) {
    const tokens = await this.getTokens();
    if (!tokens.access_token) {
      throw new Error('No access token found. Run authorization flow first.');
    }

    const url = endpoint.startsWith('http') ? endpoint : `${this.baseUrl}${endpoint}`;
    const headers = {
      'Authorization': `Bearer ${tokens.access_token}`,
      'x-api-key': this.clientId,
      'Content-Type': 'application/json',
      ...options.headers
    };

    const response = await fetch(url, {
      ...options,
      headers
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Etsy API error ${response.status}: ${errorText}`);
    }

    return response.json();
  }

  // Convenience methods for common operations
  async getShops(limit = 25) {
    return this.makeRequest(`/application/shops?limit=${limit}`);
  }

  async getShopByName(shopName) {
    return this.makeRequest(`/application/shops/${shopName}`);
  }

  async getMyShop() {
    // Extract shop name from the shop URL if available
    if (this.shopUrl) {
      const match = this.shopUrl.match(/https:\/\/(.+)\.etsy\.com/);
      if (match) {
        const shopName = match[1];
        return this.getShopByName(shopName);
      }
    }

    // Fallback: get first shop from the shops list
    const shops = await this.getShops(1);
    return shops.results?.[0] || null;
  }

  async getShopListings(shopId, options = {}) {
    const params = new URLSearchParams({
      limit: options.limit || 25,
      state: options.state || 'active',
      ...options.params
    });
    return this.makeRequest(`/application/shops/${shopId}/listings?${params}`);
  }

  async getShopReceipts(shopId, options = {}) {
    const params = new URLSearchParams({
      limit: options.limit || 25,
      ...options.params
    });
    return this.makeRequest(`/application/shops/${shopId}/receipts?${params}`);
  }

  async uploadBanner(shopId, bannerImagePath) {
    const tokens = await this.getTokens();
    if (!tokens.access_token) {
      throw new Error('No access token found');
    }

    // Note: This would need to be implemented with proper multipart/form-data
    // For now, this is a placeholder for the banner upload functionality
    throw new Error('Banner upload not yet implemented - needs multipart form data handling');
  }
}

module.exports = EtsyAPI;
