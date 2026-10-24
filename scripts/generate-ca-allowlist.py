#!/usr/bin/env python3
"""Generate the Canada-only MiddlewareTCP allowlists for the game servers.

Fetches the aggregated cc=CA prefix zones (built by ipdeny from the five
RIR delegated-stats files), validates them, and writes one MiddlewareTCP
manifest per game namespace to k8s/apps/<app>/ca-allowlist.yaml.

The list also carries infrastructure exceptions so cluster-internal,
tailnet and WireGuard-tunnel sources keep working. Those ranges can only
ever be the source of traffic that arrives via an authenticated network
or from inside the cluster — never from the open internet — so they do
not weaken the internet-facing filter.

Run from the repo root. The weekly ca-geoip job on azamilab0 runs this
and commits any changes. See scripts/README-ca-allowlist.md.
"""

import ipaddress
import sys
import urllib.request

V4_URL = "https://www.ipdeny.com/ipblocks/data/aggregated/ca-aggregated.zone"
V6_URL = "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/ca-aggregated.zone"

# App dir == namespace for every game app.
APPS = ["gregtech", "minecraft", "minecraft-ftb", "terraria", "terraria-calamity", "rcon"]

# Infrastructure exceptions, emitted first.
EXTRA = [
    "10.0.0.0/8",        # cluster pod/service networks + WireGuard tunnel addressing
    "100.64.0.0/10",     # tailnet (Tailscale CGNAT range)
    "140.238.159.81/32", # this node's public IP (OCI ca-toronto space is not cc=CA)
    "172.16.0.0/12",     # RFC1918
    "192.168.0.0/16",    # RFC1918
    "::1/128",           # loopback
]

HEADER = """# GENERATED FILE - do not edit by hand.
# Canada-only source filter for this namespace's game-server TCP route.
# Generator: scripts/generate-ca-allowlist.py - refreshed weekly by the
# ca-geoip job on azamilab0. See scripts/README-ca-allowlist.md.
"""


def fetch_zone(url, version, lo, hi):
    with urllib.request.urlopen(url, timeout=60) as resp:
        text = resp.read().decode()
    nets = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        net = ipaddress.ip_network(line)
        if net.version != version:
            raise SystemExit(f"{url}: unexpected IPv{net.version} entry {line}")
        nets.append(net)
    if not (lo <= len(nets) <= hi):
        raise SystemExit(f"{url}: {len(nets)} prefixes outside sanity range {lo}-{hi}")
    return sorted(set(nets))


def nft_sets(v4, v6, path):
    def fmt(items):
        lines, cur = [], "        "
        for n in items:
            item = f"{n}, "
            if len(cur) + len(item) > 100:
                lines.append(cur.rstrip())
                cur = "        "
            cur += item
        if cur.strip():
            lines.append(cur.rstrip().rstrip(","))
        return "\n".join(lines)

    v4all = [e for e in EXTRA if ":" not in e] + [str(n) for n in v4]
    v6all = [e for e in EXTRA if ":" in e] + [str(n) for n in v6]
    with open(path, "w") as fh:
        fh.write("# GENERATED FILE - do not edit by hand.\n")
        fh.write("# Canada allowlist sets for table inet geo_filter (azamilab0 host firewall).\n")
        fh.write("# Generator: scripts/generate-ca-allowlist.py --nft-out. See scripts/README-ca-allowlist.md.\n")
        fh.write("set ca4 {\n    type ipv4_addr\n    flags interval\n    elements = {\n")
        fh.write(fmt(v4all))
        fh.write("\n    }\n}\n")
        fh.write("set ca6 {\n    type ipv6_addr\n    flags interval\n    elements = {\n")
        fh.write(fmt(v6all))
        fh.write("\n    }\n}\n")
    print(f"wrote {path}: nft sets ({len(v4all)} v4, {len(v6all)} v6)")


def main():
    nft_out = None
    if "--nft-out" in sys.argv:
        nft_out = sys.argv[sys.argv.index("--nft-out") + 1]
    v4 = fetch_zone(V4_URL, 4, 4000, 10000)
    v6 = fetch_zone(V6_URL, 6, 500, 3000)

    # Spot check: the owner's home ISP (Beanfield, Toronto) must be covered,
    # or the filter would lock out the very traffic it exists to allow.
    home = ipaddress.ip_address("198.98.113.198")
    if not any(home in n for n in v4):
        raise SystemExit("sanity check failed: Beanfield home IP not in the CA list")

    ranges = EXTRA + [str(n) for n in v4] + [str(n) for n in v6]
    body = "".join(f"      - {r}\n" for r in ranges)

    for app in APPS:
        path = f"k8s/apps/{app}/ca-allowlist.yaml"
        content = (
            HEADER
            + "apiVersion: traefik.io/v1alpha1\n"
            + "kind: MiddlewareTCP\n"
            + "metadata:\n"
            + "  name: canada-only\n"
            + f"  namespace: {app}\n"
            + "spec:\n"
            + "  ipAllowList:\n"
            + "    sourceRange:\n"
            + body
        )
        with open(path, "w") as fh:
            fh.write(content)
        print(f"wrote {path}: {len(ranges)} ranges ({len(v4)} CA v4, {len(v6)} CA v6, {len(EXTRA)} infra)")

    if nft_out:
        nft_sets(v4, v6, nft_out)


if __name__ == "__main__":
    sys.exit(main())
