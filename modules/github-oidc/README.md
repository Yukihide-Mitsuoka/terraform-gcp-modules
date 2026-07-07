# github-oidc

Keyless GitHub Actions → GCP authentication via Workload Identity Federation. Eliminates
static service-account JSON keys entirely: a Workload Identity Pool + OIDC provider
restricted to one repository, plus a deployer service account the federated identity may
impersonate.

Pairs with the reusable workflows in
[gcp-cicd-workflows](https://github.com/Yukihide-Mitsuoka/gcp-cicd-workflows): this
module's outputs are exactly the `wif_provider` / `service_account` inputs they take.

## Usage

```hcl
module "github_oidc" {
  source            = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/github-oidc?ref=v0.2.0"
  project_id        = var.project_id
  github_repository = "my-org/my-app"

  roles = [
    "roles/run.admin",
    "roles/artifactregistry.writer",
    "roles/iam.serviceAccountUser",
  ]
}
```

GitHub Actions side (via [google-github-actions/auth](https://github.com/google-github-actions/auth)):

```yaml
permissions:
  id-token: write
  contents: read
steps:
  - uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: ${{ vars.WIF_PROVIDER }}   # = output workload_identity_provider
      service_account: ${{ vars.DEPLOYER_SA }}               # = output service_account_email
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | Project hosting the pool and service account |
| `github_repository` | `string` | — | `owner/name` allowed to authenticate |
| `pool_id` | `string` | `github` | Workload Identity Pool id |
| `provider_id` | `string` | `github-oidc` | Pool provider id |
| `service_account_id` | `string` | `github-deployer` | Deployer SA account id |
| `roles` | `list(string)` | `[]` | Project roles for the deployer (least privilege) |
| `attribute_condition` | `string` | repo-restricted | Override to tighten (e.g. main-branch only: `assertion.repository == "o/r" && assertion.ref == "refs/heads/main"`) |

## Outputs

| Name | Description |
|------|-------------|
| `workload_identity_provider` | Full provider name for `google-github-actions/auth` |
| `service_account_email` | Deployer SA email for `google-github-actions/auth` |
| `pool_name` | Full pool resource name |

## Security notes

- The provider's `attribute_condition` rejects tokens from any other repository — a fork
  or another repo in the same org cannot impersonate the deployer.
- Grant `roles` only what the pipeline actually uses; prefer resource-level grants added
  outside this module when possible.
- One instance per repository is the intended shape (separate SAs per repo keep blast
  radius small).
