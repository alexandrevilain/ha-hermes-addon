# Testing the add-on during development

## 1. Local smoke test (Docker, no Home Assistant)

Checks that the image builds and that s6 starts the dashboard, nginx and the gateway.

```sh
docker build -t hermes-addon-dev hermes/
docker run --rm -d --name hermes-dev -v hermes-dev-data:/opt/data hermes-addon-dev
docker logs -f hermes-dev                      # Ctrl-C once the dashboard is listening
docker exec hermes-dev curl -s -o /dev/null -w '%{http_code}\n' \
  -H 'X-Ingress-Path: /api/hassio_ingress/test' http://127.0.0.1:8099/   # expect 200
docker rm -f hermes-dev
```

The `hermes-dev-data` volume holds what gets persisted (`config.yaml`, `.env`,
sessions…). Run `docker volume rm hermes-dev-data` to start fresh. (Avoid bind
mounts on macOS: SQLite doesn't cope well across the VM boundary.)

## 2. Local Home Assistant (Docker, with Supervisor)

`dev.sh` runs Home Assistant + Supervisor in one privileged container (the official
add-on devcontainer image), with real ingress and the sidebar panel.

```sh
./dev.sh up       # http://localhost:7123, onboard once (first boot takes a few minutes)
./dev.sh reload   # copy hermes/ in, then build + (re)start the add-on (~15 s)
./dev.sh watch    # same, on every change under hermes/
./dev.sh logs     # add-on logs
./dev.sh down     # state is kept in the hermes-ha-* volumes; docker volume rm them to reset
```

From inside Hermes, Home Assistant is at `http://homeassistant:8123`. Run any other
`ha` command with `docker exec hermes-ha ha …`.

## 3. Real test in Home Assistant (local add-on)

1. Install the **Samba share** or **Advanced SSH & Web Terminal** add-on in HA.
2. Copy the `hermes/` folder to `/local_apps/hermes/` (`/addons/` on older HA versions):
   ```sh
   rsync -av --delete hermes/ root@homeassistant.local:/local_apps/hermes/   # rsync: add it to the SSH app's `packages`
   ```
   Then delete the `image:` line in the copied `config.yaml`, or HA pulls the
   published image instead of building your folder.
3. **Settings → Apps → App store → ⋮ → Check for updates**.
   The app shows up under **Local apps** → **Install** → **Start**.
4. Open **Hermes** from the sidebar.

After a change: copy the folder again, then hit **Rebuild** on the add-on page
(or bump `version` in `config.yaml` so HA offers an update).

Logs: the add-on's **Log** tab, or `ha addons logs local_hermes` over SSH.

## 4. Checklist

- [ ] The dashboard renders in the sidebar (CSS/JS load, no blank page).
- [ ] The **Chat** tab opens the TUI (WebSocket works through ingress).
- [ ] Model + API key can be configured from the dashboard.
- [ ] **Messaging → Telegram → Create with QR**, then a message to the bot gets a reply.
- [ ] With `HASS_URL`/`HASS_TOKEN` set in one profile (see hermes/DOCS.md), its agent can
      read an HA entity's state; another profile's agent can't.
- [ ] Restart the add-on: config, sessions and Telegram are still there.
- [ ] Port 8099 is not reachable from the LAN.

## Data

All Hermes state lives in the container's `/opt/data`, i.e. on the host at
`/app_configs/<id>_hermes/` (`addon_configs` on older versions). Included in HA backups.

## Releasing

Versions and `hermes/CHANGELOG.md` are handled by
[release-please](https://github.com/googleapis/release-please), from
[Conventional Commits](https://www.conventionalcommits.org/) (with squash merges, the PR title):

- `fix: …` → patch, `feat: …` → minor, `feat!: …` → major. `chore:`, `docs:`, `ci:` → no release.
- Renovate's Hermes bumps come in as `fix(deps): …`, so each one ships as a patch.

On every push to `main`, release-please keeps a **release PR** up to date (version in
`hermes/config.yaml` + changelog). Merging it creates the release, and the workflow then
publishes `ghcr.io/alexandrevilain/ha-hermes-addon:<version>` (amd64 + aarch64).

One-time setup on GitHub:
- **Settings → Actions → General → Allow GitHub Actions to create and approve pull requests.**
- After the first publish, make the GHCR package public (GitHub → Packages →
  ha-hermes-addon → Package settings).
