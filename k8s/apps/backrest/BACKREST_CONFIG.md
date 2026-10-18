# Backrest Backup Configuration (Source of Truth)

This document describes the desired Backrest configuration. If the Backrest
config PVC is lost, recreate using these specifications via the Backrest UI.

## Repositories

### b2-repo (Primary)
- Type: Local filesystem
- Path: /mnt/b2/backrest/repo
- Password: (stored in ~/workspace/backrest-repo-password.txt, also in Patrick's password manager)

### mysqlfs-repo (Secondary)
- Type: Local filesystem
- Path: /mnt/mysqlfs/backrest/repo
- Password: (same as b2-repo)

## Plans

### pvc-nightly (Primary - Full backup)
- Repository: b2-repo
- Paths: /pvdata
- Schedule: 0 3 * * * (3 AM local)
- Retention: 7 daily, 4 weekly, 3 monthly
- Purpose: Full PVC backup to B2

### db-critical-mysqlfs (Secondary - Critical DBs)
- Repository: mysqlfs-repo
- Paths:
  - /pvdata/pvc-0855a3a5-5337-4d5b-8d98-8f9b98c64dba_immich_immich-pg-data (Immich Postgres, 334MB)
  - /pvdata/pvc-a2995c1f-b4f4-405c-8767-bd655cf56f05_rybbit_postgres-data (Rybbit Postgres, 158MB)
  - /pvdata/pvc-aff497f4-45c1-4d44-9040-aaf2e085f599_qbittorrent_readarr-data (Readarr, 89MB)
- Schedule: 0 * * * * (hourly)
- Retention: 7 daily, 4 weekly, 3 monthly
- Purpose: Hourly critical database redundancy to mysqlfs

## Notes
- mysqlfs is suitable for small backups (<1GB). Do NOT use for full /pvdata (binlog amplification fills 50GB disk).
- B2 lifecycle rule: keep only last version (prevents 5GB hidden version accumulation).
- After MySQL wipe: apply initial_schema.sql AND all 0000000*.sql update scripts in order.
