const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');
require('dotenv').config();

function requireEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Missing env: ${name}`);
  return v;
}

const CLIENT_ID = requireEnv('ETSY_CLIENT_ID');
const TOKEN_PATH = path.resolve(process.env.ETSY_TOKEN_PATH || 'config/etsy_tokens.json');

async function main() {
  if (!fs.existsSync(TOKEN_PATH)) throw new Error(`Token file not found: ${TOKEN_PATH}`);
  const tokens = JSON.parse(fs.readFileSync(TOKEN_PATH, 'utf8'));
  if (!tokens.access_token) throw new Error('No access_token found in token file');

  const url = 'https://openapi.etsy.com/v3/application/shops?limit=1';
  const resp = await fetch(url, {
    headers: {
      Authorization: `Bearer ${tokens.access_token}`,
      'x-api-key': CLIENT_ID,
      'Content-Type': 'application/json',
    },
  });

  const text = await resp.text();
  if (!resp.ok) {
    throw new Error(`Etsy API error ${resp.status} ${resp.statusText}: ${text}`);
  }
  try {
    const data = JSON.parse(text);
    console.log('Shops response:', JSON.stringify(data, null, 2));
  } catch {
    console.log('Response:', text);
  }
}

main().catch(err => { console.error(err); process.exit(1); });
