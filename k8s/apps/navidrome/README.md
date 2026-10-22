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
- Follow-up (PR B): Soularr (feeds the Lidarr wanted list via slskd; needs
  the Lidarr API key from /config/config.xml after first boot) and Aurral
  (discovery front-end; needs ListenBrainz/Last.fm API keys from Patrick).
