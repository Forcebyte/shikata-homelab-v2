# rreading-glasses

Self-hosted Readarr metadata server. Uses Hardcover.app as upstream, with a
Postgres cache on the shared Rybbit Postgres.

> These notes used to live as a comment header on `deploy.yaml`. Flux Image
> Automation's manifest rewrites strip comments from files it pins, so the
> documentation lives here now, where the bot can't eat it.

## Scaled to 0 (Nov 15, 2026)
Replicas set to 0 as a stopgap: the app's Postgres connections hang during the
auth handshake (backends stuck in 'authentication', one per crashloop cycle),
which was refilling the shared Postgres connection pool. Postgres itself is up;
the hang affects new connections from this app (and intermittently umami too).
Do not scale back to 1 until the auth hang is diagnosed and fixed.

## Required secrets (create manually, NOT in git)

- `rreading-glasses` (namespace: qbittorrent):
  - `hardcover-auth`: `Bearer <your-hardcover-api-key>`
- `rreading-glasses-db` (namespace: qbittorrent):
  - `password`: postgres password for the `rreading_glasses` user

## Required Postgres setup (run once)

```sql
CREATE DATABASE rreading_glasses;
CREATE USER rreading_glasses WITH PASSWORD '<password>';
GRANT ALL PRIVILEGES ON DATABASE rreading_glasses TO rreading_glasses;
-- then, as frog on the rreading_glasses db:
GRANT ALL ON SCHEMA public TO rreading_glasses;
ALTER SCHEMA public OWNER TO rreading_glasses;
```

## Postgres TLS note
The app builds its Postgres DSN without an sslmode (see PGConfig.DSN() in
upstream), so pgx defaults to sslmode=prefer and tries TLS first. The shared
Postgres has SSL off, and the TLS handshake hangs instead of falling back,
leaving backends stuck in authentication until max_connections is hit
(102 stuck backends, Nov 15 2026 — took down umami too). Fix: PGSSLMODE=disable in the deployment env so pgx skips TLS entirely. Do not remove it unless the
shared Postgres gets SSL enabled.
