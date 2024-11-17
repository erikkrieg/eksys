# Server trait

Provides _most_ of the configuration required to join the K3S cluster. Some additional settings that still need to be provided:

- `serverAddr` (at the time of writing chips was the target server).
- `tokenFile` path, but also the token file currently need to be populated imperatively.
- `clusterInit` needs to be forced to `false` on worker nodes.
