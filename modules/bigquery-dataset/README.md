# bigquery-dataset

BigQuery dataset plus dataset-level least-privilege IAM. Two guardrails are enforced by
input validation: basic roles (`roles/owner|editor|viewer`) and public members
(`allUsers` / `allAuthenticatedUsers`) are rejected at plan time.

> **Location constraint**: if columns in this dataset reference policy tags, the dataset
> `location` MUST equal the taxonomy location (see
> [bigquery-policy-tags](../bigquery-policy-tags/README.md)) — column-level security does
> not apply across locations.

## Usage

```hcl
module "marts" {
  source     = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/bigquery-dataset?ref=v0.3.0"
  project_id = "my-project"
  dataset_id = "marts"
  location   = "asia-northeast1"
  iam_members = [
    { role = "roles/bigquery.dataViewer", member = "group:analysts@example.com" },
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | GCP project that owns the dataset |
| `dataset_id` | `string` | — | Dataset id (letters, digits, underscores) |
| `location` | `string` | — | Dataset location; must match the taxonomy location |
| `description` | `string` | `null` | Human-readable description |
| `default_table_expiration_ms` | `number` | `null` | Table TTL; retention-shortening lever for audit-log sink datasets |
| `default_partition_expiration_ms` | `number` | `null` | Partition TTL |
| `labels` | `map(string)` | `{}` | Dataset labels |
| `iam_members` | `list(object({role, member}))` | `[]` | Dataset-level bindings; basic roles and public members rejected |
| `delete_contents_on_destroy` | `bool` | `false` | Keep `false` (safe side) |

## Outputs

| Name | Description |
|------|-------------|
| `dataset_id` | Dataset id |
| `self_link` | Dataset self link |
| `location` | Dataset location (for the taxonomy-location check) |
