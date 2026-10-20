# rreading-glasses

Self-hosted Readarr metadata server. Uses Hardcover.app as upstream, with a
Postgres cache on the shared Rybbit Postgres.

> These notes used to live as a comment header on `deploy.yaml`. Flux Image
> Automation's manifest rewrites strip comments from files it pins, so the
> documentation lives here now, where the bot can't eat it.

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
