# terraform-aws-modules

A small AWS lab in Terraform: remote state with locking, then a reusable VPC module. Built to learn AWS by mapping it to Azure patterns I already work with.

**Status:** learning lab, Phase 1 complete. Not production.

## Scope (Phase 1)
1. `bootstrap/`: S3 bucket for Terraform state (versioned, encrypted, public access blocked, native locking).
2. `modules/vpc/`: reusable VPC module (VPC, public and private subnets, route tables, internet gateway, S3 gateway endpoint). No NAT gateway or interface endpoints (hourly cost).
3. `modules/vpc/examples/basic/`: example that calls the module and uses the remote state backend.

## Usage
Requires Terraform 1.10 or later and credentials for an AWS lab account.
1. `cd bootstrap`, then `terraform init` and `terraform apply` (local state). Note the `state_bucket_name` output.
2. `cd modules/vpc/examples/basic`, then `terraform init -backend-config="bucket=<state_bucket_name>"` and `terraform apply`.
3. Run `terraform destroy` in the example when finished. Destroy `bootstrap` last, once nothing else uses the state bucket (set `force_destroy = true` first if it still holds state).

## Azure to AWS map (kept up to date as I learn)
| Azure | AWS |
|---|---|
| Storage account + blob container (state) | S3 bucket |
| Blob lease (state lock) | S3 native lockfile (`use_lockfile`) |
| Resource group | No direct equivalent; tags and accounts organize resources |
| VNet / subnet | VPC / subnet |
| Management group / subscription | Organizations OU / account |
| Azure Policy | SCPs and AWS Config |
| Managed identity | IAM role |

## How this was built
I chose the scope and structure, ran every plan and apply myself, and reviewed the results. I used Claude Code (an AI coding assistant) to help write the Terraform and documentation, and to explain AWS concepts as I learned them. Commits carry a `Co-Authored-By` trailer. This is a learning lab, not a production system.

## What this is not
Not production. One account, one region (us-east-2), no hub-and-spoke, no multi-account governance. The account is on the AWS free plan, which blocks IAM Identity Center, so the lab uses an IAM user with a temporary CLI access key. In a real organization I would use Identity Center permission sets and short-lived credentials.

## Known limitations and production hardening
Reviewed and deliberately left out of this lab. Each would be worth adding for a real environment:

| Gap | What I would add |
|---|---|
| The S3 gateway endpoint uses the default (allow-all) policy | An endpoint policy limiting access to approved buckets or accounts, exposed as an optional variable. An account-only policy also blocks AWS-owned buckets such as package repositories, so it must be opt-in |
| No VPC Flow Logs | Flow logs to CloudWatch Logs or S3, with retention. Costs money and needs an IAM role |
| No access logging on the state bucket | CloudTrail data events or S3 access logs, delivered to a separate logging account |
| State bucket uses AWS-managed encryption keys | A customer-managed KMS key, so key use is logged in CloudTrail |
| State bucket protections are basic (versioning, public access block, TLS-only) | A separate account for state, an SCP protecting the bucket, and possibly Object Lock after testing it with Terraform's lockfile |
| No NAT gateway or interface endpoints | Added per workload, because both are billed by the hour |
| No CI, tests or linting yet | Pre-commit, tflint, trivy, `terraform test` and a release process, as in my terraform-azure-modules repo |

## Safety
No credentials, account IDs or state files are committed. See `.gitignore`.

## License
[MIT](LICENSE) © 2026 Jennifer Salvo
