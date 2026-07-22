# ADR-0001: Enable VPC Flow Logs for every managed subnet

| Field | Value |
|-------|-------|
| Status | proposed |
| Date | 2026-07-22 |
| Deciders | repository owner |
| Author | Codex (AI agent) |
| Supersedes / Superseded by | — |

## Context

The `network` module creates `google_compute_subnetwork` resources without a
`log_config` block. VPC Flow Logs are therefore disabled on every subnet created by the
module. Trivy reports this as `GCP-0076` (MEDIUM), and the inherited starter in
`secure-ai-controls` cannot pass its required `iac-scan` while pinned to module release
`v0.1.0`.

Flow records provide evidence for traffic analysis, incident investigation, and network
security monitoring. Enabling them also sends additional data to Cloud Logging and can
increase logging and retention cost. The module supports Google provider versions 5, 6,
and 7, where a `google_compute_subnetwork.log_config` block enables the feature.

Constraints:

- Existing callers using the current `subnets` input must receive a secure default
  without changing their configuration.
- The fix must not suppress or lower the severity of the scanner finding.
- The module API should remain small until a demonstrated consumer needs tuning.
- Generated log volume and metadata must be predictable and documented.

## Options considered

### Option 1: Do nothing or suppress `GCP-0076`

- **Pros:** no resource update and no additional logging cost.
- **Cons:** keeps a real observability gap, makes downstream security CI fail, and lowers
  the security posture if the finding is suppressed. Rejected.

### Option 2: Always enable Flow Logs with explicit provider defaults (chosen)

Add a `log_config` block to every managed subnet with:

- aggregation interval: `INTERVAL_5_SEC`;
- flow sampling: `0.5`;
- metadata: `INCLUDE_ALL_METADATA`.

- **Pros:** secure by default for new and existing callers; no input migration; smallest
  implementation; explicit values prevent provider-default drift; resolves `GCP-0076`.
- **Cons:** all callers incur additional Cloud Logging volume and cost; settings cannot
  be tuned per subnet without a later API addition.

### Option 3: Add configurable module or per-subnet log settings

- **Pros:** consumers can balance visibility, volume, and cost.
- **Cons:** expands the public input contract before a second configuration is required;
  adds validation and migration complexity; an opt-out could recreate the insecure
  default. Deferred until a concrete consumer requires different settings.

### Option 4: Create Network Management VPC Flow Logs configurations

Google Cloud recommends the Network Management API for new centralized Flow Logs
configuration. Adopting it here would introduce a new API/resource and move ownership
outside the subnet resource.

- **Pros:** current Google-recommended control plane and broader future targeting.
- **Cons:** larger module-boundary change, additional API enablement and IAM, and more
  migration risk than needed to secure the current subnet module. Deferred to a separate
  ADR if centralized configuration becomes a requirement.

## Decision

Choose Option 2. Every `google_compute_subnetwork.this` instance MUST contain an explicit
Flow Logs configuration using `INTERVAL_5_SEC`, `0.5` sampling, and all metadata.

Add a CI security test using Trivy so removal or weakening of Flow Logs fails before a
release. Release the backward-compatible behavior change as `v0.5.0`; consumers remain
pinned until they deliberately upgrade.

## Consequences

### Positive

- Subnets created by the module have traffic telemetry available by default.
- `GCP-0076` is fixed at the owning module instead of suppressed downstream.
- Existing module input and output shapes remain unchanged.
- A scanner-backed regression test protects the security property.

### Negative

- Upgrading callers can generate additional Cloud Logging ingestion and retention cost.
- Including all metadata broadens the diagnostic context stored with flow records.
- The fixed settings cannot yet be tuned for unusually high-volume networks.

## Migration and rollback

Implementation is incremental: first add the scanner regression test, then add
`log_config`, update module documentation, and release `v0.5.0`. Consumers opt in by
bumping their pinned tag.

Rollback is a normal module release that removes the block, but doing so reintroduces
`GCP-0076` and requires a new reviewed security decision with a compensating control.

## References

- [Google Cloud: Configure VPC Flow Logs](https://cloud.google.com/vpc/docs/using-flow-logs)
- [Google provider: `google_compute_subnetwork`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
- [Trivy GCP-0076](https://avd.aquasec.com/misconfig/gcp-0076)
