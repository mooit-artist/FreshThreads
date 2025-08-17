/*
Renders an HTML file (or a specific selector) to a PNG using Puppeteer.
Usage:
  node scripts/render_banner.js <inputHtmlPath> <outputPngPath> <selectorOrBody> <width> <height>
Example:
  node scripts/render_banner.js 'docs/assets/Etsy Logos/etsyorderbanner.html' 'docs/assets/Etsy Logos/etsyorderbanner.png' '.banner' 760 100
*/

const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');
const os = require('os');
let sharp = null;
try {
  require.resolve('sharp');
  // eslint-disable-next-line global-require, import/no-extraneous-dependencies
  sharp = require('sharp');
} catch {}

async function ensureDir(filePath) {
  const dir = path.dirname(filePath);
  await fs.promises.mkdir(dir, { recursive: true });
}

async function render() {
  const [,, inputHtml, outputPng, selector = 'body', width = '760', height = '100', scale = '3'] = process.argv;
  if (!inputHtml || !outputPng) {
    console.error('Usage: node scripts/render_banner.js <inputHtmlPath> <outputPngPath> <selectorOrBody> <width> <height>');
    process.exit(1);
  }

  const absInput = path.resolve(inputHtml);
  const absOutput = path.resolve(outputPng);

  // Verify input exists
  if (!fs.existsSync(absInput)) {
    console.error(`Input HTML not found: ${absInput}`);
    process.exit(2);
  }

  // Launch headless browser
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  // Set viewport to target dimensions to avoid scaling artifacts
  const targetWidth = parseInt(width, 10);
  const targetHeight = parseInt(height, 10);
  const dpr = Math.max(1, parseFloat(scale));
  await page.setViewport({ width: targetWidth, height: targetHeight, deviceScaleFactor: dpr });

  // Build file URL and set base for relative paths
  const fileUrl = 'file://' + absInput;
  await page.goto(fileUrl, { waitUntil: 'networkidle0' });

  // Wait for Google fonts to load (best-effort)
  try {
    await page.evaluate(async () => {
      const ready = globalThis?.document?.fonts?.ready;
      await Promise.resolve(ready);
    });
  } catch {}

  // If a selector is provided, clip to that element
  let clip = null;
  if (selector && selector !== 'body') {
    const rect = await page.$eval(selector, el => {
      const r = el.getBoundingClientRect();
      return { x: Math.round(r.x), y: Math.round(r.y), width: Math.round(r.width), height: Math.round(r.height) };
    }).catch(() => null);
    if (rect) {
      clip = rect;
    }
  }

  // Render to a temp file first at high scale to preserve detail
  await ensureDir(absOutput);
  const tmpOut = absOutput + `.tmp.${Date.now()}.png`;
  await page.screenshot({ path: tmpOut, clip: clip || undefined, fullPage: !clip, type: 'png' });
  await browser.close();

  // Downsample to exact requested size using sharp if available for best quality
  if (sharp) {
    await sharp(tmpOut)
      .resize(targetWidth, targetHeight, { fit: 'cover', kernel: sharp.kernel.lanczos3 })
      .png({ compressionLevel: 9, adaptiveFiltering: true })
      .toFile(absOutput);
    await fs.promises.unlink(tmpOut).catch(() => {});
  } else {
    // Fallback: move tmp to output (dimensions may be > target if scale>1)
    await fs.promises.rename(tmpOut, absOutput);
  }

  console.log(`Rendered ${outputPng}`);
}

render().catch(err => {
  console.error(err);
  process.exit(3);
});
