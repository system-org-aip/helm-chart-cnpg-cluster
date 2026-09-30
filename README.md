# helm-chart for cnpg cluster managment

## Backup

Disabled by default (`backup.enabled: false`) — existing releases render unchanged.

Two methods (`backup.method`):

- `plugin` (default, recommended) — [Barman Cloud Plugin](https://cloudnative-pg.io/plugin-barman-cloud/).
  The plugin (and cert-manager) must be installed in the Kubernetes cluster. The chart creates an `ObjectStore`
  and adds `spec.plugins` to the `Cluster`.
- `barmanObjectStore` — in-tree `Cluster.spec.backup` (deprecated since CNPG 1.26).

S3 credentials: either `backup.s3Credentials.existingSecret` (keys `ACCESS_KEY_ID`, `ACCESS_SECRET_KEY`,
optional `ACCESS_REGION`) or an `ExternalSecret` `<cluster>-backup-s3` is created from Vault
(`<global.vaultSecretPath>/<cluster>-backup` by default).

```yaml
backup:
  enabled: true
  destinationPath: s3://backups/postgres
  endpointURL: https://minio.example.com
  scheduledBackups:
    - name: daily
      schedule: "0 0 2 * * *"
```

### Enabling on an existing cluster

- Enabling the plugin injects a sidecar into instance pods, so CNPG performs a rolling restart
  (switchover of the primary). Plan a maintenance window.
- `destinationPath` + `serverName` must be empty: barman refuses to archive WAL into a
  location that already holds WAL of another cluster. Set `backup.serverName` to a new value when reusing a bucket path.
- A switch between `barmanObjectStore` and `plugin` requires a manual migration, see the plugin docs.
