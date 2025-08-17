#!/usr/bin/env node
const PrintfulAPI = require('./printful_client');

async function main() {
  try {
    console.log('📦 Fetching your Printful products...');

    const printful = new PrintfulAPI();
    const products = await printful.getProducts();

    if (!products.result || products.result.length === 0) {
      console.log('📝 No products found in your store');
      console.log('\n💡 Create your first product:');
      console.log('node scripts/printful/create_product.js "https://example.com/design.png" "Product Name" "24.99"');
      return;
    }

    console.log(`✅ Found ${products.result.length} products in your store:`);
    console.log('=' .repeat(60));

    for (const product of products.result) {
      console.log(`\n📦 ${product.name}`);
      console.log(`   ID: ${product.id}`);
      console.log(`   Status: ${product.status || 'Active'}`);
      console.log(`   Variants: ${product.variants || 'N/A'}`);

      // Get detailed info for first few products
      if (products.result.indexOf(product) < 3) {
        try {
          const details = await printful.getProduct(product.id);
          if (details.result) {
            const variants = details.result.sync_variants || [];
            if (variants.length > 0) {
              console.log(`   Price: $${variants[0].retail_price}`);
              console.log(`   Sizes: ${variants.map(v => v.size || 'N/A').join(', ')}`);
            }
          }
        } catch (detailError) {
          console.log(`   (Details unavailable)`);
        }
      }

      console.log(`   Dashboard: https://printful.com/dashboard/store/products/${product.id}`);
    }

    console.log('\n🔗 Manage all products:');
    console.log('https://printful.com/dashboard/store/products');

  } catch (error) {
    console.error('❌ Error fetching products:', error.message);
  }
}

if (require.main === module) {
  main();
}
