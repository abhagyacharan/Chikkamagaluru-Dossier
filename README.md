# The Chikmagalur Dossier

A single-file, self-contained trip itinerary for a 4-day monsoon run to Chikmagalur (18-21 Jul 2026). Five people, one XUV 3XO, Karnataka's highest peak, two waterfalls, and a strict per-head budget.

Built as one static `itinerary.html` with a dark "field dossier" aesthetic. No build step, no dependencies to install. The only external resource is Google Fonts.

## What's inside

- **Route** - day-by-day plan on an elevation spine (drive, summit, waterfalls, return).
- **Budget ledger** - per-head cost breakdown with an animated split bar, against a ₹15K cap.
- **Safety & tips** - monsoon-specific warnings (leeches, currents, mountain roads, network).
- **Essentials** - interactive pack-list checkboxes across documents, gear, health, and vehicle.
- **FAQ** - the practical questions that come up on the drive.

## Features

- Fully responsive, mobile-first.
- Scroll-progress bar, nav scroll-spy, staggered scroll reveals, hero word-reveal, film-grain and rain ambience.
- Respects `prefers-reduced-motion` (all motion collapses to static).
- Self-contained: open the file in any browser and it just works.

## View locally

Open `itinerary.html` directly in a browser, or serve it:

```bash
python3 -m http.server 8087
# then visit http://127.0.0.1:8087/itinerary.html
```

## Deploy behind a Cloudflare tunnel

These steps serve the page at a subdomain (e.g. `chikkamagaluru.abhagyacharan.xyz`) from a home Ubuntu server, using Python's built-in static server as a systemd service behind an existing `cloudflared` tunnel. Adjust the port (`8087`), tunnel name (`websites`), and hostname to your own.

### 1. Place the file

```bash
sudo mkdir -p /var/www/chikkamagaluru
sudo cp itinerary.html /var/www/chikkamagaluru/index.html
```

Naming it `index.html` makes the root URL serve it directly.

### 2. Run it as a systemd service

```bash
sudo tee /etc/systemd/system/chikkamagaluru.service > /dev/null <<'EOF'
[Unit]
Description=Chikkamagaluru itinerary static site
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/www/chikkamagaluru
ExecStart=/usr/bin/python3 -m http.server 8087 --bind 127.0.0.1
Restart=on-failure
User=www-data

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now chikkamagaluru.service
```

`--bind 127.0.0.1` keeps the server local-only; only the tunnel reaches it.

### 3. Add the ingress rule

Edit your tunnel config (usually `/etc/cloudflared/config.yml`) and add the hostname **above** the `http_status:404` catch-all:

```yaml
ingress:
  # ... existing rules ...
  - hostname: chikkamagaluru.abhagyacharan.xyz
    service: http://127.0.0.1:8087
  - service: http_status:404
```

### 4. Route DNS and restart

```bash
cloudflared tunnel route dns websites chikkamagaluru.abhagyacharan.xyz
sudo systemctl restart cloudflared
```

Cloudflare terminates TLS at its edge, so the public URL is HTTPS automatically.

### Updating the page

Copy a new `index.html` into `/var/www/chikkamagaluru/`. No restart needed - `http.server` reads the file fresh per request. Hard-refresh (Ctrl+Shift+R) to bypass browser cache.

## License

Personal project. Use freely.
