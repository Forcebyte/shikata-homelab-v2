# Canada-only filter for the game servers

The game servers (Minecraft, GTNH, Terraria, FTB, rcon) are reachable
directly on the node's public IP — they are not behind Cloudflare. To cut
probe noise, their Traefik TCP routes only accept connections from
Canadian IP space.

## How it works

- `generate-ca-allowlist.py` builds one `MiddlewareTCP` named
  `canada-only` per game namespace at `k8s/apps/<app>/ca-allowlist.yaml`,
  from the aggregated cc=CA zones published by ipdeny (derived from the
  five RIR delegated-stats files): roughly 6,400 IPv4 and 1,100 IPv6
  prefixes.
- Each game's `IngressRouteTCP` references its namespace's middleware.
  Traefik matches on the real connecting IP (the Traefik service runs
  with `externalTrafficPolicy: Local`, PR #111, so source IPs are not
  masqueraded) and silently closes non-matching connections — foreign
  probers get no response at all.
- The allowlist also carries infrastructure ranges (RFC1918, the
  tailnet's 100.64.0.0/10, the WireGuard tunnel range, and the node's
  own public /32, since OCI's Toronto space is not registered as
  cc=CA). These can only appear as sources for traffic arriving via the
  cluster itself, the tailnet, or the WireGuard tunnel — all
  authenticated — never from the open internet.

## What is deliberately NOT filtered

- **qBittorrent** (ports 49155 TCP/UDP): its routes never reference the
  middleware. It needs open inbound for torrent seeding.
- **WireGuard** (51820/UDP): never filtered, so the owner can reach the
  homelab — and, through the tunnel, the game servers — from abroad.
- **Web/websecure**: behind Cloudflare, out of scope.
- **UDP game routes** (Hytale, 5520): Traefik has no middleware support
  for UDP routes at all, so they cannot be filtered at this layer. If
  Hytale is ever unparked and needs this, use a single host nftables
  rule for that port fed by the same prefix list.

## Refresh

RIR allocations drift, so a weekly job on azamilab0 (`~/ca-geoip.sh`,
host cron) re-runs the generator from its own clone and commits any
changes for Flux to apply. To refresh by hand: run the generator from
the repo root, review the diff, commit.

The generator refuses to emit a list that fails its sanity checks
(prefix-count ranges, and a spot check that the owner's Beanfield home
IP is covered).
