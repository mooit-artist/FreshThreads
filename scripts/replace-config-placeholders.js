#!/usr/bin/env node
/**
 * GitHub Actions Script: Replace Configuration Placeholders
 * This script replaces placeholder values in configuration files with GitHub Secrets
 */

const fs = require('fs');
const path = require('path');

// Configuration file paths
const CONFIG_FILES = [
  'docs/assets/js/config.js',
  'docs/checkout.html'
];

// Environment variables mapping
const REPLACEMENTS = {
  'STRIPE_PUBLISHABLE_KEY_PLACEHOLDER': process.env.STRIPE_PUBLISHABLE_KEY || 'pk_test_placeholder',
  'STRIPE_SECRET_KEY_PLACEHOLDER': process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder',
  'PAYPAL_CLIENT_ID_PLACEHOLDER': process.env.PAYPAL_CLIENT_ID_SANDBOX || 'paypal_client_id_placeholder',
  'PRINTIFY_API_KEY_PLACEHOLDER': process.env.PRINTIFY_API_KEY || 'printify_api_key_placeholder',
  'ENVIRONMENT_PLACEHOLDER': process.env.NODE_ENV || 'development'
};

console.log('🔧 Replacing configuration placeholders...');

CONFIG_FILES.forEach(filePath => {
  if (!fs.existsSync(filePath)) {
    console.log(`⚠️  File not found: ${filePath}`);
    return;
  }

  let content = fs.readFileSync(filePath, 'utf8');
  let hasChanges = false;

  Object.entries(REPLACEMENTS).forEach(([placeholder, value]) => {
    if (content.includes(placeholder)) {
      content = content.replace(new RegExp(placeholder, 'g'), value);
      hasChanges = true;
      console.log(`✅ Replaced ${placeholder} in ${filePath}`);
    }
  });

  if (hasChanges) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`💾 Updated ${filePath}`);
  } else {
    console.log(`ℹ️  No placeholders found in ${filePath}`);
  }
});

console.log('🎉 Configuration replacement complete!');
