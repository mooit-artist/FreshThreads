#!/usr/bin/env node
/**
 * sync-etsy.mjs — pull active Etsy listings into data/products.json
 *
 * Runs in GitHub Actions on a schedule (see .github/workflows/sync-etsy.yml).
 * Node 20+, no dependencies. Uses the Etsy Open API v3 with an API key only;
 * none of the endpoints below need OAuth.
 *
 * Env:
 *   ETSY_API_KEY        keystring from https://www.etsy.com/developers/your-apps  (required)
 *   ETSY_SHARED_SECRET  shared secret from the same page                          (recommended)
 *   ETSY_SHOP_NAME      your Etsy shop name, e.g. "freshthreads"                  (required)
 *
 * Behaviour:
 *   - Any API failure exits non-zero and leaves the existing products.json alone.
 *   - A shop with zero active listings writes [] (that is a valid result).
 */

import { readFile, writeFile, rename, mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const API = 'https://openapi.etsy.com/v3/application';
const PAGE_SIZE = 100; // max allowed by the API
const OUT_FILE = resolve(dirname(fileURLToPath(import.meta.url)), '..', 'data', 'products.json');

const keystring = (process.env.ETSY_API_KEY || '').trim();
const sharedSecret = (process.env.ETSY_SHARED_SECRET || '').trim();
const shopName = (process.env.ETSY_SHOP_NAME || '').trim();

if (!keystring) fail('ETSY_API_KEY is not set.');
if (!shopName) fail('ETSY_SHOP_NAME is not set.');
if (!sharedSecret) console.warn('warning: ETSY_SHARED_SECRET is not set. Etsy currently documents the header as keystring:shared_secret.');

// Etsy docs: x-api-key: <keystring>:<shared_secret>
const headers = {
  'x-api-key': sharedSecret ? `${keystring}:${sharedSecret}` : keystring,
  'accept': 'application/json',
  'user-agent': 'FreshThreads-site-sync (+https://freshthreadsllc.com)',
};

async function get(path, params = {}) {
  const url = new URL(API + path);
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null) continue;
    url.searchParams.set(k, Array.isArray(v) ? v.join(',') : String(v));
  }
  const res = await fetch(url, { headers });
  if (!res.ok) {
    const body = (await res.text().catch(() => '')).slice(0, 300);
    throw new Error(`GET ${url.pathname} -> HTTP ${res.status}${body ? `: ${body}` : ''}`);
  }
  return res.json();
}

async function findShopId(name) {
  const data = await get('/shops', { shop_name: name, limit: 25 });
  const results = Array.isArray(data.results) ? data.results : [];
  const exact = results.find(s => String(s.shop_name).toLowerCase() === name.toLowerCase());
  const shop = exact || (results.length === 1 ? results[0] : null);
  if (!shop) {
    const seen = results.map(s => s.shop_name).join(', ') || 'none';
    throw new Error(`No shop named "${name}" found. Matches returned: ${seen}`);
  }
  if (!exact) console.warn(`warning: no exact match for "${name}", using "${shop.shop_name}".`);
  return { id: shop.shop_id, name: shop.shop_name };
}

async function fetchAllActiveListings(shopId) {
  const all = [];
  for (let offset = 0; ; offset += PAGE_SIZE) {
    const page = await get(`/shops/${shopId}/listings/active`, {
      limit: PAGE_SIZE, offset, sort_on: 'created', sort_order: 'desc',
    });
    const results = Array.isArray(page.results) ? page.results : [];
    all.push(...results);
    const total = Number(page.count ?? all.length);
    if (results.length < PAGE_SIZE || all.length >= total) break;
  }
  return all;
}

// The /listings/active endpoint has no `includes`, so fetch images in batches.
async function attachImages(listings) {
  const byId = new Map();
  for (let i = 0; i < listings.length; i += PAGE_SIZE) {
    const ids = listings.slice(i, i + PAGE_SIZE).map(l => l.listing_id);
    const data = await get('/listings/batch', { listing_ids: ids, includes: ['Images'] });
    for (const l of data.results || []) byId.set(l.listing_id, l.images || []);
  }
  return listings.map(l => ({ ...l, images: byId.get(l.listing_id) || [] }));
}

function toProduct(l) {
  const img = [...(l.images || [])].sort((a, b) => (a.rank ?? 0) - (b.rank ?? 0))[0];
  const amount = Number(l.price?.amount ?? 0);
  const divisor = Number(l.price?.divisor ?? 100) || 100;
  return {
    id: l.listing_id,
    title: String(l.title || '').trim(),
    price: Math.round((amount / divisor) * 100) / 100,
    currency: l.price?.currency_code || 'USD',
    url: l.url || `https://www.etsy.com/listing/${l.listing_id}`,
    image: img ? (img.url_570xN || img.url_fullxfull || null) : null,
    imageAlt: (img && img.alt_text) ? String(img.alt_text).trim() : String(l.title || '').trim(),
    tags: Array.isArray(l.tags) ? l.tags : [],
    _created: Number(l.original_creation_timestamp || l.created_timestamp || l.creation_timestamp || 0),
  };
}

async function writeAtomic(file, text) {
  await mkdir(dirname(file), { recursive: true });
  const tmp = `${file}.tmp`;
  await writeFile(tmp, text, 'utf8');
  await rename(tmp, file);
}

function fail(msg) {
  console.error(`error: ${msg}`);
  process.exit(1);
}

try {
  const shop = await findShopId(shopName);
  console.log(`shop "${shop.name}" -> id ${shop.id}`);

  const listings = await fetchAllActiveListings(shop.id);
  console.log(`${listings.length} active listing(s)`);

  const withImages = listings.length ? await attachImages(listings) : [];
  const products = withImages
    .map(toProduct)
    .sort((a, b) => b._created - a._created || b.id - a.id)
    .map(({ _created, ...p }) => p);

  const next = JSON.stringify(products, null, 2) + '\n';
  const prev = await readFile(OUT_FILE, 'utf8').catch(() => null);
  if (prev === next) {
    console.log('products.json unchanged');
  } else {
    await writeAtomic(OUT_FILE, next);
    console.log(`wrote ${products.length} product(s) to ${OUT_FILE}`);
  }
} catch (err) {
  // Leave the existing products.json untouched so a bad run never empties the site.
  fail(err && err.message ? err.message : String(err));
}
