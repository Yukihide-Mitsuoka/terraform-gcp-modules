# terraform-gcp-modules

Personal library of reusable GCP Terraform modules. **Referenced, never copied**: consumers
pin a released tag via a git source — they do not vendor this code.

```hcl
module "network" {
  source     = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/network?ref=v0.5.0"
  project_id = var.project_id
  name       = "core"
  subnets = [
    { name = "app", cidr = "10.0.0.0/24", region = "asia-northeast1" },
  ]
}
```

## Consumption contract

| Rule | Detail |
|------|--------|
| Pin a tag, never a branch | `?ref=vX.Y.Z` only. `?ref=main` breaks reproducibility |
| Versioning | SemVer tags on this repo. MAJOR = breaking variable/output change |
| Upgrades are consumer-driven | Fixing a module here does NOT touch consumers; they bump `?ref` when they choose |
| One module = one directory | `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md` |

This split is deliberate: project scaffolding (rules, CI, layout) is distributed by the
[terraform-gcp-template](https://github.com/Yukihide-Mitsuoka/terraform-gcp-template)
template repo (copy-and-own), while infrastructure building blocks live here
(reference-and-pin). Do not add project scaffolding to this repo.

## Layout

```
modules/
  network/               VPC + subnets (example module; the conventions reference)
  github-oidc/           Keyless GitHub Actions -> GCP auth (Workload Identity Federation)
  bigquery-dataset/      BigQuery dataset + dataset-level least-privilege IAM
  bigquery-policy-tags/  Sensitivity taxonomy + policy tags (column-level security)
  bigquery-data-policy/  Column masking bound to a policy tag (+ maskedReader grants)
  log-router-sink/       Audit-log routing sink + destination writer grant
  bq-inspector-role/     Read-only custom role for the BQ inspection path
```

## Module conventions

- Inputs validated in `variables.tf` (types + `validation` blocks where cheap).
- No provider blocks inside modules — consumers own providers; modules declare
  `required_providers` constraints only (`versions.tf`).
- Outputs expose IDs/names consumers need to wire modules together, nothing speculative.
- Each module README documents inputs, outputs, and a minimal usage example.

## CI

`validate.yml` runs `terraform fmt -check` repo-wide and `terraform init -backend=false &&
terraform validate` per module on every push/PR.

## Releasing

1. Merge changes to `main` (PR + green CI).
2. Tag: `git tag v0.2.0 && git push origin v0.2.0`.
3. Consumers bump `?ref=` when ready.

## License

MIT — see [LICENSE](LICENSE).
