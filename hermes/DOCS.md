# Home Assistant App: Hermes Agent

## First steps

1. In the dashboard, pick a model and add your provider's API key
   (OpenRouter, Anthropic, OpenAI…).
2. **Messaging → Telegram → Create with QR**: scan it in Telegram, done. Only your
   account is allowed to talk to the bot.
3. Say hi. Once Home Assistant access (below) is set up, try:
   *"Turn off the living room lights."*

## Home Assistant access

Hermes gets no access to Home Assistant by default. You decide which profile gets
it, and with which rights:

1. In Home Assistant, create a dedicated **non-admin** user (e.g. `hermes`), log in
   as that user, then **Profile → Security → Long-lived access tokens → Create token**.
2. In the Hermes dashboard, create the profile that will run your home if you want
   one (**Profiles → New Profile**, e.g. `home`), then select it in the
   **Managing profile** switcher at the top of the sidebar.
3. **Keys → Add a custom key**, twice:
   - `HASS_URL` = `http://homeassistant:8123`
   - `HASS_TOKEN` = the token from step 1
4. Restart the gateway from the status page.

Only that profile can reach Home Assistant. To revoke access, delete the token in
Home Assistant.

## Where is my data?

Inside the container: `/opt/data`. On the host: `/app_configs/<id>_hermes/`
(`addon_configs` on older HA versions). It survives updates and is backed up.

## Security

- The dashboard is only reachable through Home Assistant ingress. The add-on maps
  no ports, and the proxy only accepts the ingress gateway.
- Anyone with HA admin access can use Hermes.
- In Home Assistant, Hermes acts as the user whose token you gave it. Keep that
  user non-admin: it can then control your devices but not change your HA setup
  (integrations, users, add-ons).
- The add-on has no Home Assistant API access of its own. The only way in is the
  token you add to a profile, stored in its `.env` (and in your HA backups) like
  your other API keys.
- Profiles are not a hard security boundary: they all run as the same user, so an
  agent with terminal or file tools in another profile can still read that `.env`.
  Turn those tools off in the other profiles if that matters to you.
- Telegram uses polling, so nothing is exposed to the internet.
