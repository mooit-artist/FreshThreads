#!/usr/bin/env node
const PrintfulAPI = require('./printful_client');

async function main() {
  const args = process.argv.slice(2);

  if (args.length < 3) {
    console.log('Usage: node create_product.js <design_url> <product_name> <price>');
    console.log('Example: node create_product.js "https://cdn.example.com/design.png" "Fresh Logo Tee" "24.99"');
    process.exit(1);
  }

  const [designUrl, productName, price] = args;

  try {
    console.log('🏗️ Creating Printful product...');
    console.log(`Design: ${designUrl}`);
    console.log(`Name: ${productName}`);
    console.log(`Price: $${price}`);

    const printful = new PrintfulAPI();

    // Create product data
    const productData = {
      sync_product: {
        name: productName,
        thumbnail: designUrl
      },
      sync_variants: [
        {
          retail_price: price,
          variant_id: 4011, // Bella + Canvas 3001 Unisex Short Sleeve Jersey T-Shirt - Black - S
          files: [
            {
              type: 'front',
              url: designUrl
            }
          ]
        },
        {
          retail_price: price,
          variant_id: 4012, // Same shirt - M
          files: [
            {
              type: 'front',
              url: designUrl
            }
          ]
        },
        {
          retail_price: price,
          variant_id: 4013, // Same shirt - L
          files: [
            {
              type: 'front',
              url: designUrl
            }
          ]
        }
      ]
    };

    console.log('\n📤 Sending to Printful...');
    const result = await printful.createProduct(productData);

    if (result.result) {
      console.log('✅ Product created successfully!');
      console.log(`   Product ID: ${result.result.id}`);
      console.log(`   Name: ${result.result.sync_product.name}`);
      console.log(`   Variants: ${result.result.sync_variants.length}`);
      console.log(`   Status: ${result.result.sync_product.status || 'Active'}`);

      console.log('\n🔗 Printful Dashboard:');
      console.log(`   View: https://printful.com/dashboard/store/products/${result.result.id}`);

      // Save product info locally
      const fs = require('fs');
      const path = require('path');
      const productInfoPath = path.resolve('config/printful_products.json');

      let existingProducts = [];
      if (fs.existsSync(productInfoPath)) {
        existingProducts = JSON.parse(fs.readFileSync(productInfoPath, 'utf8'));
      }

      existingProducts.push({
        id: result.result.id,
        name: productName,
        price: price,
        designUrl: designUrl,
        createdAt: new Date().toISOString(),
        printfulData: result.result
      });

      fs.mkdirSync(path.dirname(productInfoPath), { recursive: true });
      fs.writeFileSync(productInfoPath, JSON.stringify(existingProducts, null, 2));

      console.log(`\n💾 Product info saved to: ${productInfoPath}`);
    }

  } catch (error) {
    console.error('❌ Failed to create product:', error.message);

    if (error.message.includes('Invalid file URL')) {
      console.log('\n🔧 Design URL issue:');
      console.log('• Make sure the design URL is publicly accessible');
      console.log('• URL should return a PNG/JPG image');
      console.log('• Try: curl -I "' + designUrl + '"');
    }
  }
}

if (require.main === module) {
  main();
}
