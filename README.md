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

These steps serve the page at a subdomain (e.g. `chikkamagaluru.abhagyacharan.xyz`) from a home Ubuntu server behind an existing `cloudflared` tunnel. Pick one of the two serving methods below (Docker or Python/systemd), then follow the shared tunnel steps. Both bind to `127.0.0.1:8087` so only the tunnel reaches them. Adjust the port (`8087`), tunnel name (`websites`), and hostname to your own.

Start by pulling the repo onto the server:

```bash
git clone https://github.com/abhagyacharan/YOUR_REPO_NAME.git chikkamagaluru-src
cd chikkamagaluru-src
```

### Serve the file - Option A: Docker (recommended)

Uses the included `Dockerfile` and `docker-compose.yml` (nginx:alpine, `restart: unless-stopped`).

```bash
docker compose up -d --build
docker compose ps                 # expect "running"
curl -I http://127.0.0.1:8087     # expect HTTP/1.1 200 OK
```

Manage with `docker compose logs -f`, `docker compose restart`, `docker compose down`.

### Serve the file - Option B: Python + systemd (no Docker)

Zero extra installs; Python ships with Ubuntu.

```bash
sudo mkdir -p /var/www/chikkamagaluru
sudo cp itinerary.html /var/www/chikkamagaluru/index.html

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
curl -I http://127.0.0.1:8087     # expect HTTP/1.0 200 OK
```

### Shared tunnel step 1: add the ingress rule

Edit your tunnel config (usually `/etc/cloudflared/config.yml`) and add the hostname **above** the `http_status:404` catch-all:

```yaml
ingress:
  # ... existing rules ...
  - hostname: chikkamagaluru.abhagyacharan.xyz
    service: http://127.0.0.1:8087
  - service: http_status:404
```

### Shared tunnel step 2: route DNS and restart

```bash
cloudflared tunnel route dns websites chikkamagaluru.abhagyacharan.xyz
sudo systemctl restart cloudflared
```

Cloudflare terminates TLS at its edge, so the public URL is HTTPS automatically.

### Updating the page

**Docker (Option A):** rebuild after pulling, since the HTML is baked into the image.

```bash
cd chikkamagaluru-src && git pull
docker compose up -d --build
```

To skip rebuilds, mount the file live instead by using this service in `docker-compose.yml`:

```yaml
services:
  chikkamagaluru:
    image: nginx:alpine
    container_name: chikkamagaluru
    restart: unless-stopped
    ports:
      - "127.0.0.1:8087:80"
    volumes:
      - ./itinerary.html:/usr/share/nginx/html/index.html:ro
```

With the mount, updating is just `git pull` (no rebuild).

**Python/systemd (Option B):** copy a new `index.html` into `/var/www/chikkamagaluru/`. No restart needed - `http.server` reads the file fresh per request.

Either way, hard-refresh (Ctrl+Shift+R) to bypass browser cache.

## License

Personal project. Use freely.
