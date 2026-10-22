# Music stack (Oct 2026)

Streaming + acquisition stack replacing Spotify, all in the qbittorrent
namespace (house pattern: file-sharing apps co-locate with the shared PVCs,
same as Readarr).

- navidrome/ — Navidrome server. Mounts the shared music PVC (30Gi)
  at /music, own data on navidrome-data. Public at navidrome.forcebyte.org.
  DELIBERATE: no github-oauth middleware on this route — Navidrome has its
  own user accounts (a second account is for the friend who shared the
  Spotify plan). Scrobbling to ListenBrainz/Last.fm is per-user, set in the
  Navidrome UI.
- lidarr/ — Lidarr (linuxserver). Mounts /config (lidarr-config),
  /downloads (qbittorrent-downloads), /music, /slskd-downloads. Admin UI at
  lidarr.forcebyte.org behind github-oauth. Wire-up after first boot:
  Prowlarr app-sync + qBittorrent client + root folder /music, quality
  profile LOSSY (library is lossy by decision, Oct 22 2026).
- slskd/ — Soulseek daemon. Downloads to slskd-downloads PVC (15Gi),
  shares /music read-only (Soulseek citizenship). Soulseek credentials come
  from the out-of-band Secret slskd-soulseek (keys SLSKD_SLSK_USERNAME /
  SLSKD_SLSK_PASSWORD); envFrom is optional so the pod runs before the
  Secret exists. Listen port 50300 is NOT publicly exposed (works, with
  reduced peer reachability; expose via IngressRouteTCP only if needed).
- soularr/ — Soularr (PR B). Reads the Lidarr wanted list and downloads via
  slskd, then triggers Lidarr imports. Config (config.ini with the Lidarr +
  slskd API keys) lives on the soularr-data PVC, NOT in git (Backrest-style);
  editable later via its web UI at soularr.forcebyte.org. Search settings are
  MP3-only (allowed_filetypes = mp3 320,mp3) to match the lossy decision.
  slskd API key lives in the out-of-band Secret slskd-config (slskd.yml,
  mounted at /app/slskd.yml); slskd runs as UID 1000 with its app dir on the
  slskd-data PVC so file ownership agrees across lidarr/slskd/soularr.
- aurral/ — Aurral discovery front-end at aurral.forcebyte.org. Config on
  aurral-config PVC; media mounted under /data (music, downloads,
  slskd-downloads). Integrations (Lidarr, ListenBrainz user Forcebyte,
  Navidrome) are connected in its UI after the admin account is created.
