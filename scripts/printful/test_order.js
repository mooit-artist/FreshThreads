#!/usr/bin/env node
const PrintfulAPI = require('./printful_client');

async function main() {
  try {
    console.log('🧪 Creating test order...');

    const printful = new PrintfulAPI();

    // First, get available products
    const products = await printful.getProducts();
    if (!products.result || products.result.length === 0) {
      console.log('❌ No products found. Create a product first:');
      console.log('node scripts/printful/create_product.js "https://example.com/design.png" "Test Product" "24.99"');
      return;
    }

    const firstProduct = products.result[0];
    console.log(`📦 Using product: ${firstProduct.name}`);

    // Get product details to find variant
    const productDetails = await printful.getProduct(firstProduct.id);
    const variants = productDetails.result.sync_variants || [];

    if (variants.length === 0) {
      console.log('❌ Product has no variants available');
      return;
    }

    const firstVariant = variants[0];
    console.log(`👕 Using variant: ${firstVariant.name || 'Default'} - $${firstVariant.retail_price}`);

    // Create test order
    const orderData = {
      recipient: {
        name: 'John Doe',
        company: 'Fresh Threads Test',
        address1: '123 Test Street',
        address2: 'Apt 4B',
        city: 'Los Angeles',
        state_code: 'CA',
        country_code: 'US',
        zip: '90210',
        phone: '555-123-4567',
        email: 'test@freshthreads.com'
      },
      items: [
        {
          sync_variant_id: firstVariant.id,
          quantity: 1,
          retail_price: firstVariant.retail_price
        }
      ],
      external_id: `test_order_${Date.now()}`
    };

    console.log('\n📋 Order Details:');
    console.log(`   Recipient: ${orderData.recipient.name}`);
    console.log(`   Address: ${orderData.recipient.address1}, ${orderData.recipient.city}, ${orderData.recipient.state_code}`);
    console.log(`   Items: 1x ${firstProduct.name}`);
    console.log(`   Total: $${firstVariant.retail_price}`);

    console.log('\n⚠️  This will create a DRAFT order (not confirmed)');
    console.log('Press Ctrl+C to cancel, or wait 5 seconds to continue...');

    await new Promise(resolve => setTimeout(resolve, 5000));

    console.log('\n📤 Creating draft order...');
    const result = await printful.createOrder(orderData);

    if (result.result) {
      console.log('✅ Test order created successfully!');
      console.log(`   Order ID: ${result.result.id}`);
      console.log(`   Status: ${result.result.status}`);
      console.log(`   External ID: ${result.result.external_id}`);
      console.log(`   Total: $${result.result.retail_costs?.total || 'N/A'}`);

      console.log('\n🔗 View in dashboard:');
      console.log(`https://printful.com/dashboard/default/orders/${result.result.id}`);

      console.log('\n📝 Notes:');
      console.log('• This is a DRAFT order - it will not be printed');
      console.log('• To confirm: call printful.confirmOrder(orderId)');
      console.log('• To cancel: call printful.cancelOrder(orderId)');

      // Save order info
      const fs = require('fs');
      const path = require('path');
      const orderInfoPath = path.resolve('config/printful_test_orders.json');

      let existingOrders = [];
      if (fs.existsSync(orderInfoPath)) {
        existingOrders = JSON.parse(fs.readFileSync(orderInfoPath, 'utf8'));
      }

      existingOrders.push({
        id: result.result.id,
        externalId: result.result.external_id,
        status: result.result.status,
        createdAt: new Date().toISOString(),
        printfulData: result.result
      });

      fs.mkdirSync(path.dirname(orderInfoPath), { recursive: true });
      fs.writeFileSync(orderInfoPath, JSON.stringify(existingOrders, null, 2));

      console.log(`\n💾 Order info saved to: ${orderInfoPath}`);
    }

  } catch (error) {
    console.error('❌ Failed to create test order:', error.message);

    if (error.message.includes('variant')) {
      console.log('\n🔧 Variant issue - try creating a product with proper variants first');
    }
  }
}

if (require.main === module) {
  main();
}
