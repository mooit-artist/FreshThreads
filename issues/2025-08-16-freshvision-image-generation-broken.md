# Issue: FreshVision image generation broken when served via http-server

- Status: Closed
- Opened: 2025-08-16
- Closed: 2025-08-16
- Components: `docs/freshvision.html`, `comfyui_web_interface.py`
- Severity: High (core feature unavailable)

## Summary
When serving the FreshVision UI from http://127.0.0.1:5500 (VS Code http-server), clicking Generate failed. The frontend posted to `/generate` on the same origin (5500), but the Python backend listens on http://localhost:8080.

## Impact
- Users could not generate images from the FreshVision page when opened via the static server.
- Requests to `/generate` and `/status` failed due to wrong origin.

## Root Cause
Frontend used relative fetch paths assuming the backend shared the same origin. In local dev, the UI runs on 5500 while the backend runs on 8080.

## Resolution
- Updated `docs/freshvision.html`:
  - Introduced `BACKEND` base URL (uses current origin if 8080; otherwise `http://localhost:8080`).
  - Switched endpoints to `${BACKEND}/generate` and `${BACKEND}/status`.
  - Corrected ComfyUI payload to `{ ai_service: 'comfyui', concept, theme, speed }`.
  - Normalized returned image URLs so `/generated_designs/...` resolve across ports.
- Started backend via `python3 comfyui_web_interface.py`.

## Verification
- Successful POST `/generate` responses and 200 GETs for `/generated_designs/*.png`.
- UI displays generated images and enables download.

## Follow-ups
- Optional: Add VS Code task to start the Python backend alongside the HTTP server.
- Optional: Document local dev steps in README.
