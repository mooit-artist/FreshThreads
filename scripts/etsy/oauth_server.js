/*
Minimal Etsy OAuth2 (PKCE) flow to obtain and store access/refresh tokens.
Requirements: set env in .env (see .env.example). Run: npm run etsy:auth
*/

const express = require('express');
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
require('dotenv').config();

const { generateVerifier, challengeFromVerifier, randomState } = require('../utils/pkce');

const PORT = process.env.ETSY_AUTH_PORT || 8787;
const REDIRECT_URI = `http://localhost:${PORT}/etsy/callback`;
const TOKEN_PATH = path.resolve(process.env.ETSY_TOKEN_PATH || 'config/etsy_tokens.json');

const ETSY_BASE = 'https://www.etsy.com';
const AUTH_URL = `${ETSY_BASE}/oauth/connect`;
const TOKEN_URL = 'https://openapi.etsy.com/v3/public/oauth/token';

function requireEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Missing env: ${name}`);
  return v;
}

const CLIENT_ID = requireEnv('ETSY_CLIENT_ID');
const SCOPES = (process.env.ETSY_SCOPES || 'listings_r,shops_r').split(',').map(s => s.trim()).join(' ');

const app = express();
let pending = {};

app.get('/etsy/login', async (req, res) => {
  const verifier = generateVerifier();
  const challenge = challengeFromVerifier(verifier);
  const state = randomState();

  pending[state] = { verifier, createdAt: Date.now() };

  const params = new URLSearchParams({
    response_type: 'code',
    redirect_uri: REDIRECT_URI,
    scope: SCOPES,
    client_id: CLIENT_ID,
    state,
    code_challenge: challenge,
    code_challenge_method: 'S256'
  });

  const url = `${AUTH_URL}?${params.toString()}`;
  res.redirect(url);
});

app.get('/etsy/callback', async (req, res) => {
  const { code, state } = req.query;
  const entry = pending[state];
  if (!entry) return res.status(400).send('Invalid or expired state');

  try {
    const body = {
      grant_type: 'authorization_code',
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      code: code,
      code_verifier: entry.verifier,
    };

    const resp = await fetch(TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams(body),
    });
    const data = await resp.json();
    if (!resp.ok) {
      return res.status(500).send(`Token error: ${resp.status} ${resp.statusText} - ${JSON.stringify(data)}`);
    }

    await fs.promises.mkdir(path.dirname(TOKEN_PATH), { recursive: true });
    await fs.promises.writeFile(TOKEN_PATH, JSON.stringify({
      ...data,
      created_at: Date.now(),
      redirect_uri: REDIRECT_URI,
      scopes: SCOPES,
    }, null, 2));

    delete pending[state];
    res.send('Etsy authorization complete. You can close this window.');
  } catch (e) {
    res.status(500).send(`Callback error: ${e.message}`);
  }
});

app.get('/', (req, res) => res.send('Etsy OAuth server running. Go to /etsy/login to start.'));

app.listen(PORT, () => {
  console.log(`Etsy OAuth server listening on http://localhost:${PORT}`);
  console.log(`Go to: http://localhost:${PORT}/etsy/login`);
  if (process.env.ETSY_OPEN_BROWSER !== '0') {
    exec(`open http://localhost:${PORT}/etsy/login`, (err) => {
      if (err) console.log('Could not auto-open browser. Please open the URL manually.');
    });
  }
});
