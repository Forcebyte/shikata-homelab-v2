# Image controller scale-to-zero

The image-reflector-controller and image-automation-controller only do
useful work around the Sunday image-update gate (02:00–04:00
America/Toronto, when the ImageUpdateAutomation is unsuspended by
`~/iua-gate.sh`). The rest of the week the reflector just scans the 31
ImageRepositories every 30 minutes — and OOMKills on the tag-list spikes —
while the automation controller sits suspended, doing nothing.

So these two deployments run only Sunday 01:00–05:00 Toronto time:

- `image-controllers-scale-up` (Sun 01:00): scales both to 1 replica.
  The reflector then has an hour to do a full 31-repo scan before the
  gate opens at 02:00.
- `image-controllers-scale-down` (Sun 05:00): scales both to 0 replicas,
  an hour after the gate closes, so any in-flight update commits finish.

Savings while off: ~256Mi of booked requests (~216Mi actual usage).

## How it survives Flux

Both deployments carry the annotation
`kustomize.toolkit.fluxcd.io/reconcile: disabled`, so the
kustomize-controller leaves their replica count alone and the CronJobs'
scaling sticks. **While that annotation is present, git changes to those
two deployments do NOT apply.** That is why the reflector's 1Gi memory
limit (PR #154) landed before the annotation was added: the cold-start
Sunday scan is the biggest spike of all, and the limit has to be in place
first.

To change either deployment (image, resources, args): remove the
annotation from the manifest, let Flux apply, then re-add it.

## RBAC

The CronJobs run as ServiceAccount `image-scale-cron`, whose Role permits
only `get` on the two deployments and `get`/`update`/`patch` on their
`deployments/scale` subresources — nothing else, nowhere else.

## Failure mode

If the Sunday 01:00 scale-up fails (or the reflector's full scan is slow),
that week's image updates silently don't land — there is no retry until
the next Sunday. The CronJob history (`kubectl -n flux-system get jobs`)
is the place to check. The image-automation-controller's own image is not
managed by an ImagePolicy, so the annotation does not freeze its updates.
