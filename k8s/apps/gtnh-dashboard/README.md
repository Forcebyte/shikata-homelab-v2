# GTNH RCON Dashboard

A website showing live info about the GTNH Minecraft server: players, TPS,
pod CPU/memory, view-distance, and uptime. Reachable at
https://gtnh-dash.forcebyte.org (behind the github-oauth middleware, same as
the homepage).

## How it works (no in-game items, no server mods)

The app is a single pure-Python (stdlib only) program (app.py, shipped in
the gtnh-dashboard-app ConfigMap) running on the generic python:3.14-slim
image. Every 30 seconds it polls:

- Minecraft server-list ping (TCP to gregtech.gregtech.svc.cluster.local:25567):
  version, MOTD, players online/max and sample names.
- RCON (TCP to the same Service on port 25575): list and forge tps.
  The Overall and Dim 0 (overworld) TPS / mean tick time are parsed out.
- Kubernetes Metrics API (metrics.k8s.io, namespace gregtech, pod
  label app=gregtech): the server pod CPU (millicores) and memory (MiB).
- Kubernetes API (apps/v1, deployment gregtech in namespace
  gregtech): the VIEW_DISTANCE env var, so the dashboard shows the value
  the deployment actually carries.

It serves a self-contained HTML page on :8080 (GET /) and a JSON status
endpoint (GET /api/status). If the server is down it reports
online: false and keeps showing the last-known values; it never crashes.

## Data sources and limits

- Per-multiblock machine state (for example EU stored in a specific machine)
  is NOT readable from outside the game. Only OpenComputers or a mod could
  see it, and that route was declined, so the dashboard is server-level info
  only (players, TPS, memory, uptime).
- History is a rolling 24h of 30s samples kept in memory; the latest snapshot
  is persisted to /data/state.json on an emptyDir so a pod restart keeps
  the most recent reading, but the chart history resets on pod restart.
- The RCON password is NOT in git. It lives in the live-only Secret
  gtnh-rcon (namespace gtnh-dashboard, key rcon-password), created with
  kubectl from the GTNH pod server.properties. If the namespace is ever
  deleted, recreate that Secret before the pod starts.

## Why VIEW_DISTANCE comes from the Deployment, not server.properties

The itzg image rewrites server.properties from its env vars at every
container start, and the server writes its in-memory config back on
shutdown, so server.properties is an output, not a source. The env var in
git (k8s/apps/gregtech/deploy.yaml) is the source of truth, and the
dashboard reads it from the live Deployment via the Kubernetes API.

## Networking

- The dashboard NetworkPolicy allows ingress only from Traefik (port 8080)
  and egress to DNS (UDP 53), the gregtech namespace (TCP 25565/25567/25575),
  and 0.0.0.0/0:443 (covers the Kubernetes API server).
- The gregtech Service gained a rcon port (25575) and the gregtech
  NetworkPolicy gained an ingress rule for the gtnh-dashboard namespace
  (ports 25565 + 25575). The matching egress half lives in this app policy.

## Resources

Requests 64Mi, limits 128Mi, no CPU request/limit. Memory is tight on this
node (it hung on Nov 14), so keep it small.
