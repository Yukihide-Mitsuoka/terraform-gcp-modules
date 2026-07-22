# network

Custom-mode VPC plus subnets. Serves as the conventions reference for every module in
this library (no provider block, validated inputs, minimal outputs).

## Usage

```hcl
module "network" {
  source     = "git::https://github.com/Yukihide-Mitsuoka/terraform-gcp-modules.git//modules/network?ref=v0.5.0"
  project_id = "my-project"
  name       = "core"
  subnets = [
    { name = "app", cidr = "10.0.0.0/24", region = "asia-northeast1" },
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | — | GCP project that owns the network |
| `name` | `string` | — | VPC name; also prefixes subnet names (`<name>-<subnet>`) |
| `subnets` | `list(object({name, cidr, region}))` | `[]` | Subnets to create |

## Security defaults

Every managed subnet enables VPC Flow Logs with a five-second aggregation interval,
50% sampling, and all metadata. This provides traffic evidence for investigation and
monitoring, while adding Cloud Logging ingestion and retention cost. These values are
fixed in this release; introduce configuration only when a concrete consumer requires a
different volume or metadata trade-off.

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | Fully-qualified VPC id |
| `network_name` | VPC name |
| `subnet_ids` | Map: subnet name → fully-qualified subnet id |
