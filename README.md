<div align="center">

<img src=".github/logo.png" alt="Shikata Homelab Logo" width="200"/>

# Shikata Homelab (v2)

<p><i>Homelab Configurations for Shikata, a OCI-Based HomeLab I use for random stuff</i></p>

</div>


## What is this?

Originally, back in ~2021, I had a fairly large homelab within my apartment which contained a ProxMox instance and a bunch of created configurations and systems, this is mostly documented under [my GitHub site I barely use](https://forcebyte.github.io/posts/2021-17-01-shikata-homelab-2/) - overall, it worked, but as I moved from place to place this became more and more annoying to keep up - specifically; the overall power draw from servers and costs associated to it became a bit of an annoyance for something I don't use as often as i'd like (outside of a few systems)

Thus, in 2025, I decided to try to replicate this into a single set of OCI (Oracle Cloud) free-tier instances, and perform most of the GitOps operations in a MonoRepo.


### How does this work?

In general, this repository is split into the following:

```
C:.
├───k8s
│   └───apps                 # Contains Flux configurations for various homelab projects
│       ├───calibre
|       ...
│       ├───flux-system
│       └───traefik-addons
├───qemu                     # Contains a Qemu hypervisor for ARM -> AMD Support
└───terraform                # Contains TFE code for secret additions to the cluster
```

The *Terraform* configuration does two things, specifically:
- Adds individual secrets (Cloudflare Tokens, Prowlarr/Sonarr) to namespaces
- Set up flux default config pointing to k8s folder

the *k8s* folder is FluxCD's base folder

### Why?

A few reasons, specifically:
- OCI's free tier is very good, the same amount of compute at my datacenter can be sufficiently done using the Ampere instances that can replace it easily
- Outside of storage, the free-tier connectivity and availability is way better than local
- Power and consumption costs are pretty much eliminated, allowing like-for-like utilization of services

The only *real* limitation of this is storage costs, at the moment my homelab doesnt have a large amount of storage requirements, but i'll likely have to figure out a good storage mirroring solution down the road (syncthing, etc)

### Other Notes

- Flux auto-syncs this repository every 30 seconds
- Terraform plan/applies this repository on file changes to the `terraform` folder

