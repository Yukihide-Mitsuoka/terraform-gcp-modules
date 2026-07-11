# log-router-sink

Audit-log routing (FR-3): `google_logging_project_sink` with a unique writer identity,
plus the writer grant on the destination (`roles/bigquery.dataEditor` on the dataset or
`roles/storage.objectCreator` on the bucket). Optional sink-scoped exclusion filters
drop Cloud Logging noise before export.

Retention shortening is the **destination's** responsibility: for BigQuery set
`default_table_expiration_ms` / `default_partition_expiration_ms` on the dataset (see
[bigquery-dataset](../bigquery-dataset/README.md)); for GCS use a bucket lifecycle rule.
BigQuery sinks default to partitioned tables so partition expiration applies.

## Usage

```hcl
module "audit_logs" {
  source = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/log-router-sink?ref=v0.4.0"

  project_id       = "my-project"
  sink_name        = "bq-data-access"
  destination_type = "bigquery"
  destination_id   = module.audit_dataset.dataset_id
  filter           = <<-EOT
    logName="projects/my-project/logs/cloudaudit.googleapis.com%2Fdata_access"
    protoPayload.serviceName="bigquery.googleapis.com"
  EOT

  exclusions = [
    { name = "no-list-jobs", filter = "protoPayload.methodName=\"jobservice.listjobs\"" },
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | Project whose logs are routed (BigQuery destination datasets are assumed to live here) |
| `sink_name` | `string` | — | Sink name |
| `destination_type` | `string` | — | `bigquery` \| `storage` |
| `destination_id` | `string` | — | Dataset id or bucket name |
| `filter` | `string` | `""` | Inclusion filter; empty routes ALL logs — set one |
| `exclusions` | `list(object({name, filter}))` | `[]` | Sink-scoped noise exclusions; names must be unique |
| `bigquery_use_partitioned_tables` | `bool` | `true` | Keep `true` so partition expiration can shorten retention |

## Outputs

| Name | Description |
|------|-------------|
| `sink_id` | Sink resource id |
| `writer_identity` | Service account the sink writes as (write access already granted by this module) |
