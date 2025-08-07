// Print-on-Demand Configuration
// Replace the placeholder values with your actual API keys

window.podConfig = {
    // PRINTIFY CONFIGURATION
    // Get these from: https://printify.com/app/account/api
    printifyApiKey: 'YOUR_PRINTIFY_API_KEY_HERE', // Will be replaced by GitHub Actions
    printifyShopId: '23745844', // FreshThreadsLLC store ID

    // PRINTFUL CONFIGURATION
    // Get this from: https://www.printful.com/dashboard/settings/api
    printfulApiKey: 'YOUR_PRINTFUL_API_KEY_HERE',

    // DEVELOPMENT SETTINGS
    debug: true,
    testMode: false // Set to true for testing
};

// Instructions for getting your API keys:
/*
PRINTIFY SETUP:
1. Go to https://printify.com
2. Create account and verify email
3. Go to "My Stores" → "Connect a new store" → Choose "API"
4. Note the Shop ID from the URL: printify.com/app/stores/[SHOP_ID]/products
5. Go to Settings → API → Create Personal Access Token
6. Copy the token and paste it as printifyApiKey above
7. Copy the Shop ID and paste it as printifyShopId above

PRINTFUL SETUP:
1. Go to https://printful.com
2. Create account and verify email
3. Go to Settings → API
4. Click "Create API Key"
5. Copy the key and paste it as printfulApiKey above

SECURITY NOTE:
- Never commit this file with real API keys to version control
- For production, consider using environment variables
- Add config.js to your .gitignore file
*/
