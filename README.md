# terraform-aws-modules

A small, honest AWS lab in Terraform: remote state with locking, then a reusable VPC module. Built to learn AWS by mapping it to Azure patterns I already work with.

**Status:** work in progress. Private until reviewed.

## Scope (Phase 1)
1. `bootstrap/`: S3 bucket for Terraform state (versioned, encrypted, public access blocked, native locking).
2. `modules/vpc/`: reusable VPC module (VPC, public and private subnets, route tables, internet gateway, S3 gateway endpoint). No NAT gateway or interface endpoints (hourly cost).
3. `modules/vpc/examples/basic/`: example that calls the module and uses the remote state backend.

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

## What this is not
Not production. One account, one region (us-east-2), no hub-and-spoke, no multi-account governance. Built with AI assistance (Claude Code) and reviewed by me.

## Safety
No credentials, account IDs or state files are committed. See `.gitignore`.
