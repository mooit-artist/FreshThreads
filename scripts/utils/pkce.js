const crypto = require('crypto');

function base64url(input) {
  return input
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/g, '');
}

function generateVerifier(length = 64) {
  return base64url(crypto.randomBytes(length));
}

function challengeFromVerifier(verifier) {
  const hash = crypto.createHash('sha256').update(verifier).digest();
  return base64url(hash);
}

function randomState() {
  return base64url(crypto.randomBytes(24));
}

module.exports = { generateVerifier, challengeFromVerifier, randomState };
