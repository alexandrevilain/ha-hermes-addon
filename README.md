# Hermes Agent for Home Assistant

Run [Hermes Agent](https://hermes-agent.nousresearch.com/), the self-improving AI agent
by Nous Research, right inside Home Assistant. It remembers, learns new skills, talks
to you on Telegram, and can see and control your home.

[![Add repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Falexandrevilain%2Fha-hermes-addon)

## What you get

- **Hermes in your sidebar.** The official web dashboard (chat, config, API keys,
  sessions, skills, cron) behind Home Assistant's login. By default, the app opens
  no port.
- **Hermes Desktop and the mobile app (optional).** Turn on remote access to use
  them, and MCP servers that sign in with OAuth (Notion...). Hermes then asks for
  its own login, in the sidebar too.
- **Telegram (and other messaging apps).** The gateway runs 24/7. Set up a bot in
  one QR scan from the dashboard.
- **Home Assistant control.** Hermes can see and control your home, from the
  profile you pick and as a non-admin user you create.
- **Everything persisted.** Config, memory, sessions and skills live in the add-on's
  config folder and are included in your HA backups.
- **Small and boring.** It's the official, pinned Hermes image plus a tiny nginx
  proxy. Hermes runs as a non-root user.

## Install

1. Click the button above, or go to **Settings → Apps → App store → ⋮ →
   Repositories** and add `https://github.com/alexandrevilain/ha-hermes-addon`.
2. Find **Hermes Agent** in the store, then **Install** and **Start**.
3. Open **Hermes** from the sidebar.

Requires a 64-bit system (amd64 or aarch64, e.g. a Raspberry Pi 4/5).

Then see [the documentation](hermes/DOCS.md) (also in the app's **Documentation** tab) to
set up your model, Telegram and Home Assistant access.

## Development

See [DEV.md](DEV.md).

## Credits

This is an unofficial add-on, not affiliated with Nous Research. Hermes Agent and its
mascot artwork are © Nous Research, used under the
[MIT License](https://github.com/NousResearch/hermes-agent/blob/main/LICENSE).

