# Shared Postgres

The cluster shared PostgreSQL 18 instance (superuser frog), home to the
umami and rreading_glasses databases. Consumers: the Umami app (ns umami)
and rreading-glasses (ns qbittorrent), both via
postgres.postgres.svc.cluster.local:5432.

The POSTGRES_PASSWORD lives in the postgres Secret in this namespace,
created out-of-band (never in git).

Migrated out of the retired rybbit namespace on 2026-10-21 (the instance
originally served Rybbit; Rybbit itself was decommissioned the same day).
Data moved with a logical pg_dumpall copy; the old volume was retained
until the new instance verified, then deleted.
