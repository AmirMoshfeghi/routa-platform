# routa-platform

Verda Senior Platform Engineer take-home assignment: a self-hosted Kubernetes
platform built on Verda Cloud CPU instances.

**Status: scaffold only.** Nothing has been provisioned. See `docs/decisions.md` for
the full reasoning, decision log, and current state — it is the primary artifact of
this assignment, not this README.

## Architecture

```
Terraform (verda provider)  →  4 CPU VMs, public IPs, one SSH key
        ↓
Ansible  →  OS hardening, then RKE2 install (Cilium as CNI)
        ↓
routa-mgmt:            k3s + Rancher Manager + cert-manager
routa-cp-1..3:         RKE2 3-server HA control plane (etcd quorum, schedulable),
                       imported into Rancher
        ↓
Argo CD (app-of-apps)  →  kube-prometheus-stack, Harbor, demo app
                           promoted dev → staging → prod via git ref + manual gate
```

## Repository layout

| Path | Tool | Scope |
|---|---|---|
| `terraform/` | Terraform | Provisioning: 4 VMs, SSH key, IP outputs → Ansible inventory |
| `ansible/` | Ansible | OS hardening, RKE2 install, kubeconfig retrieval |
| `gitops/` | Argo CD | Everything inside the cluster |
| `docs/` | — | Decision log and (eventually) the assignment report |

See `CLAUDE.md` for detailed conventions and the standing rules this repo is built
under (version pinning, docs-before-syntax, Verda MCP usage).

## Prerequisites

```bash
brew install ansible kubectl helm git
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
curl -sSL https://raw.githubusercontent.com/verda-cloud/verda-cli/main/scripts/install.sh | sh
```

Verda credentials sourced from `~/.config/verda/env` (not committed — see
`docs/decisions.md` Section 3 Step 5 for why and how):

```bash
source ~/.config/verda/env
verda doctor   # should be all green before doing anything else
```

## Usage (not yet run)

```bash
# 1. Provision
cd terraform
cp terraform.tfvars.example terraform.tfvars   # image defaults to ubuntu-24.04
terraform init
terraform plan
terraform apply   # writes ansible/inventory/hosts.ini on success

# 2. Configure
cd ../ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml

# 3. Deliver
kubectl apply -k gitops/bootstrap   # bootstraps Argo CD's app-of-apps
```
