# bq-inspector-role

Least-privilege read-only custom role for the BigQuery governance inspection path
(FR-6), bound to the inspector service account. Implements the "governance tooling must
not hold excess privilege" principle: no clean predefined read-only role covers all the
read paths (sink config, taxonomy IAM, ...), so a custom role bundles exactly what the
inspection needs.

A validation rejects any write permission (`create` / `update` / `delete` / `set` /
`write` verbs) — the sole exception is `bigquery.jobs.create`, required to run
`INFORMATION_SCHEMA` queries. This module does NOT create the service account; wire in
the inspector SA created alongside the WIF pool.

## Usage

```hcl
module "inspector_role" {
  source             = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/bq-inspector-role?ref=v0.4.0"
  project_id         = "my-project"
  inspector_sa_email = google_service_account.inspector.email
}
```

Default permission set (override `permissions` to tune):

| Purpose | Permissions |
|---------|-------------|
| BQ metadata / schema | `bigquery.datasets.get`, `bigquery.tables.get`, `bigquery.tables.list` |
| INFORMATION_SCHEMA queries | `bigquery.jobs.create` |
| Taxonomy / policy tags | `datacatalog.taxonomies.get`, `datacatalog.taxonomies.list`, `datacatalog.categories.getIamPolicy` |
| Project IAM (read) | `resourcemanager.projects.getIamPolicy` |
| Logging routing config (read) | `logging.sinks.get`, `logging.sinks.list`, `logging.exclusions.list` |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | Project that owns the role and binding |
| `role_id` | `string` | `"bqInspector"` | Custom role id |
| `title` | `string` | `"BigQuery Inspector (read-only)"` | Role title |
| `description` | `string` | (FR-6 description) | Role description |
| `permissions` | `list(string)` | table above | Write permissions rejected except `bigquery.jobs.create` |
| `inspector_sa_email` | `string` | — | Inspector SA the role is bound to |

## Outputs

| Name | Description |
|------|-------------|
| `role_id` | Full custom role resource name (usable directly as an IAM `role`) |
| `inspector_sa_email` | Bound SA email (pass-through) |
