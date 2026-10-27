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

## Remote access (Hermes Desktop, mobile app, MCP OAuth)

[Hermes Desktop](https://hermes-agent.nousresearch.com/docs/user-guide/desktop),
the mobile app and MCP servers that sign in with OAuth (Notion...) can't use the
sidebar. They need port `9119`. This port is not published by default. It only
answers once you set up remote access.

### Logging in

The sidebar goes through Home Assistant, which already knows who you are. So by
default, Hermes doesn't ask for a login.

Once you set up remote access, Hermes asks for its own login everywhere, in the
sidebar too. Hermes can't tell if a request comes from the sidebar or from
outside, so it asks every time. Your browser remembers the login, so you only
enter it once per browser.

### 1. Turn remote access on

1. Open the app's **Configuration** tab.
2. Fill in the [Remote access](#option-remote_access) section:
   - the public URL: the address you will use to reach Hermes, e.g.
     `https://ha.example.com:9119`;
   - a username;
   - a password.
3. Restart the app.

### 2. Reach Hermes

Pick one of these three ways.

**With Home Assistant's certificate.** Use this if Home Assistant already uses
HTTPS with its own certificate (DuckDNS, Let's Encrypt..., files in `/ssl`):

1. Turn on `ssl`.
2. Publish `9119` in the app's **Network** section.
3. Forward port `9119` on your router, like you did for Home Assistant.

Hermes is then at e.g. `https://ha.example.com:9119`.

Home Assistant Cloud (Nabu Casa) does not work here: it only gives access to
Home Assistant, not to app ports. Use a proxy app instead.

**With a proxy or tunnel app** (Cloudflared, NGINX Proxy Manager...):

1. Leave `ssl` off.
2. Point the proxy at `http://<app hostname>:9119`. You can find the hostname on the app's **Info** tab.

The proxy must keep the `Host` header and support WebSockets. You don't need to
publish any port.

**On a trusted network** (Tailscale, LAN):

1. Leave `ssl` off.
2. Publish `9119`.
3. Use `http://<address>:9119`.

This is plain HTTP, without encryption. MCP OAuth providers usually refuse it.

The public URL must match the address you use, with the same host. Hermes refuses requests for any other host.

### 3. Use it

- **Hermes Desktop:** go to **Settings → Gateways → Remote gateway**, enter the address and sign in.
- **MCP OAuth:** connect the MCP server from the dashboard. After you sign in, the provider sends you back to the public URL.

## Configuration

**Note**: _Restart the app after you change the configuration._

Example app configuration:

```yaml
remote_access:
  public_url: https://ha.example.com:9119
  username: me
  password: a-long-unique-password
ssl: true
certfile: fullchain.pem
keyfile: privkey.pem
```

**Note**: _This is only an example. Don't copy and paste it: use your own values._

### Option: `remote_access`

Hermes' own login, for [remote access](#remote-access-hermes-desktop-mobile-app-mcp-oauth):

- `public_url`: the address you use to reach Hermes from outside, with the host
  and the port. Setting it turns remote access on:
  - port `9119` starts to answer. Before that, Hermes refuses every request on it;
  - Hermes asks for its login everywhere, in the sidebar too.

  If `username` or `password` is empty, the app ignores `public_url`. The app's
  **Log** tab then tells you why.
- `username` and `password`: Hermes' login. Use a long, unique password: anyone
  on the internet can try it.

Hermes also has [other logins](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard#authentication-gated-mode),
such as Sign in with Nous Portal. To use one, set its keys in Hermes instead.
Keys in Hermes' `.env` win over these options.

### Option: `ssl`

Serves port `9119` over HTTPS, with Home Assistant's certificate. It doesn't
change the sidebar. Leave it off if you use a proxy or tunnel app: the app
already handles HTTPS.

If a certificate file is missing, port `9119` stays closed. The app never falls
back to plain HTTP. The app's **Log** tab tells you which file is missing.

### Option: `certfile`

The certificate file to use for SSL.

**Note**: _The file MUST be in `/ssl/`, which is the default._

### Option: `keyfile`

The private key file to use for SSL.

**Note**: _The file MUST be in `/ssl/`, which is the default._

## Where is my data?

Inside the container: `/opt/data`. On the host: `/app_configs/<id>_hermes/`
(`addon_configs` on older HA versions). It survives updates and is backed up.
During a backup, Home Assistant stops the app (Telegram too) until the copy is
done. This way, the backup never contains a half-written Hermes database.

## Security

- By default, you can only reach the dashboard from the Home Assistant sidebar.
  The app publishes no port, and its proxy only accepts requests from Home
  Assistant.
- Anyone with HA admin access can use Hermes.
- Port `9119` leads to the same dashboard as the sidebar. Without a public URL,
  Hermes refuses every request on this port. With a public URL, Hermes asks for
  its login everywhere.
- Hermes keeps this login in its environment, like your API keys. So an agent
  with terminal tools can read it.
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

## Known quirks

- Once you set up remote access, the sidebar asks for the Hermes login too. See
  [Logging in](#logging-in).
