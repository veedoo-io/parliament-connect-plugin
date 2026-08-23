# Parliament Connect

Search UK Parliament video clips by what was actually said, from inside Claude
Code, Cowork, or Codex.

## Before you install

**You need a Parliament Connect account on an active plan or trial.** The
connector signs in as you and searches only the MPs your plan covers, so
without an account there is nothing for it to search and the first query will
tell you so. Start at [parliamentconnect.com](https://parliamentconnect.com) —
the trial does not ask for a card.

## What it covers

Clips of MPs speaking in the **House of Commons chamber**, matched against what
was actually spoken in them.

Not covered: the House of Lords, select and public bill committees, Westminster
Hall, and the devolved legislatures. A Lords member will resolve as a member and
then return nothing — that is the chamber, not the member.

## Install

Add the marketplace, then the plugin.

Clone this repo, then add it as a marketplace from the checkout. (Installing by
GitHub slug lands when the repo is published; these are the forms that are
verified working today.)

**Claude Code**

```bash
claude plugin marketplace add ./
claude plugin install parliament-connect@veedoo-plugins
```

**Codex**

```bash
codex plugin marketplace add ./
codex plugin add parliament-connect@veedoo-plugins
```

**Cowork** — install from the plugin directory in the Claude app.

Requires Claude Code 2.1.241 or Codex CLI 0.149.0 and above. On older builds the
skills may load without the server behind them, which looks like an
authentication problem but is a version problem.

## Then sign in — it is a separate step

Installing does **not** sign you in. There is no API key and nothing to paste;
the server registers the client itself and opens a browser for you to approve.

- **Claude Code** — run `/mcp`, pick Parliament Connect, authenticate. For a
  headless or SSH session, the server's full name is
  `plugin:parliament-connect:parliament-connect`.
- **Codex** — run `codex mcp login parliament-connect`. Do not pass a `--scopes`
  list; narrowing the request costs you the refresh token. Separately, some
  clients may currently end up without one regardless, in which case the
  connection needs re-authorising once the access token expires — re-run the
  same login.
- **Cowork** — a Connect prompt appears the first time it is used.

### If you already added the server by hand

Anyone following the earlier setup instructions has a `parliament-connect`
server configured manually. Remove it before or after installing, because the
two do not merge:

- **Claude Code** — `claude mcp remove parliament-connect`. Left in place you
  get two copies of every tool and two sign-in prompts.
- **Codex** — delete the `[mcp_servers.parliament-connect]` block from
  `~/.codex/config.toml`. Left in place it silently overrides the plugin's
  server, so a future change to the plugin is ignored.

Removing the server is a local change only — the old authorisation is still
live on your account. Revoke it in Parliament Connect under **Settings →
Connections**. Grants are listed by the name the AI tool registered under, so
where you have two from the same tool, the stale one is the older grant.

## First query

> Find clips where MPs criticised water companies over sewage discharges. Give
> me the three strongest quotes with speaker, party, date and a link.

If that returns clips, everything is working.

## Two things worth knowing

- The excerpt attached to each result is usually enough to pick the right clip
  without opening anything.
- Matching runs on the spoken word, so the half-remembered sentence is the thing
  to type. A topic label finds less than a phrase someone actually said.

## Other places this works

The same account works in Claude.ai, ChatGPT, and Codex without this plugin —
setup for each is documented at
[parliamentconnect.com/blog/search-parliament-clips-from-chatgpt-and-claude](https://parliamentconnect.com/blog/search-parliament-clips-from-chatgpt-and-claude).

## Support

[parliamentconnect.com/contact](https://parliamentconnect.com/contact)

## Changing this plugin

Run `./scripts/validate.sh` before pushing. Use it rather than
`claude plugin validate .` on its own — with a marketplace manifest in the same
directory, that command skips the skills entirely and still exits 0.

Licensed MIT. See [LICENSE](LICENSE).
