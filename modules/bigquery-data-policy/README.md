# bigquery-data-policy

Column-level data masking (or access restriction) bound to a policy tag:
`google_bigquery_datapolicy_data_policy` plus optional
`roles/bigquerydatapolicy.maskedReader` grants. Masked readers see tagged columns in
masked form (e.g. `SHA256`) instead of being denied; members without either
fine-grained-reader or masked-reader access are denied outright.

> **Location constraint**: `location` MUST equal the location segment of `policy_tag`
> (enforced by a plan-time precondition) — which in turn must match the dataset location
> (see [bigquery-policy-tags](../bigquery-policy-tags/README.md)).

## Usage

```hcl
module "mask_high" {
  source         = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/bigquery-data-policy?ref=v0.4.0"
  project_id     = "my-project"
  location       = "asia-northeast1"
  data_policy_id = "mask_high_sha256"
  policy_tag     = module.sensitivity.policy_tag_ids.high

  predefined_expression = "SHA256"
  masked_readers = [
    "group:analysts@example.com",
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | GCP project that owns the data policy |
| `location` | `string` | — | Must equal the policy tag's location |
| `data_policy_id` | `string` | — | Policy id (letters, digits, underscores) |
| `policy_tag` | `string` | — | Full policy-tag resource name (from `bigquery-policy-tags`) |
| `data_policy_type` | `string` | `"DATA_MASKING_POLICY"` | Or `COLUMN_LEVEL_SECURITY_POLICY` |
| `predefined_expression` | `string` | `null` | Masking routine (`SHA256`, `EMAIL_MASK`, `DEFAULT_MASKING_VALUE`, ...); required for masking policies |
| `masked_readers` | `list(string)` | `[]` | Members reading tagged columns in masked form; public members rejected |

## Outputs

| Name | Description |
|------|-------------|
| `data_policy_id` | Data policy id |
