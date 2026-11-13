# Backrest

Hourly critical-DB backups (mysqlfs repo) and the nightly PVC backup
(B2 repo) run from this pod.

## Liveness probe

The container has an exec liveness probe that stats
/mnt/mysqlfs/backrest/repo/config every 60s (3 consecutive failures
restarts the pod). The mysqlfs FUSE mount is a hostPath: when
mysqlfs.service restarts, the pod keeps pointing at the dead mount
instance and every restic run fails with transport endpoint is not
connected until the pod restarts. The probe makes that recovery
automatic. The same failure happened Oct 18 and Nov 12, 2026.
