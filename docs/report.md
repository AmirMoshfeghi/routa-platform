# routa-platform — Assignment Report

**Candidate:** Amir Moshfeghi
**Role:** Senior Platform Engineer — Verda
**Repository:** https://github.com/AmirMoshfeghi/routa-platform
**Full decision log:** [`docs/decisions.md`](decisions.md) — every decision below is traceable to a dated, sourced entry there.

---

## 1. What I built

A self-hosted, high-availability Kubernetes platform on four Verda CPU instances in FIN-03, provisioned and configured entirely through code — Terraform for infrastructure, Ansible for OS and cluster configuration, and Argo CD for everything running inside the cluster.

At a glance:

- **4 VMs**: one management node (`routa-mgmt`, `CPU.4V.16G`) and three cluster nodes (`routa-cp-1/2/3`, `CPU.16V.64G`), all Ubuntu 24.04, all in FIN-03.
- **RKE2**, a 3-server HA control plane with embedded etcd — not a single node — with Cilium as CNI.
- **Rancher Manager 2.15.0** on the management node, with the RKE2 cluster imported and managed.
- **Argo CD**, installed once and then self-managing via GitOps, running an app-of-apps pattern with explicit `dev` / `staging` / `prod` promotion.
- **Harbor**, deployed via Argo, with a pushed image that the cluster pulls at runtime — a genuine end-to-end registry loop, not just an install.
- **kube-prometheus-stack** (Prometheus, Alertmanager, Grafana), with persistent storage, monitoring the cluster. Full alerting strategy for production in [`docs/alerting.md`](alerting.md).
- **Security hardening**: non-root SSH access with root login disabled, a default-deny firewall with node-to-node traffic restricted to cluster peer IPs only, and scoped, expiring API credentials.
- **SSO on both Rancher and Argo CD**, via GitHub OAuth — Argo through Dex, Rancher through its native GitHub auth provider. Two separate OAuth Apps, RBAC scoped so authentication alone doesn't imply access (`policy.default: role:readonly` on Argo, explicit admin mapping to my GitHub identity on both).
- **AI-assisted engineering** throughout, using Claude for architecture and review and Claude Code (with Verda's own MCP server) for implementation — documented in [`docs/ai-usage.md`](ai-usage.md), including specific cases where AI output was wrong and how that was caught.

Everything above is reproducible from the repository: `terraform apply` → `ansible-playbook playbooks/site.yml` → `kubectl apply -f gitops/bootstrap/bootstrap.yaml` and one imperative Helm install to seed Argo CD (documented in `decisions.md`).

**Access:**

| Service | URL | Notes |
|---|---|---|
| Rancher | https://rancher.95.133.252.175.sslip.io | Let's Encrypt production cert |
| Argo CD | https://argocd.95.133.252.180.sslip.io | Let's Encrypt production cert |
| Harbor | https://harbor.95.133.252.180.sslip.io | Let's Encrypt production cert, public `routa` project |

Credentials are not included here for obvious reasons; screenshots below show working, authenticated sessions as proof.

---

## 2. Architecture

```
Terraform (verda provider)  →  4 CPU VMs, public IPs, one SSH key
        ↓
Ansible  →  OS hardening, then RKE2 install (Cilium as CNI)
        ↓
routa-mgmt:            k3s + Rancher Manager 2.15.0 + cert-manager + Traefik
routa-cp-1..3:         RKE2 3-server HA control plane (etcd quorum, all schedulable),
                       imported into Rancher
        ↓
Argo CD (self-managing, app-of-apps)
        ↓
   ├── cert-manager + ClusterIssuers (staging + production)
   ├── local-path-provisioner (dynamic storage — RKE2 ships none by default)
   ├── Harbor (registry, TLS via cert-manager)
   ├── kube-prometheus-stack (Prometheus + Alertmanager + Grafana, persistent)
   └── demo-app (pulls its image from Harbor — closes the GitOps loop)

Promotion: environments/dev → staging → prod, same base manifests,
per-environment Kustomize overlays, different git refs. dev/staging
auto-sync; prod requires a manual `argocd app sync` — a deliberate gate,
not an oversight.
```

**Why this shape, briefly** (full reasoning in `decisions.md`):

- **Terraform / Ansible / Argo CD is a deliberate three-way split**, not incidental. Terraform only provisions (VMs, SSH key, IP outputs). Ansible only configures the OS and installs RKE2/Rancher. Everything *inside* the cluster is Argo CD's job. Each tool's surface stays small and single-purpose.
- **3-node HA control plane, not 1+2.** The original scaffold defaulted to a single control-plane node for simplicity. I overrode this: a single node is not fault-tolerant, and the JD explicitly names high-availability environments as a competency. All three RKE2 servers hold etcd and are schedulable, so HA cost nothing extra in VM count.
- **Argo CD manages itself.** Rather than a one-time Helm install left alone, Argo CD's own installation is a Git-tracked Application that Argo reconciles — the strongest demonstration of "GitOps structure" the brief asks for, since even the GitOps controller is declarative.
- **Rancher on a separate node from the workload cluster**, because a cluster manager that lives inside the cluster it manages can't recover it if it goes down.
- **DNS via sslip.io, TLS via cert-manager + Let's Encrypt**, validated on staging first and switched to production once the path was proven — avoiding sslip.io's shared rate-limit quota as a first-attempt risk.

**Screenshots** *(place your renamed files in `docs/screenshots/` and reference here — see mapping below)*:
- `docs/screenshots/rancher-cluster-imported.png` — Rancher showing `routa-rke2` Active
- `docs/screenshots/rancher-github-sso.png` — Rancher login via GitHub SSO
- `docs/screenshots/argocd-app-tree.png` — the full Argo CD application tree, all Synced/Healthy
- `docs/screenshots/argocd-github-sso.png` — Argo CD login via GitHub SSO
- `docs/screenshots/argocd-prod-gate.png` — `routa-prod`'s manifest showing no `automated` sync policy
- `docs/screenshots/grafana-dashboard.png` — a live Grafana dashboard
- `docs/screenshots/harbor-image.png` — the pushed image in Harbor

---

## 3. What worked, and what didn't

The brief weights debugging approach over a clean happy path, so this section is the most important one in the report. Everything below actually happened, in this build, tonight — nothing is hypothetical.

### What worked cleanly

- Provisioning, hardening, and the RKE2 HA install all completed with only minor, quickly-resolved issues.
- The AI-assisted workflow caught real mistakes before they shipped — most notably, an interactive CLI wizard that silently failed on macOS (worked around with explicit flags), and a `terraform apply` that partially failed on a live capacity shortage (recovered idempotently rather than torn down and rebuilt).

### What didn't work, and how it was found and fixed

| Problem | Root cause | How it was caught | Fix |
|---|---|---|---|
| `terraform apply` partially failed mid-run | `CPU.8V.32G` capacity vanished from FIN-03 between planning and applying | Live `503 No capacity available` on 2 of 3 workers | Fell back to `CPU.16V.64G`; re-applied idempotently rather than destroying and rebuilding |
| Terraform's rendered Ansible inventory had a `null` IP | Freshly-created cloud resources have eventually-consistent attributes; a same-run reference to a sibling resource read before the IP settled | `terraform apply` output showed `bootstrap_host.ip is null` | Re-ran `apply`; the second pass refreshed state and resolved cleanly |
| SSH access failed for the `ubuntu` user | Verda's minimal `ubuntu-24.04` image seeds the SSH key to `root`, not a cloud-init `ubuntu` user | Verbose SSH showed the key was offered and rejected, not missing | Bootstrapped as `root`, then had the hardening role create a non-root admin user, verify it could log in and escalate, *then* disable root SSH — gated by an explicit assertion so a broken handover can't lock the node |
| RKE2 workers couldn't start persistent workloads | RKE2 ships no default StorageClass (unlike k3s) — nothing was disabled, it was simply never bundled | A Harbor PVC stuck `Pending`; traced to zero StorageClasses cluster-wide | Deployed `local-path-provisioner` as an Argo-managed Application, explicitly sequenced by sync-wave to land before anything that needs storage |
| Argo's self-managing bootstrap failed at first sync | A `ClusterIssuer` (cert-manager CRD) was bundled in the same Kustomize build as cert-manager's own install — the CRD didn't exist yet when the build tried to validate the CR | `kubectl kustomize` passed locally (no cluster validation) but Argo's repo-server, which does validate, failed | Split the ClusterIssuer into its own directory-type Application with `SkipDryRunOnMissingResource=true`, decoupling its sync cycle |
| kube-prometheus-stack's CRDs failed to apply | The Prometheus Operator CRDs exceed Kubernetes' 262144-byte annotation limit under client-side apply | Sync error naming the exact CRDs and the byte limit | Added `ServerSideApply=true`, which doesn't use the offending annotation |
| Rancher's TLS silently stayed on the staging (untrusted) cert after switching to production | cert-manager won't re-issue a certificate while a valid one already exists in the secret — an Issuer's ACME environment changing isn't itself a renewal trigger | Browser and phone both flagged the cert as untrusted; `openssl s_client` confirmed the issuer was still Let's Encrypt *staging* | Deleted the TLS secret to force a fresh request against the now-production Issuer |
| The Prometheus Operator stopped reconciling | CRDs were applied in two batches an hour apart; the operator's admission webhook TLS appears to have gone stale in between | The CR showed `DESIRED 1` but blank `READY`/`RECONCILED`, and `Events: <none>` — the operator had never attempted reconciliation, not failed at it | Restarted the operator deployment; it re-established its watches and created the missing StatefulSets |
| A pushed image failed to pull on the cluster | Built on Apple Silicon (arm64); RKE2 nodes are amd64 | `ImagePullBackOff` — `no match for platform in manifest` | Rebuilt with `docker build --platform linux/amd64` |

The thread running through all of these: **local success does not imply cluster success.** `kubectl kustomize`, `terraform fmt`, and `--syntax-check` all passed on configs that failed once they hit a live API server, a live registry limit, or a live architecture mismatch. The fix, applied consistently after the first time this bit me, was to verify by rendering against the real target — Argo's repo-server, the pinned Helm chart, or the live cluster — rather than trusting a local, unvalidated pass.

---

## 4. Security and operational considerations

- **No standing root access.** Verda's base image only permits root SSH. The hardening role creates a dedicated admin user, installs its key, grants passwordless sudo, and *proves* that login and escalation work — before disabling root login. If the handover can't be verified, the role stops with root access still intact rather than risking a locked-out node.
- **Default-deny firewall, with node-to-node traffic scoped to real peer IPs.** These Verda CPU instances have no private network — every node talks to every other node over its public IP. That means source-restricting inter-node ports (etcd, the RKE2 supervisor API, the Cilium VXLAN tunnel) to the cluster's own IPs is the *only* thing keeping etcd off the open internet, not a defense-in-depth nicety.
- **Scoped, expiring credentials.** The Verda Cloud API credentials are 30-day-scoped rather than permanent, given the assignment has a known end date. SSH keys are generated fresh for this assignment, not reused from elsewhere.
- **No secrets in the repository, anywhere, ever.** Verda credentials live in a local env file outside the repo; kubeconfigs, Terraform state, and `.tfvars` are all gitignored from the first commit. The Terraform provider authenticates via environment variables, so the provider block itself is empty.
- **A public GitHub repo was a deliberate trade-off.** Argo CD needs to pull manifests over HTTPS, and a private repo would require a deploy key stored as a cluster Secret — more credential surface for a small benefit. Going public means the repo's real node IPs are visible, but the nodes are hardened (no root SSH, default-deny firewall) and the environment is short-lived.
- **All API endpoints are on real, browser-trusted TLS** — not self-signed — via cert-manager and Let's Encrypt. Certificates were validated against Let's Encrypt's staging environment first specifically to avoid burning a shared rate-limit quota that sslip.io users all share, before switching to production.
- **Rancher's own etcd-holding downstream cluster is not exposed via a load balancer** — API access currently goes through a single node's public IP (`routa-cp-1`). etcd itself is genuinely HA across all three nodes; API *access* is not yet, and that's an open item below.

---

## 5. What I'd improve with more time

- **API-endpoint HA.** etcd tolerates a node failure; the kubeconfig and Rancher's import both currently point at one node's IP for API access. A real load balancer or DNS record in front of all three servers would remove that single point of failure. Deferred here because standing up an LB just to relocate the same single point of failure onto another node isn't a real fix — the three server IPs are already in the TLS SAN list, so adding a proper endpoint later is a config change, not a rebuild.
- **Harbor's `sourceRepos: ["*"]`.** The AppProject currently trusts any Git source; tightening it to the exact list this platform actually uses (this repo, the Argo Helm chart repo, the cert-manager OCI registry, Harbor's chart repo, kube-prometheus-stack's chart repo) is a small change I'd make before calling this production-ready.
- **GPU support.** The brief directs CPU provisioning, and I kept it that way rather than spending credits chasing GPU capacity. If this were extended: the NVIDIA GPU Operator for driver/device-plugin management, `nvidia.com/gpu` resource requests and node taints for scheduling, and a DCGM exporter feeding both Grafana and the alerting tiers described in the monitoring section — idle GPU time is the most expensive thing a platform like this can waste, so I'd treat GPU utilization as a cost signal, not just a capacity one.
- **A prioritized fallback instance type list, not a single hardcoded SKU.** The mid-build capacity failure showed that on-demand inventory on this platform is genuinely volatile — an instance type validated minutes before `apply` can vanish during it. Terraform has no native "first available from this list" primitive; a small wrapper or a documented manual fallback procedure would make rebuilds more resilient to this.
- **KWOK and Kueue**, from the bonus list — not attempted, given the time spent on hardening the core build properly rather than adding breadth. Both would be natural additions to demonstrate cluster-scale thinking and job-priority scheduling respectively.

---

*Full, dated reasoning for every decision above — including the ones this report only summarizes — is in [`docs/decisions.md`](decisions.md). AI-tooling usage, including cases where AI output was wrong and how it was verified, is in [`docs/ai-usage.md`](ai-usage.md).*
