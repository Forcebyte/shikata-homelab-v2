# cs2 notes

## Disabled alternative Service (removed by the image bot, preserved here)

`manifest.yaml` used to carry the Service below as a commented-out block.
The Flux image-automation rewrite (commit e2b4492) stripped it, since the
bot deletes comments from manifests it pins. It is kept here in case the
LoadBalancer variant is ever wanted again — the live manifest uses a
different Service definition.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cs2-modded-service
  namespace: game-server
spec:
  selector:
    app: cs2-modded-server
  ports:
    - name: tcp-27015
      protocol: TCP
      port: 27015
      targetPort: 27015
    - name: udp-27015
      protocol: UDP
      port: 27015
      targetPort: 27015
    - name: tcp-27020
      protocol: TCP
      port: 27020
      targetPort: 27020
    - name: udp-27020
      protocol: UDP
      port: 27020
      targetPort: 27020
  type: LoadBalancer
```
