# Downtify

Self-hosted Spotify downloader (henriquesebastiao/downtify, pinned 3.8.1
plus image policy `flux-system:downtify`, gated by the Sunday
image-automation window like everything else).

- UI: https://downtify.forcebyte.org — own accounts (no github-oauth,
  mirroring Navidrome; the friend uses paste-a-link here).
- FIRST LOGIN: default admin / downtify — change the password in
  Settings -> General immediately.
- Downloads land in /music/downtify (the shared `music` PVC mounted at
  /downloads with subPath `downtify`). Navidrome scans /music
  recursively, so files appear there after its rescan.
- Playlist .m3u files: Downtify writes standard M3U that Navidrome picks
  up — verify paths resolve after the first playlist download; if not,
  use Downtify's Navidrome mirror integration (needs the Navidrome
  admin account).
- Sources: YouTube Music by default (no Spotify API key, no Premium).
  slskd as an audio source is a later wiring step (needs the slskd API
  key in a Secret, never in git).
- No CPU limit by policy (limits throttle); memory limit 1Gi for ffmpeg
  bursts. Runs as UID/GID 1000 with fsGroup 1000 (slskd pattern); the
  initContainer chmods the download dir writable.
- CSV library import accepts Soundiiz/TuneMyMusic/Exportify exports —
  the bulk path for the Nov 2 Spotify export (every track URI converts
  to an open.spotify.com/track/<id> link).

## slskd wiring (Nov 2, 2026)
- Downtify reaches slskd over the API (NP egress to slskd:5030, PR #149) AND
  must share slskd's download dir: the slskd-downloads PVC is mounted at
  /slskd in this Deployment (Downtify's slskd.source_dir). Without the mount,
  Soulseek transfers complete but Downtify never sees the files, every
  candidate times out, and downloads fall through to YouTube (bot-blocked).
- Downtify setting slskd.leave_in_place=false so completed files are copied
  into the music library (/downloads) instead of staying in the slskd dir,
  where Navidrome would never scan them.
