# FreshThreads LLC — freshthreadsllc.com

The brand homepage for FreshThreads LLC, a small print-on-demand T-shirt business.

- **Static site.** One page (`index.html`), no build step, no framework, no npm dependencies for the page.
- **Hosted on GitHub Pages**, deployed by `.github/workflows/deploy.yml` on every push to `main`. DNS is on Cloudflare.
- **Takes no payments.** Every "Buy" button sends the visitor to the Etsy listing.
- **Products come from Etsy automatically.** A scheduled workflow writes `data/products.json`; the page reads it on load. If the file is empty or can't be loaded, the page shows a "New designs dropping soon" section instead.

## How it fits together

```
Printify  ──(prints & ships)──▶  Etsy shop  ──(API, daily)──▶  data/products.json  ──▶  index.html
```

- **Printify** is connected to Etsy inside the Printify dashboard (**My Stores → Connect Etsy**). It prints and ships every Etsy order on its own. **The website needs no Printify setup and never holds a Printify token.**
- **Etsy** is the storefront: `https://www.etsy.com/shop/freshthreads`.
- **This repo** only reads public listing data from Etsy and shows it.

## Repo layout

| Path | What it is |
|---|---|
| `index.html` | The whole site |
| `assets/images/`, `assets/logos/` | Images the page uses, as WebP with PNG fallback |
| `data/products.json` | Etsy listings, written by the sync workflow. Don't edit by hand. |
| `scripts/sync-etsy.mjs` | The sync script (Node 20+, no dependencies) |
| `.github/workflows/deploy.yml` | Publishes the site to GitHub Pages |
| `.github/workflows/sync-etsy.yml` | Daily Etsy sync |
| `archive/` | Unused originals kept for reference. **Not published.** |

Only `index.html`, `assets/`, `data/` and a few root files are deployed. Everything else stays in the repo.

## One-time Etsy API setup

The sync needs an Etsy app key. This takes about five minutes.

1. Go to <https://www.etsy.com/developers/your-apps> and click **Create a New App**. Any name works, for example "FreshThreads website". Etsy may put the app in a short review period before the key is active.
2. Open the app and copy the **Keystring** and the **Shared secret**.
3. In this GitHub repo, go to **Settings → Secrets and variables → Actions**.
   - Under **Secrets**, add `ETSY_API_KEY` (the keystring) and `ETSY_SHARED_SECRET`.
   - Under **Variables**, add `ETSY_SHOP_NAME` set to your shop name as it appears in your shop URL, for example `freshthreads`.
4. Go to **Actions → Sync Etsy listings → Run workflow** and run it once. The log shows the shop ID it found and how many listings it pulled.
5. If listings changed, the workflow commits `data/products.json` and kicks off the Pages deploy. The site updates within a minute or two.

Never put the key in `index.html` or anywhere else that ships to the browser. It only ever lives in GitHub Secrets.

### If the shop URL changes

The Etsy shop URL is written into `index.html` in a few places as a no-JavaScript fallback. Search for `etsy.com/shop/` and replace it, then update the `ETSY_SHOP_NAME` variable.

## Adding a new shirt

1. Create the product in **Printify** and publish it to **Etsy**.
2. That's it. The next daily sync (around 11:17 UTC) picks it up and it appears on the site.
3. Want it now? **Actions → Sync Etsy listings → Run workflow.**

Removing or deactivating a listing on Etsy removes it from the site the same way.

## Running the sync locally

```bash
ETSY_API_KEY=xxx ETSY_SHARED_SECRET=yyy ETSY_SHOP_NAME=freshthreads node scripts/sync-etsy.mjs
```

The script exits non-zero on any API error and leaves the existing `data/products.json` untouched, so a bad run never blanks the site. A shop with zero active listings writes `[]`, which is a normal result.

## Images

Page images are WebP (quality 80, max 1200 px) with a compressed PNG fallback via `<picture>`. Full-size originals live in `archive/originals/`. To add a new one:

```bash
cwebp -q 80 -resize 1200 0 archive/originals/NewDesign.png -o assets/images/NewDesign.webp
pngquant --quality=70-90 --force --output assets/images/NewDesign.png archive/originals/NewDesign.png
```

Both tools install with `brew install webp pngquant`.
