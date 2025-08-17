/*
Converts an image to high-quality JPEG using sharp.
Usage:
  node scripts/convert_to_jpeg.js <inputPath> <outputPath> [quality]
Example:
  node scripts/convert_to_jpeg.js 'docs/assets/Etsy Logos/etsyorderbanner.png' 'docs/assets/Etsy Logos/etsyorderbanner.jpg' 95
*/

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

async function ensureDir(filePath) {
  await fs.promises.mkdir(path.dirname(filePath), { recursive: true });
}

async function main() {
  const [,, input, output, qualityArg] = process.argv;
  if (!input || !output) {
    console.error('Usage: node scripts/convert_to_jpeg.js <inputPath> <outputPath> [quality]');
    process.exit(1);
  }
  const q = Math.max(1, Math.min(100, parseInt(qualityArg || '95', 10)));
  const absIn = path.resolve(input);
  const absOut = path.resolve(output);
  if (!fs.existsSync(absIn)) {
    console.error(`Input not found: ${absIn}`);
    process.exit(2);
  }
  await ensureDir(absOut);
  await sharp(absIn)
    .jpeg({ quality: q, progressive: true, mozjpeg: true, chromaSubsampling: '4:4:4' })
    .toFile(absOut);
  console.log(`Wrote JPEG: ${absOut} (quality=${q})`);
}

main().catch(err => { console.error(err); process.exit(3); });
