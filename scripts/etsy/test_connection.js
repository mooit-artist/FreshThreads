#!/usr/bin/env node
const EtsyAPI = require('./etsy_client');

async function main() {
  try {
    const etsy = new EtsyAPI();

    console.log('🏪 Testing Etsy API connection...');
    console.log('📱 App: Namefreshthreadsllc');
    console.log('🔗 Shop URL:', process.env.ETSY_SHOP_URL || 'Not configured');
    console.log();

    // Test 1: Get my shop info
    console.log('1️⃣ Fetching shop information...');
    const shop = await etsy.getMyShop();
    if (shop) {
      console.log(`✅ Shop found: ${shop.shop_name}`);
      console.log(`   Shop ID: ${shop.shop_id}`);
      console.log(`   URL: https://${shop.shop_name}.etsy.com`);
      console.log(`   Currency: ${shop.currency_code}`);
      console.log(`   Created: ${new Date(shop.create_date * 1000).toLocaleDateString()}`);
    } else {
      console.log('❌ No shop found');
      return;
    }

    // Test 2: Get active listings
    console.log('\n2️⃣ Fetching active listings...');
    const listings = await etsy.getShopListings(shop.shop_id, { limit: 5 });
    console.log(`✅ Found ${listings.count} total listings`);
    if (listings.results && listings.results.length > 0) {
      listings.results.forEach((listing, i) => {
        console.log(`   ${i + 1}. ${listing.title}`);
        console.log(`      Price: ${listing.price.currency_code} ${listing.price.amount / listing.price.divisor}`);
        console.log(`      State: ${listing.state}`);
      });
    } else {
      console.log('   No active listings found');
    }

    // Test 3: Get recent receipts (orders)
    console.log('\n3️⃣ Fetching recent receipts...');
    try {
      const receipts = await etsy.getShopReceipts(shop.shop_id, { limit: 3 });
      console.log(`✅ Found ${receipts.count} total receipts`);
      if (receipts.results && receipts.results.length > 0) {
        receipts.results.forEach((receipt, i) => {
          console.log(`   ${i + 1}. Receipt #${receipt.receipt_id}`);
          console.log(`      Total: ${receipt.total_price.currency_code} ${receipt.total_price.amount / receipt.total_price.divisor}`);
          console.log(`      Date: ${new Date(receipt.create_timestamp * 1000).toLocaleDateString()}`);
        });
      } else {
        console.log('   No receipts found');
      }
    } catch (err) {
      console.log(`   ⚠️ Receipts access failed: ${err.message}`);
      console.log('   (This may require additional OAuth scopes)');
    }

    console.log('\n✅ Etsy API connection test complete!');
    console.log('\nNext steps:');
    console.log('• Your banner files are ready: etsyorderbanner.png and etsyorderbanner.jpg');
    console.log('• Check your Etsy Developer Console to enable production API access');
    console.log('• Rate limits: 5 req/sec, 5,000 req/day when enabled');

  } catch (error) {
    console.error('❌ Error:', error.message);

    if (error.message.includes('Token file not found')) {
      console.log('\n🔧 To fix this, run: npm run etsy:auth');
    } else if (error.message.includes('401') || error.message.includes('403')) {
      console.log('\n🔧 Authentication issue. Try refreshing tokens: npm run etsy:refresh');
    }
  }
}

if (require.main === module) {
  main();
}

module.exports = main;
