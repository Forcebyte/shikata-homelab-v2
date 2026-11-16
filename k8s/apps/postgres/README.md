# Shared Postgres

The cluster shared PostgreSQL 18 instance (superuser frog), home to the
umami and rreading_glasses databases. Consumers: the Umami app (ns umami)
and rreading-glasses (ns qbittorrent), both via
postgres.postgres.svc.cluster.local:5432.

## io_method=sync (Nov 15, 2026)
Postgres 18 defaults to async I/O (io_method=worker, 3 io workers). On this
ARM64 box, new connections hang in 'authentication' forever: the backend
waits on a read buffer from the AIO workers and the wakeup never arrives
(likely AppArmor/container signal blocking; see Ubuntu bug 2172640 for the
same symptom on ARM64/k3s). Single-user mode and Postgres 17 work fine.
Fix: run postgres with '-c io_method=sync' (args in deploy.yaml), which
disables the AIO workers and uses synchronous I/O. Verified Nov 15: a fresh
Postgres 18 with io_method=sync accepts connections instantly, while the
default worker mode hangs. Do NOT remove this unless the underlying
AppArmor/signal issue is fixed and re-tested.

The POSTGRES_PASSWORD lives in the postgres Secret in this namespace,
created out-of-band (never in git).

Migrated out of the retired rybbit namespace on 2026-10-21 (the instance
originally served Rybbit; Rybbit itself was decommissioned the same day).
Data moved with a logical pg_dumpall copy; the old volume was retained
until the new instance verified, then deleted.
