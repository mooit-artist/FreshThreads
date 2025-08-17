#!/usr/bin/env node
const PrintfulAPI = require('./printful_client');

async function main() {
  try {
    console.log('🏪 Fresh Threads ↔️ Printful Integration Test');
    console.log('=' .repeat(50));

    const printful = new PrintfulAPI();

    // Test 1: Connection Test
    console.log('\n1️⃣ Testing Printful connection...');
    const isConnected = await printful.isConnected();

    if (!isConnected) {
      console.log('❌ Failed to connect to Printful');
      console.log('\n🔧 Setup required:');
      console.log('1. Go to https://printful.com/dashboard/settings/api');
      console.log('2. Generate an API key');
      console.log('3. Add PRINTFUL_API_KEY to your .env file');
      return;
    }

    console.log('✅ Successfully connected to Printful!');

    // Test 2: Store Information
    console.log('\n2️⃣ Fetching store information...');
    const storeInfo = await printful.getStoreInfo();
    if (storeInfo.result) {
      console.log(`✅ Store: ${storeInfo.result.name || 'Default Store'}`);
      console.log(`   Currency: ${storeInfo.result.currency}`);
      console.log(`   Country: ${storeInfo.result.country}`);
    }

    // Test 3: Available Products
    console.log('\n3️⃣ Checking available products in catalog...');
    const products = await printful.getProducts();
    if (products.result && products.result.length > 0) {
      console.log(`✅ Found ${products.result.length} product types available`);

      // Show popular t-shirt options
      const tshirts = products.result.filter(p =>
        p.type.toLowerCase().includes('shirt') ||
        p.type_name.toLowerCase().includes('shirt')
      ).slice(0, 3);

      if (tshirts.length > 0) {
        console.log('\n   📦 Popular T-Shirt Options:');
        tshirts.forEach(shirt => {
          console.log(`      • ${shirt.type_name} (ID: ${shirt.id})`);
        });
      }
    }

    // Test 4: Existing Store Products
    console.log('\n4️⃣ Checking your store products...');
    try {
      const storeProducts = await printful.getProducts();
      if (storeProducts.result && storeProducts.result.length > 0) {
        console.log(`✅ You have ${storeProducts.result.length} products in your store`);
        storeProducts.result.slice(0, 3).forEach((product, i) => {
          console.log(`   ${i + 1}. ${product.name} (${product.variants} variants)`);
        });
      } else {
        console.log('📝 No products in your store yet');
      }
    } catch (error) {
      console.log('📝 No products in your store yet (or endpoint changed)');
    }

    // Test 5: Design Upload Capabilities
    console.log('\n5️⃣ Checking design capabilities...');
    const fs = require('fs');
    const bannerExists = fs.existsSync('docs/assets/Etsy Logos/etsyorderbanner.png');
    const logoExists = fs.existsSync('docs/assets/Fresh_ThreadsLLCLogoTrans.png');

    console.log(`   Banner file: ${bannerExists ? '✅' : '❌'} ${bannerExists ? 'Ready' : 'Run: npm run render:etsy-banner'}`);
    console.log(`   Logo file: ${logoExists ? '✅' : '❌'} ${logoExists ? 'Ready' : 'Logo file missing'}`);

    // Test 6: Sample Product Creation (dry run)
    console.log('\n6️⃣ Sample product structure...');
    const sampleProduct = printful.createTShirtProduct(
      { url: 'https://example.com/design.png' },
      {
        name: 'Fresh Threads Sample Tee',
        price: '24.99'
      }
    );

    console.log('✅ Product template ready:');
    console.log(`   Name: ${sampleProduct.sync_product.name}`);
    console.log(`   Price: $${sampleProduct.sync_variants[0].retail_price}`);
    console.log(`   Variant ID: ${sampleProduct.sync_variants[0].variant_id}`);

    // Summary
    console.log('\n🎉 Integration Test Complete!');
    console.log('\n📋 Next Steps:');
    console.log('1. Upload your designs to a public URL (CDN/hosting)');
    console.log('2. Create products: node scripts/printful/create_product.js');
    console.log('3. Test orders: node scripts/printful/test_order.js');
    console.log('4. Set up webhooks for order notifications');

    console.log('\n💡 Quick Commands:');
    console.log('• Test connection: npm run printful:test');
    console.log('• Create product: npm run printful:create-product');
    console.log('• List products: npm run printful:products');

  } catch (error) {
    console.error('\n❌ Error during integration test:', error.message);

    if (error.message.includes('401') || error.message.includes('unauthorized')) {
      console.log('\n🔧 Authentication issue:');
      console.log('• Check your PRINTFUL_API_KEY in .env');
      console.log('• Verify the API key is active in Printful dashboard');
    } else if (error.message.includes('PRINTFUL_API_KEY not found')) {
      console.log('\n🔧 Configuration issue:');
      console.log('• Add PRINTFUL_API_KEY=your_api_key to .env file');
      console.log('• Get your API key from: https://printful.com/dashboard/settings/api');
    }
  }
}

if (require.main === module) {
  main();
}

module.exports = main;
