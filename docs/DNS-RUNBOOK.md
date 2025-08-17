# DNS Runbook (FreshThreads)

This is a quick reference for keeping freshthreadsllc.com healthy.

## Nameservers
- Registrar must use the two Cloudflare-assigned NS for the zone.
- Verify:
  - `dig NS freshthreadsllc.com +short` → shows the exact CF NS pair.

## Records
- Apex (freshthreadsllc.com): GitHub Pages A records (4 IPs) or CNAME flattening to your `*.github.io`.
- www: CNAME → freshthreadsllc.com.

## Cloudflare
- SSL/TLS Mode: Full (strict)
- Universal SSL: Enabled
- Always Use HTTPS: ON
- Rocket Loader: OFF (can break inline scripts/CSP)
- Auto Minify: optional; disable JS if any breakage

## GitHub Pages
- `docs/CNAME` contains freshthreadsllc.com
- Wait for certificate provisioning after DNS changes

## Troubleshooting
1. Check NS delegation: `dig NS freshthreadsllc.com +short`
2. Check apex: `dig +short freshthreadsllc.com`
3. Check www: `dig +short www.freshthreadsllc.com`
4. Check cert: visit https://freshthreadsllc.com (no warnings)
