# Issue: Site unavailable due to wrong cloud DNS nameservers

- Status: Closed
- Opened: 2025-08-16
- Closed: 2025-08-16
- Component: DNS / Cloudflare / Registrar
- Severity: High (site resolution impacted)

## Summary

The domain stopped resolving correctly because the registrar was pointing to the wrong cloud DNS nameservers. Cloudflare was configured for the zone, but authoritative NS at the registrar did not match the NS assigned by Cloudflare.

## Impact

- Intermittent or complete site outage for freshthreadsllc.com and subdomains.
- SSL cert issuance and Pages custom domain verification could fail.

## Root Cause

Registrar nameserver settings did not use the Cloudflare-assigned pair (e.g., `name.ns.cloudflare.com`, `name.ns.cloudflare.com`). Queries hit non-authoritative DNS, serving stale or empty zone data.

## Resolution

- Updated registrar to use the exact Cloudflare-assigned nameservers shown in the Cloudflare dashboard for the zone.
- Waited for NS delegation to propagate (typically minutes to 24h; verified via `dig NS freshthreadsllc.com +short`).
- Rechecked A/CNAME records for GitHub Pages and www CNAME.
- Verified SSL mode: Full (strict) and Universal SSL enabled.

## Verification

- `dig +short freshthreadsllc.com` returns GitHub Pages A/CNAME targets as expected.
- `dig NS freshthreadsllc.com +short` shows the two Cloudflare nameservers assigned to the zone.
- Site loads via HTTPS without cert warnings.

## Follow-ups

- Document DNS runbook (registrar, Cloudflare settings, Pages targets).
- Add a recurring reminder to re-verify NS delegation after registrar updates.
