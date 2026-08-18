# routa-platform

Verda Senior Platform Engineer take-home assignment: a self-hosted Kubernetes
platform built on Verda Cloud CPU instances.

**The platform is deployed and live.** `docs/report.md` is the assignment
deliverable — what was built, why, and what worked and didn't. `docs/decisions.md`
is the full build log — every non-obvious decision, in order, as it was made. This
README is orientation only; it doesn't try to compete with either.

## Live

**As of 2026-08-18 — kept up for review, then torn down.** The table below is a
point-in-time snapshot, not a permanent endpoint: the instances will be shut down
once review is done (see "Tearing this down" below for what that means for this
section). Screenshots in `docs/screenshots/` and the report are the durable evidence
that this worked; these URLs are not.

| Service | URL | Auth |
|---|---|---|
| Rancher | https://rancher.95.133.252.175.sslip.io | GitHub OAuth (native provider) |
| Argo CD | https://argocd.95.133.252.180.sslip.io | GitHub OAuth (Dex) |
| Harbor | https://harbor.95.133.252.180.sslip.io | Local admin (public `routa` project — anonymous pulls) |

All three on Let's Encrypt production certificates via cert-manager, not self-signed.

### Tearing this down

When the instances come down, this section will go stale (dead links, or a different
IP if rebuilt later) unless it's updated at the same time — recommended sequence:

1. Replace the table above with a one-line status: *"Torn down as of `<date>`. Was
   live `2026-08-18` – `<date>` for review. Screenshots in `docs/screenshots/` and
   `docs/report.md` are the durable record; the Bootstrap procedure below reproduces
   this from scratch."*
2. Leave the "What's running" and "Architecture" sections untouched — they describe
   what the repo builds, not a live endpoint, so they don't go stale on teardown.
3. Don't delete the IPs from `docs/decisions.md` — that log is dated, point-in-time
   narrative by design (same reasoning as Section 4.4's sizing table: a record of
   what was true when it was written, not a live status page). Only this README
   table needs updating; the decision log doesn't.

## What's running

- **Rancher**, managing the 3-server RKE2 HA control plane it imported.
- **Argo CD**, self-managing (it deploys and reconciles its own installation via
  Git) as an app-of-apps, with dev → staging → prod promotion via git ref. Only dev
  auto-syncs; staging and prod both require a manual sync gate (see `decisions.md`
  for why staging's was added after dev/staging/prod turned out to share child
  Application names).
- **Harbor**, serving a real image (`demo-app`) that's been pushed and pulled
  through it — the GitOps loop closes through infrastructure this platform built
  itself, not an external registry.
- **kube-prometheus-stack**, with persistent storage (not ephemeral `emptyDir`) on
  the cluster's own default `local-path` StorageClass. Production alerting design in
  [`docs/alerting.md`](docs/alerting.md).
- **Kueue** (bonus), for job queueing and quota management — a `ClusterQueue` with a
  tight CPU quota and a demo (`gitops/platform/kueue-demo/`) that proves real FIFO
  admission: two `Job`s together exceed the quota, so the second visibly waits on the
  first.
- **GitHub SSO** on both Rancher and Argo CD.

## Architecture

```
Terraform (verda provider)  →  4 CPU VMs, public IPs, one SSH key
        ↓
Ansible  →  OS hardening, then RKE2 install (Cilium as CNI)
        ↓
routa-mgmt:            k3s + Rancher Manager + cert-manager, GitHub SSO
routa-cp-1..3:         RKE2 3-server HA control plane (etcd quorum, schedulable),
                       imported into Rancher, GitHub SSO
        ↓
Argo CD (self-managing, app-of-apps)
  gitops/bootstrap/    Argo CD itself, cert-manager, Let's Encrypt ClusterIssuers,
                       local-path-provisioner, Kueue (bonus) — cluster-wide
                       singletons, synced once per cluster rather than once per
                       environment
  gitops/platform/     kube-prometheus-stack, Harbor, demo app, Kueue demo
                       promoted dev → staging → prod via git ref; dev auto-syncs,
                       staging and prod both require a manual sync gate
```

## Repository layout

| Path | Tool | Scope |
|---|---|---|
| `terraform/` | Terraform | Provisioning: 4 VMs, SSH key, IP outputs → Ansible inventory |
| `ansible/` | Ansible | OS hardening; RKE2 install; k3s + Rancher + cert-manager on the mgmt node; kubeconfig retrieval |
| `gitops/` | Argo CD | Everything inside the cluster |
| `docs/` | — | `report.md` (the assignment deliverable), `decisions.md` (the full build log), `ai-usage.md` (AI-assisted engineering record), `alerting.md` (production alerting design) |

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

## Bootstrap procedure (for a rebuild — this has already been run once)

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
ansible-playbook playbooks/site.yml   # hardening, RKE2, k3s+Rancher+cert-manager on mgmt

# 3. Deliver — Argo CD has to exist before it can manage itself, so this is a
#    one-time imperative seed followed by a declarative handoff, not a single
#    `kubectl apply` (see docs/decisions.md Section 20.5 for why):
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm && helm repo update argo
helm install argocd argo/argo-cd \
  --version 10.4.0 --namespace argocd \
  -f gitops/bootstrap/argocd-values.yaml
kubectl apply -f gitops/bootstrap/bootstrap.yaml   # Argo CD adopts itself from here
```
