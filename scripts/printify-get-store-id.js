// scripts/printify-get-store-id.js
// Fetches Printify store(s) using the PRINTIFY_API_KEY from environment and prints their IDs and names

const https = require("https");

const apiKey = process.env.PRINTIFY_API_KEY;
if (!apiKey) {
  console.error("❌ PRINTIFY_API_KEY is NOT set in environment!");
  process.exit(1);
}

const options = {
  hostname: "api.printify.com",
  path: "/v1/shops.json",
  method: "GET",
  headers: {
    Authorization: `Bearer ${apiKey}`,
    "Content-Type": "application/json",
    "User-Agent": "FreshThreads/1.0",
  },
};

const req = https.request(options, (res) => {
  let data = "";
  res.on("data", (chunk) => {
    data += chunk;
  });
  res.on("end", () => {
    if (res.statusCode !== 200) {
      console.error(
        `❌ Printify API error: ${res.statusCode} ${res.statusMessage}`,
      );
      console.error(data);
      process.exit(1);
    }
    try {
      const stores = JSON.parse(data);
      if (!Array.isArray(stores) || stores.length === 0) {
        console.log("No stores found for this API key.");
        process.exit(1);
      }
      console.log("Your Printify Stores:");
      stores.forEach((store) => {
        console.log(`- Name: ${store.title} | ID: ${store.id}`);
      });
    } catch (e) {
      console.error("❌ Failed to parse Printify API response:", e);
      process.exit(1);
    }
  });
});

req.on("error", (error) => {
  console.error("❌ Request error:", error);
  process.exit(1);
});

req.end();
