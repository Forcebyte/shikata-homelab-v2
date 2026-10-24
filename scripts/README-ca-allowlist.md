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

## Host firewall layer

Traefik is a proxy: it must accept a TCP connection before it can check
and close it, so handshake-only port scanners still see the game ports
as open. A second, kernel-level layer on azamilab0 closes that gap:

- nftables table `inet geo_filter` (host files `/etc/nftables/geo-filter.nft`
  + generated `/etc/nftables/ca-sets.nft`, loaded at boot by the
  `geo-filter.service` systemd unit, which runs before k3s) drops any
  packet arriving on the WAN interface (`enp0s6`) to the six game TCP
  ports whose source is not in the same Canada sets — before kube-proxy
  NAT and before Traefik. Non-Canadian scanners now get silence: SYNs
  are dropped, not answered. `nft list chain inet geo_filter prerouting`
  shows the drop counters.
- qBittorrent and WireGuard are not in the port list, so they stay open
  exactly as before.
- Rollback is one command: `sudo nft delete table inet geo_filter`
  (the Traefik layer keeps working on its own).

## What is deliberately NOT filtered

- **qBittorrent** (ports 49155 TCP/UDP): its routes never reference the
  middleware. It needs open inbound for torrent seeding.
- **WireGuard** (51820/UDP): never filtered, so the owner can reach the
  homelab — and, through the tunnel, the game servers — from abroad.
- **Web/websecure**: behind Cloudflare, out of scope.
- **UDP game routes** (Hytale, 5520): Traefik has no middleware support
  for UDP routes at all, so they cannot be filtered at this layer. If
  Hytale is ever unparked, extend the host table below with a UDP rule
  for that port fed by the same sets.

## Refresh

RIR allocations drift, so a weekly job on azamilab0 (`~/ca-geoip.sh`,
host cron) re-runs the generator from its own clone and commits any
changes for Flux to apply.
The same run regenerates the host firewall sets (`--nft-out`) and
reloads the nft table; the reload is check-then-apply and atomic, so a
bad list can never take the running table down. To refresh by hand: run the generator from
the repo root, review the diff, commit.

The generator refuses to emit a list that fails its sanity checks
(prefix-count ranges, and a spot check that the owner's Beanfield home
IP is covered).
