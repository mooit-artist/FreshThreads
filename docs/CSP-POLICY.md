# Content Security Policy Configuration

## Overview

This document outlines the Content Security Policy (CSP) implementation for FreshThreads LLC to protect against XSS, data injection, and other common web attacks.

## CSP Headers for GitHub Pages

Since GitHub Pages doesn't support custom HTTP headers, we implement CSP via meta tags in HTML files.

### Recommended CSP for FreshThreads

```html
<meta
  http-equiv="Content-Security-Policy"
  content="
  default-src 'self';
  script-src 'self' 'unsafe-inline'
    https://cdn.jsdelivr.net
    https://unpkg.com
    https://ajax.googleapis.com
    https://cdnjs.cloudflare.com;
  style-src 'self' 'unsafe-inline'
    https://fonts.googleapis.com
    https://cdn.jsdelivr.net;
  font-src 'self'
    https://fonts.gstatic.com;
  img-src 'self'
    data:
    https:
    blob:;
  connect-src 'self'
    https://api.printify.com
    https://fonts.googleapis.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  upgrade-insecure-requests;
"
/>
```

### Policy Breakdown

- **default-src 'self'**: Only allow resources from same origin by default
- **script-src**: Allow JavaScript from CDNs and inline scripts (required for some functionality)
- **style-src**: Allow CSS from Google Fonts and inline styles
- **font-src**: Allow fonts from Google Fonts
- **img-src**: Allow images from HTTPS sources, data URLs, and blobs
- **connect-src**: Allow API calls to Printify and font loading
- **frame-src 'none'**: Prevent embedding in frames (clickjacking protection)
- **object-src 'none'**: Block plugins like Flash
- **upgrade-insecure-requests**: Automatically upgrade HTTP to HTTPS

### Implementation Files

1. **docs/csp-template.html** - Template with CSP header
2. **scripts/add-csp.py** - Script to add CSP to all HTML files
3. **Makefile targets** - Automation commands

## Security Benefits

- ✅ **XSS Protection**: Prevents execution of malicious scripts
- ✅ **Data Injection Defense**: Blocks unauthorized resource loading
- ✅ **Clickjacking Prevention**: Prevents iframe embedding
- ✅ **Mixed Content Protection**: Forces HTTPS connections
- ✅ **Plugin Security**: Blocks dangerous plugins

## Monitoring and Reporting

For production deployment, consider adding CSP reporting:

```html
<meta
  http-equiv="Content-Security-Policy-Report-Only"
  content="
  [policy];
  report-uri https://your-csp-report-endpoint.com/report
"
/>
```
