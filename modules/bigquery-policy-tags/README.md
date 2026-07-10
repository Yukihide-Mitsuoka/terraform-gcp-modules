# bigquery-policy-tags

Sensitivity taxonomy plus one policy tag per level (column-level security). Defaults
implement a 3-tier catalog (`high` / `medium` / `low`); override `levels` per engagement.
Optionally grants `roles/datacatalog.categoryFineGrainedReader` per level.

> **Location constraint**: the taxonomy `location` MUST equal the location of every
> dataset whose columns reference these tags (see
> [bigquery-dataset](../bigquery-dataset/README.md)) — column-level security does not
> apply across locations.

## Usage

```hcl
module "sensitivity" {
  source                = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/bigquery-policy-tags?ref=v0.3.0"
  project_id            = "my-project"
  location              = "asia-northeast1"
  taxonomy_display_name = "ga4-sensitivity"
  fine_grained_readers = {
    high = ["group:privacy-office@example.com"]
  }
}
```

Wire `policy_tag_ids` into the transformation tool's column config — the tag is applied
by dbt/Dataform, not by Terraform:

```yaml
# dbt schema.yml
columns:
  - name: user_id
    policy_tags: ["${module.sensitivity.policy_tag_ids.high}"]   # via var/env indirection
```

```js
// Dataform SQLX config
columns: { user_id: { bigqueryPolicyTags: [policyTagIds.high] } }
```

The executing service account needs `datacatalog.taxonomies.get` +
`bigquery.tables.setCategory` to attach tags from dbt/Dataform.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | GCP project that owns the taxonomy |
| `location` | `string` | — | Taxonomy region; must match dataset locations |
| `taxonomy_display_name` | `string` | — | Unique per project + location |
| `activated_policy_types` | `list(string)` | `["FINE_GRAINED_ACCESS_CONTROL"]` | Policy types |
| `levels` | `list(object({name, description}))` | 3-tier high/medium/low | Sensitivity levels; names must be unique |
| `fine_grained_readers` | `map(list(string))` | `{}` | Level name → members allowed to read tagged columns; public members rejected |

## Outputs

| Name | Description |
|------|-------------|
| `taxonomy_id` | Full taxonomy resource name |
| `policy_tag_ids` | Map: level name → full policy-tag resource name (what dbt/Dataform configs reference) |
