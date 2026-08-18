# Verda Senior Platform Engineer Assignment — Day 0 Decision Log

> **Note:** Sections 1–9 are the original Day-0 planning log (2026-08-09), preserved
> as written; current state is in `docs/report.md`. Section 10 onward covers the build.

## Table of contents

<details><summary>140 sections/subsections — click to expand</summary>

- [1. Assignment analysis](#sec-1)
  - [1.1 The brief](#sec-1-1)
  - [1.2 Mapping the assignment to the job description](#sec-1-2)
  - [1.3 The most important sentence in the brief](#sec-1-3)
  - [1.4 GPU: deferred, not decided — revisit once time budget is known](#sec-1-4)
- [2. Target architecture (planned, not yet built)](#sec-2)
  - [2.1 Rationale per component](#sec-2-1)
- [3. Steps completed today, in order, with reasoning](#sec-3)
  - [Step 1 — Analysed assignment and job ad; mapped rubric](#sec-3-1)
  - [Step 3 — Resolved a misreading: signup does not start a timed session](#sec-3-3)
  - [Step 4 — Account, project, and credential setup](#sec-3-4)
  - [Step 5 — Corrected credential storage](#sec-3-5)
  - [Step 6 — Verda CLI auth-login bug, and the `routa` naming convention](#sec-3-6)
- [4. Discovery results — region, sizing and cost model (locked)](#sec-4)
  - [4.1 Regional capacity varies — FIN-03 is the only viable region](#sec-4-1)
  - [4.2 Instance pricing (CPU)](#sec-4-2)
  - [4.3 Storage is billed independently — and it is not a rounding error](#sec-4-3)
  - [4.4 Locked configuration](#sec-4-4)
  - [4.5 Shutdown policy](#sec-4-5)
  - [4.6 Spot pricing — considered and rejected](#sec-4-6)
- [5. Documentation consulted](#sec-5)
  - [5.1 Key facts extracted](#sec-5-1)
- [6. AI-assisted engineering angle](#sec-6)
- [7. Open items](#sec-7)
  - [7.1 Open question — project scoping for API credentials](#sec-7-1)
- [9. Standing constraints](#sec-9)
- [10. Repository scaffolded (2026-08-17)](#sec-10)
- [11. Topology change: RKE2 control plane goes from 1 server + 2 agents to a 3-server HA quorum (2026-08-17)](#sec-11)
- [12. API endpoint, TLS SANs, and a latent `group_vars` bug (2026-08-17)](#sec-12)
  - [12.1 The reported issue, corrected](#sec-12-1)
  - [12.2 API endpoint decision (and what is deliberately deferred)](#sec-12-2)
  - [12.3 The bug found while verifying: `group_vars/` was never being loaded](#sec-12-3)
- [13. CPU image identifier resolved (2026-08-17)](#sec-13)
- [14. Capacity constraint hit mid-apply: worker type falls back to CPU.16V.64G (2026-08-17)](#sec-14)
- [15. SSH identity: Verda's minimal image seeds root, not `ubuntu` — and the root→admin handover (2026-08-17)](#sec-15)
- [16. Firewall port set: Cilium/RKE2 ports resolved, and split public vs node-to-node (2026-08-17)](#sec-16)
  - [16.1 The defects](#sec-16-1)
  - [16.2 Port set, with provenance](#sec-16-2)
  - [16.3 Public vs node-to-node — the substantive design change](#sec-16-3)
  - [16.4 One addition beyond the reported defects](#sec-16-4)
  - [16.5 Verification](#sec-16-5)
- [17. Rancher Manager on routa-mgmt: the chart's `kubeVersion` cap drives every other version (2026-08-17)](#sec-17)
  - [17.1 The constraint that decided it](#sec-17-1)
  - [17.2 k3s pinned to 1.35, not 1.36 — the non-obvious call](#sec-17-2)
  - [17.3 Ingress: ingress-nginx is retired, so Traefik](#sec-17-3)
  - [17.4 cert-manager — and ignoring Rancher's own docs on it](#sec-17-4)
  - [17.5 Let's Encrypt over sslip.io is a known trap](#sec-17-5)
  - [17.6 Structure: Ansible, not gitops/](#sec-17-6)
  - [17.7 Verification so far (rule 4 — render, don't syntax-check)](#sec-17-7)
  - [17.8 Deferred, deliberately](#sec-17-8)
- [18. Rancher TLS: the production cert flip that silently didn't happen (2026-08-17)](#sec-18)
- [19. RKE2 cluster import: `agentTLSMode: strict` vs a public Let's Encrypt cert (2026-08-17)](#sec-19)
- [20. Argo CD: self-managing bootstrap plan (2026-08-17)](#sec-20)
  - [20.1 Versions pinned](#sec-20-1)
  - [20.2 RKE2 already has an ingress controller — and it is Traefik](#sec-20-2)
  - [20.3 The structural call: singletons go in `bootstrap/`, not `platform/`](#sec-20-3)
  - [20.4 Self-management: `ServerSideApply=true` is mandatory](#sec-20-4)
  - [20.5 Bootstrap sequence](#sec-20-5)
  - [20.6 UI exposure, consistent with Rancher](#sec-20-6)
  - [20.7 Blocking: the repo has no Git remote](#sec-20-7)
  - [20.8 Deferred](#sec-20-8)
- [21. Argo CD bootstrap manifests written (2026-08-17)](#sec-21)
  - [21.1 Files](#sec-21-1)
  - [21.2 The bug the plan didn't catch: `bootstrap` referencing its own not-yet-created project](#sec-21-2)
  - [21.3 Sync-wave sequencing, and why it's needed at all](#sec-21-3)
  - [21.4 Two things reused from earlier incidents rather than re-derived](#sec-21-4)
  - [21.5 Scope held, gaps flagged rather than silently closed](#sec-21-5)
  - [21.6 Verification (rule 4 — rendered, not eyeballed)](#sec-21-6)
- [22. Placeholders resolved: repo is push-ready (2026-08-17)](#sec-22)
  - [22.1 What was filled in](#sec-22-1)
  - [22.2 One instruction that didn't cleanly apply: Harbor's `externalURL`](#sec-22-2)
  - [22.3 TODO before this is production: `project.yaml` sourceRepos is still `"*"`](#sec-22-3)
  - [22.4 Verification (rule 4 — rendered, all four affected roots, not just one)](#sec-22-4)
- [23. Bootstrap sync failure: ClusterIssuer bundled in the same Application as cert-manager (2026-08-17)](#sec-23)
  - [23.1 Why sync-waves didn't save this, and why that's not a sync-wave bug](#sec-23-1)
  - [23.2 The fix: a separate Application, not a suppressed check](#sec-23-2)
  - [23.3 `SkipDryRunOnMissingResource=true` — required, and why it's safe to leave on](#sec-23-3)
  - [23.4 Verification (rendered, both the split-out piece and everything around it)](#sec-23-4)
- [24. kube-prometheus-stack hit the same CRD-size failure as cert-manager (2026-08-17)](#sec-24)
- [25. Root cause found: RKE2 never bundled a default StorageClass — this was never disabled (2026-08-17)](#sec-25)
  - [25.1 What was actually checked, and what it shows](#sec-25-1)
  - [25.2 The fix — and why "enable it via RKE2 config" was never actually an option](#sec-25-2)
  - [25.3 Vendoring discipline: patch what's addressable, edit what isn't, and say which is which](#sec-25-3)
  - [25.4 Verification (rendered, every level: the sub-kustomization, the wrapping app, and every root)](#sec-25-4)
  - [25.5 Flagged, not decided: Prometheus on `emptyDir`](#sec-25-5)
- [26. Storage fix, split by risk: Argo for the live cluster, documentation for Ansible (2026-08-17)](#sec-26)
  - [26.1 Re-stated plainly: there is nothing to update in RKE2's `disable` list](#sec-26-1)
  - [26.2 A real mechanism exists — checked, and deliberately not used](#sec-26-2)
  - [26.3 What was actually done in Ansible](#sec-26-3)
  - [26.4 The live cluster — unchanged from Section 25, re-verified](#sec-26-4)
  - [26.5 Verification](#sec-26-5)
- [27. The storage fix wasn't actually ordered relative to its consumers (2026-08-17)](#sec-27)
  - [27.1 What was actually true before this section](#sec-27-1)
  - [27.2 Why the fix belongs on the root apps, not on Harbor or kube-prometheus-stack](#sec-27-2)
  - [27.3 The fix](#sec-27-3)
  - [27.4 Verification (rendered — the actual wave numbers, not the annotations in isolation)](#sec-27-4)
- [28. Persistent storage for Prometheus and Alertmanager (2026-08-17)](#sec-28)
  - [28.1 The asymmetry the request warned about — confirmed real](#sec-28-1)
  - [28.2 A second layer of the same asymmetry, found only by rendering — not a problem, but worth recording](#sec-28-2)
  - [28.3 Design choices in the values](#sec-28-3)
  - [28.4 WaitForFirstConsumer — naming why a `Pending` PVC here is not Section 25 again](#sec-28-4)
  - [28.5 Verification](#sec-28-5)
- [29. Prometheus Operator running but not reconciling — stale webhook certs (2026-08-18)](#sec-29)
- [30. TLS enabled on Harbor (2026-08-18)](#sec-30)
  - [30.1 Traced the actual chart templates, not just the values.yaml comments](#sec-30-1)
  - [30.2 The values](#sec-30-2)
  - [30.3 `letsencrypt-production` used directly — a deliberate exception to staging-first, stated plainly](#sec-30-3)
  - [30.4 Section 18 lesson — checked, confirmed not applicable, said so anyway](#sec-30-4)
  - [30.5 Verification — rendered against the real pinned chart, not just parsed](#sec-30-5)
- [31. demo-app image: arm64 build, amd64 nodes (2026-08-18)](#sec-31)
- [32. Argo CD SSO via Dex + GitHub OAuth (2026-08-18)](#sec-32)
  - [32.1 Callback path — verified against current docs, matches what's already registered](#sec-32-1)
  - [32.2 Config location — traced in the pinned chart, not assumed](#sec-32-2)
  - [32.3 `useLoginAsID` — the non-obvious flag that makes username-based RBAC possible at all](#sec-32-3)
  - [32.4 No `orgs:` — a real access consequence, not a missing detail](#sec-32-4)
  - [32.5 The RBAC mapping — proposed, not yet confirmed](#sec-32-5)
  - [32.6 The Secret — imperative, never through Git](#sec-32-6)
  - [32.7 Verification](#sec-32-7)
- [33. SSO implemented on Rancher and Argo CD (2026-08-18)](#sec-33)
  - [33.1 Argo CD — GitHub OAuth via Dex](#sec-33-1)
  - [33.2 Rancher — native GitHub auth provider](#sec-33-2)
- [34. Argo CD flipped to Let's Encrypt production (2026-08-18)](#sec-34)
- [35. `project.yaml` sourceRepos tightened from `"*"` (2026-08-18)](#sec-35)
- [36. Kueue (bonus task) added (2026-08-18)](#sec-36)
  - [36.1 Version, verified two ways — and a real doc-vs-tag mismatch caught by that](#sec-36-1)
  - [36.2 Architecture: cluster singleton, same shape as cert-manager/ClusterIssuer](#sec-36-2)
  - [36.3 The demo: sized to actually prove queueing, not just installation](#sec-36-3)
  - [36.4 A pre-existing condition this inherits, not one it creates](#sec-36-4)
  - [36.4b Demo runtime bumped 60s → 180s — the quota was never wrong, the window was too short (2026-08-18)](#sec-36-4b)
  - [36.5 Verification](#sec-36-5)
- [37. Environment Application-name collision: root cause confirmed, orphaned resources cleaned up, root cause NOT fixed (2026-08-18)](#sec-37)
  - [37.1 Root cause, confirmed directly against the live cluster](#sec-37-1)
  - [37.2 Correction: this is what was actually behind `kube-prometheus-stack`'s bad health](#sec-37-2)
  - [37.3 A live, cluster-wide side effect checked *before* anything was deleted](#sec-37-3)
  - [37.4 What actually got cleaned up — and by whom](#sec-37-4)
  - [37.5 What's still actually broken — cleanup is not a fix](#sec-37-5)
  - [37.6 Verification](#sec-37-6)
  - [37.7 `routa-staging`'s auto-sync removed — closes the recurrence risk 37.5 flagged, not the root cause](#sec-37-7)

</details>

**Date:** 2026-08-09
**Status:** Account and tooling complete. Sizing and region locked from live discovery
data.
**Balance:** $115.35 USD (coupon redeemed into the dedicated project)
**Target region:** FIN-03
**Stated deadline:** 2026-08-13

> **Note:** This document is intended to become the seed of `docs/decisions.md` in the
> submitted repository. The assignment brief states that reasoning, trade-offs and
> debugging approach matter more than a perfect implementation, so a running decision
> log written *as decisions are made* is worth more than one reconstructed at the end.

---

<a id="sec-1"></a>
## 1. Assignment analysis

<a id="sec-1-1"></a>
### 1.1 The brief

Provision infrastructure on Verda Cloud (CPU VMs with public IPs) and build a small
Kubernetes platform. Deliverables: access instructions/screenshots, a Git repository
with manifests/scripts/docs, and a summary report covering what was built,
architecture, what worked and what did not, security and operational considerations,
and what would be improved with more time.

Senior track adds: Rancher Manager, Argo CD, a container registry (Harbor or
alternative), and monitoring — each with SSO "if possible".

Optional advanced tasks: Cilium, KWOK (simulate ~100 nodes), Kueue (priority queues),
GPU tasks if GPU nodes are available, backup strategy, security hardening.

<a id="sec-1-2"></a>
### 1.2 Mapping the assignment to the job description

Every task maps to a stated requirement. This is not a generic DevOps exercise; it is
a targeted probe of the role's competencies.

| Assignment task | Corresponding JD line |
|---|---|
| CPU VMs → build Kubernetes yourself | "Strong experience managing **self-hosted** Kubernetes clusters end-to-end" |
| Rancher Manager + cluster import | Nice to have: "Experience with **Rancher**" |
| Argo CD + GitOps promotion thinking | "Infrastructure automation using **Ansible, GitOps, and CI/CD**" |
| Harbor / registry + image flow | Container platforms, supply chain |
| kube-prometheus-stack + production alerts | "On-call rotations and production incident management" |
| Cilium (bonus) | Nice to have: "**Cilium**"; "Kubernetes networking, CNI plugins, platform security" |
| KWOK 100 nodes (bonus) | Evidence of thinking at cloud-provider scale |
| Kueue (bonus) | Verda ships Kueue documentation for their own Instant Clusters |
| Security hardening (bonus) | "Cluster hardening and access controls" |

**Conclusion:** the bonus list is not a grab-bag. Every item is something Verda
operates in production. Bonus tasks are therefore high-signal, not optional filler.

<a id="sec-1-3"></a>
### 1.3 The most important sentence in the brief

> "We care more about your reasoning, tradeoffs, debugging approach, and final summary
> than a copy-paste happy path."

Repeated in the covering email. Two consequences that shape the whole approach:

1. The **written report is likely worth as much as the cluster**. Budget real time for it.
2. **"What did not work" is a scoring section, not a confession.** Documenting a real
   failure and the debugging path to resolution is the strongest available signal of
   seniority. Do not hide failures; instrument them.

<a id="sec-1-4"></a>
### 1.4 GPU: deferred, not decided — revisit once time budget is known

Initial framing was to skip GPU outright, on the reasoning that credits should be
protected for the core tasks. Revisited after sizing the CPU cluster and confirming
real headroom in the balance ($115.35 against ~$7/day for the full CPU build) — cost
is no longer the binding constraint here, time is.

**Verified pricing** (`verda cost estimate --type 1V100.6V --os-volume 50`):

| | Hourly | Daily |
|---|---|---|
| `1V100.6V` (cheapest GPU type) + 50 GiB | $0.18 | $4.41 |

A short-lived demo — provision, run one GPU workload, capture evidence, tear down —
costs under $1. Leaving it running alongside the CPU cluster costs ~38% of the
remaining balance per day, which rules out treating it as a fifth always-on node.

**Decision, deferred rather than made:** GPU stays the lowest-priority item on the
optional-task list — the brief lists it last, and it is explicitly conditional
("if GPU nodes are available"), unlike Cilium/KWOK/Kueue/backup/hardening, which are
mostly configuration against infrastructure already being built. GPU is additive to
the existing architecture (one more Terraform resource, one more Ansible run against
it) rather than structural, so deferring it costs nothing now.

**Revisit this once the base + senior-track requirements are solid** and the real
remaining time is known. If time allows: provision `1V100.6V` in FIN-03 (confirmed in
stock), install the NVIDIA GPU Operator, run a GPU workload, add a DCGM-based Grafana
panel, then tear down. If time does not allow: the fallback is a written section
covering the approach that would be taken — GPU Operator vs. manual driver install,
device plugin, `nvidia.com/gpu` resources and taints, DCGM exporter, MIG vs.
time-slicing trade-offs — which demonstrates the knowledge without spending the time
or credits.

---

<a id="sec-2"></a>
## 2. Target architecture (planned, not yet built)

```
Terraform (verda provider)  →  4 CPU VMs, public IPs, SSH keys
        ↓
Ansible  →  OS hardening + RKE2 install (Cilium as CNI)
        ↓
VM-0 (mgmt):   k3s + Rancher Manager + cert-manager
VM-1,2,3:      RKE2 cluster → imported into Rancher
        ↓
Argo CD (app-of-apps) → Harbor, kube-prometheus-stack, demo app
```

<a id="sec-2-1"></a>
### 2.1 Rationale per component

**Terraform + Ansible rather than manual provisioning.**
The JD names Ansible explicitly and the brief asks for "manifests/scripts/docs".
Provisioning by hand and screenshotting the result is the mid-level answer.

**Tooling split — three concerns, three tools:**

| Layer | Tool | Scope |
|---|---|---|
| Provisioning | Terraform | VMs, SSH keys, IPs only |
| Configuration | Ansible | OS hardening, RKE2 install, kubeconfig retrieval |
| Application delivery | Argo CD | Everything inside the cluster |

This keeps the Terraform surface deliberately small (roughly four resource types,
~60 lines), which matters because Terraform is the weaker of the two tools for me
right now. It is also a clean architectural story for the report.

**RKE2 as the Kubernetes distribution.** Rancher's own distro, so it integrates
cleanly with Rancher Manager. Ships with built-in etcd snapshots, which gives a
backup story for free. Supports selecting **Cilium as CNI at install time** — one
configuration flag satisfies a bonus task.

**Install Rancher rather than justify skipping it.** The brief permits "explain
clearly why you chose not to", but Rancher is a listed nice-to-have on the JD and is
cheap to run. Declining would read as avoidance.

**sslip.io / nip.io for DNS.** The VMs have public IPs, so `rancher.<ip>.sslip.io`
plus cert-manager with Let's Encrypt yields real TLS and browser access with zero DNS
registration. This is what unblocks the SSO sub-tasks.

**SSO approach.** GitHub OAuth is the fastest genuine implementation — Rancher
supports it natively, Argo CD via Dex. Harbor via OIDC is more work; if time runs
short, document the design instead of building it. The brief says "if possible".

**Secrets in the delivered repo.** SOPS+age or Sealed Secrets. The repository is
being handed to a reviewer, so demonstrating awareness of what a GitOps repo leaks is
worth more than the implementation effort costs.

---

<a id="sec-3"></a>
## 3. Steps completed today, in order, with reasoning

<a id="sec-3-1"></a>
### Step 1 — Analysed assignment and job ad; mapped rubric
**Why first:** understanding what is being tested determines where effort goes.
Building before understanding the rubric risks a technically fine cluster that misses
the point.

<a id="sec-3-3"></a>
### Step 3 — Resolved a misreading: signup does not start a timed session
**Concern raised:** would logging in start the assignment clock?

**Resolution:** no. The brief describes a normal cloud account and a coupon code; the
deadline is a calendar date, not a countdown. The covering email supplies a
self-service coupon code (`ASSIGNMENT-XXXXX`), which supersedes the brief's
"share your email and we will add credits" instruction — nothing is queued on Verda's
side.

**Why this mattered:** the misreading was costing a day of preparation time for no
reason.

<a id="sec-3-4"></a>
### Step 4 — Account, project, and credential setup

Created the Verda account at [console.verda.com](https://console.verda.com) using the
recruiter's email (coupon redemption is cross-referenced against candidates).

**Created a dedicated project (`amir-platform-assignment`) before redeeming the
coupon**, since credits are allocated to whichever project is active at redemption
time — the reverse order would have put credits in the account's default project.

**Reviewed billing safeguards.** Verda's documentation states plainly that a zero
balance discontinues instances and deletes volumes (96-hour restore window). With a
fixed, non-toppable credit pool, this is an operational risk worth monitoring, not
housekeeping. Confirmed low-balance email notifications are on, and explicitly **did
not enable auto top-up or attach a payment card** — no reason to expose personal funds
to a cluster that might be left running.

Enabled account 2FA as baseline hygiene.

**Created scoped Cloud API credentials** (`platform-cli`, 30-day expiry rather than
non-expiring) — the assignment has a known end date, so a permanent credential is an
unnecessary liability. Worth a line in the security section of the report.

<a id="sec-3-5"></a>
### Step 5 — Corrected credential storage
**Problem:** credentials had been temporarily copied into Google Drive.

**Why that is wrong:** not primarily an attacker concern — it is incidental exposure.
Drive files acquire forgotten share links, sync to retired devices, sit in plaintext in
an indexed service, and surface in search months later. Cloud credentials in a synced
document is a legitimate finding in a security review.

**Remediation:** moved to a password manager as the source of truth; deleted the Drive
copy including Trash (30-day retention).

**Target working pattern**, used on every machine since:

```bash
mkdir -p ~/.config/verda
cat > ~/.config/verda/env <<'EOF'
export VERDA_CLIENT_ID="..."
export VERDA_CLIENT_SECRET="..."
EOF
chmod 600 ~/.config/verda/env
```

Sourced at the start of a work session. Using a file rather than typing `export`
at the prompt keeps the secret out of shell history, where it would otherwise persist
in plaintext indefinitely.

**Terraform consequence:** the Verda provider reads `VERDA_CLIENT_ID` and
`VERDA_CLIENT_SECRET` from the environment, permitting an empty provider block:

```hcl
provider "verda" {}
```

Result: **zero credential material anywhere in the repository**, visible at a glance
to a reviewer.

<a id="sec-3-6"></a>
### Step 6 — Verda CLI auth-login bug, and the `routa` naming convention

**Debugging note — interactive `auth login` wizard did not render.** Running
`verda auth login` produced no visible output in Terminal.app; the interactive TUI
wizard hung or cleared silently. Diagnosed as a terminal-rendering issue with the
wizard's TUI library rather than a broken install, since other commands worked
normally. **Resolved by bypassing the wizard** and authenticating via explicit flags:

```bash
verda auth login --client-id "<id>" --client-secret "<secret>"
```

`verda doctor` subsequently passed cleanly on every check. This is a genuine
"what did not work, how it was debugged" instance — an undocumented rendering bug
worked around with a documented non-interactive flag path.

**Naming scheme, decided once rather than improvised per-resource.** The Verda
*project* keeps an explicit name (`amir-platform-assignment`) since it is a
billing/admin object a reviewer may glance at directly. Everything below the project
layer — what would exist if this were real infrastructure — uses a single codename,
**`routa`**:

| Layer | Name |
|---|---|
| Verda project | `amir-platform-assignment` |
| Cluster codename | `routa` |
| SSH key | `routa_ed25519` |
| Planned VM hostnames | `routa-mgmt`, `routa-cp-1`, `routa-cp-2`, `routa-cp-3` |
| Planned DNS | `rancher.routa.<ip>.sslip.io`, `argocd.routa.<ip>.sslip.io` |

Rationale: a billing object appropriately references the fact that this is an
assignment; infrastructure named that way reads as temporary and unconsidered.
Everything a reviewer would encounter *inside* the cluster is named as if going into
production.

---

<a id="sec-4"></a>
## 4. Discovery results — region, sizing and cost model (locked)

Discovery was run *before* any design was committed. This was the correct order: it
surfaced a regional capacity constraint that would have invalidated the plan if
discovered mid-build.

<a id="sec-4-1"></a>
### 4.1 Regional capacity varies — FIN-03 is the only viable region

`verda availability` across all three Finnish regions:

| Location | CPU instance types in stock |
|---|---|
| FIN-01 | **none** |
| FIN-02 | `CPU.4V.16G` only |
| FIN-03 | `CPU.4V.16G`, `CPU.8V.32G`, `CPU.16V.64G`, `CPU.32V.128G` |

**Decision: build in FIN-03.** FIN-02 would force every node down to 4 vCPU / 16 GB,
which is tight for a worker running Harbor alongside kube-prometheus-stack. FIN-01 has
no CPU capacity at all.

**Operational note for the report:** this is live on-demand inventory and it changes.
Capacity constraints are a first-class operational fact on a GPU cloud, and designing
for "the region I want may not have stock" is a legitimate platform concern rather
than an inconvenience. It is also an argument for provisioning sooner rather than later.

**Re-verified before provisioning (2026-08-16):** re-ran `verda availability
--location FIN-03` immediately before starting the build. The type list had shifted
(13 types vs. 14 on first check — several GPU SKUs came and went), which is expected
and confirms live inventory really does move. Both required CPU types,
`CPU.4V.16G` and `CPU.8V.32G`, were still present. Re-checking availability
immediately before `terraform apply` is now standard practice for this build, not a
one-off.

<a id="sec-4-2"></a>
### 4.2 Instance pricing (CPU)

| Type | vCPU | RAM | $/hr |
|---|---|---|---|
| CPU.4V.16G | 4 | 16 GB | $0.0279 |
| CPU.8V.32G | 8 | 32 GB | $0.0558 |
| CPU.16V.64G | 16 | 64 GB | $0.1116 |
| CPU.32V.128G | 32 | 128 GB | $0.2232 |

<a id="sec-4-3"></a>
### 4.3 Storage is billed independently — and it is not a rounding error

`verda cost estimate` breaks compute and OS volume into separate line items.
Storage is linear at **$0.20 / GiB / month**.

The significance: on a `CPU.4V.16G` node, a 100 GiB OS volume costs $20.00/month
against $20.37/month for the instance itself — **disk is half the bill**. An initial
sizing plan that ignored storage understated total cost by roughly 50% on the small
nodes. Verified estimates:

| Configuration | Instance | OS volume | Total/day |
|---|---|---|---|
| CPU.4V.16G + 50 GiB | $0.67 | $0.33 | **$1.00** |
| CPU.8V.32G + 100 GiB | $1.34 | $0.66 | **$2.00** |
| CPU.16V.64G + 100 GiB | $2.68 | $0.66 | **$3.34** |

<a id="sec-4-4"></a>
### 4.4 Locked configuration

| Role | Type | OS volume | $/day |
|---|---|---|---|
| VM-0 — mgmt (k3s + Rancher + cert-manager) | `CPU.4V.16G` | 50 GiB | $1.00 |
| VM-1, VM-2, VM-3 — RKE2 cluster | `CPU.8V.32G` | 100 GiB | $2.00 each |
| **Total, running 24/7** | | | **$7.00/day** |

Against a $115.35 balance: **~16 days of continuous runway**, materially more with
shutdown discipline. Budget is settled and is not the binding constraint — time is.

**Sizing rationale:**
- 32 GB per worker (96 GB across the cluster) comfortably accommodates Harbor,
  kube-prometheus-stack, Argo CD, Cilium, Kueue and a KWOK simulation. 64 GB was
  considered and rejected as paying for unused headroom.
- Workers keep 100 GiB because Harbor stores images and Prometheus stores TSDB, both
  landing on node-local disk via the local-path provisioner. VM-0 runs only Rancher,
  so 50 GiB suffices.
- The governing trade-off: at these prices, **abundant credits are worth spending to
  protect scarce time**. An evening lost to diagnosing OOMKills costs more than the
  entire compute bill.

<a id="sec-4-5"></a>
### 4.5 Shutdown policy

Because storage bills independently of compute, and the pricing model separates the
two, three end-of-session options exist with different economics:

| Action | Saves | Costs |
|---|---|---|
| Leave running | nothing | $7.00/day |
| Shut down | compute only (~$4.35/day, ~62%) | nothing |
| `terraform destroy` | everything | 20–30 min rebuild each morning |

**Policy: shut down between sessions.** It recovers the majority of spend at zero
inconvenience. Billing is prepaid in 10-minute increments with the unused portion
refunded, so there is no penalty for stopping mid-hour.

**At final teardown: purge the volume trash.** Deleted volumes go to a per-account
trash bin and continue to count toward storage quota until permanently purged.

<a id="sec-4-6"></a>
### 4.6 Spot pricing — considered and rejected

Spot pricing is available (`--spot`) and cheaper. Rejected for this build: spot
instances can be reclaimed, and losing an etcd member mid-build would cost hours.

Spot *would* be appropriate for KWOK simulation nodes or CI runners — workloads that
are stateless and cheap to restart. This distinction belongs in the report; it
demonstrates understanding of the platform's own cost model, which is directly
relevant to the role.

---

<a id="sec-5"></a>
## 5. Documentation consulted

| Topic | URL |
|---|---|
| Docs home | https://docs.verda.com/ |
| Cloud Console | https://console.verda.com |
| CLI overview and install | https://docs.verda.com/cli/ |
| CLI getting started / credential resolution | https://docs.verda.com/cli/getting-started/ |
| CLI MCP server | https://docs.verda.com/cli/mcp/ |
| API credentials | https://docs.verda.com/welcome-to-verda/api-credentials/ |
| Pricing and billing (incl. credit coupons, low balance) | https://docs.verda.com/welcome-to-verda/pricing-and-billing/ |
| How to redeem credits | https://docs.verda.com/resources/obtaining-free-credits/how-to-redeem-credits/ |
| Securing your instance | https://docs.verda.com/cpu-and-gpu-instances/securing-your-instance/ |
| Connecting to your server | https://docs.verda.com/cpu-and-gpu-instances/connecting-to-your-datacrunch.io-server/ |
| Shutdown and delete | https://docs.verda.com/cpu-and-gpu-instances/shutdown-hibernate-and-delete/ |
| Terraform provider (Verda docs) | https://docs.verda.com/infrastructure-as-code/terraform/ |
| Terraform provider (Registry) | https://registry.terraform.io/providers/verda-cloud/verda/latest/docs |
| Terraform provider (source) | https://github.com/verda-cloud/terraform-provider-verda |
| Public API reference | https://api.verda.com/v1/docs |
| Audit logs — supported events | https://docs.verda.com/resources/audit-logs/supported-events/ |
| Kubernetes on Instant Clusters | https://docs.verda.com/clusters/instant-clusters/kubernetes/ |
| Kueue job queueing | https://docs.verda.com/clusters/instant-clusters/kubernetes/queueing/ |
| Container registry | https://docs.verda.com/storage/container-registry/ |
| CLI releases | https://github.com/verda-cloud/verda-cli/releases |

<a id="sec-5-1"></a>
### 5.1 Key facts extracted

- Billing is **prepaid, in 10-minute increments**, with the unused portion refunded if
  a resource is terminated early → shutting down between sessions genuinely saves
  credits, with no penalty for stopping mid-hour.
- **Zero balance discontinues instances and deletes volumes** (96-hour restore window).
- Credits are allocated to **the project the coupon is redeemed from**.
- Deleted volumes go to a trash bin and **continue to count toward storage quota**
  until purged.
- API base URL default: `https://api.verda.com/v1`.
- Terraform env vars: `VERDA_CLIENT_ID`, `VERDA_CLIENT_SECRET`, `VERDA_BASE_URL`
  (optional).
- Verda ships an **MCP server** (`verda mcp serve`) exposing 18 tools, plus a skills
  system, explicitly for Claude Code and Cursor. Credentials are shared with the CLI.
- Verda ships an **agent mode** (`verda --agent ...`) producing JSON output and
  structured errors for scripting.

---

<a id="sec-6"></a>
## 6. AI-assisted engineering angle

The JD states this twice: "Leverage AI-assisted engineering tools to improve
automation, operations, and troubleshooting" and "Comfortable using AI-powered tooling
to improve engineering workflows". The covering email hints they want to see it.

Verda ships its own MCP server and skills for Claude Code — so the strongest available
move is to use *their* AI integration to do *their* assignment, and document it.

Planned:

1. Wire up `.mcp.json` in the repository root for Claude Code (`verda mcp serve`) and
   **commit it** — it appears in the diff.
2. Write a `CLAUDE.md` with repository conventions, cluster layout, and runbook. This
   is the AI-native form of "contribute to platform standards, documentation, and
   operational best practices", a listed responsibility.
3. Author one **custom skill** — e.g. a cluster-triage skill running a standard
   diagnostic sequence. This is the difference between *using* AI tools and *building*
   AI-assisted operations.
4. Maintain `docs/ai-usage.md`: what was delegated, what was verified, and **at least
   one case where the AI was wrong and it was caught**. The verification loop is the
   seniority signal; anyone can claim to have used AI.

---

<a id="sec-7"></a>
## 7. Open items

<a id="sec-7-1"></a>
### 7.1 Open question — project scoping for API credentials

**The question:** the dedicated project was created through the console UI. Cloud API
credentials are documented as being *"tied to the team member who created them, not to
a project"*, and neither `verda auth show` nor the Terraform provider schema
(`client_id`, `client_secret`, `base_url` only) exposes a project selector. So it is
not documented how the CLI decides which project a created instance belongs to.

**Evidence so far:** `verda cost balance` returns $115.35, matching the coupon
redeemed into the dedicated project. That is suggestive but not conclusive — it could
equally be reporting an account-level or unallocated balance.

**Why it matters:** if instances land in the default project rather than the dedicated
one, the clean per-project cost tracking intended for the report is lost, and the
credits may not be drawn from where expected.

**Resolution plan, cheapest first:**
1. `verda cost balance -o json` — check whether a project ID is present in the payload.
2. `verda --help`, `verda vm create --help`, and the config-file option (`--config`,
   YAML) — check for a project flag or setting.
3. Empirical test: create one `CPU.4V.16G` instance, confirm in the console which
   project it appears under, then delete it. At $0.04/hr billed in 10-minute prepaid
   increments, this costs under one cent — and doubles as an end-to-end validation of
   the provisioning path before writing any Terraform.

**Fallback if it lands in the wrong project:** recreate the API credentials with the
dedicated project selected in the console, on the hypothesis that credential creation
context determines binding. If that fails, ask Verda support.

**Report value:** this is a genuine "what did not work / how I investigated it" entry.
The brief explicitly weights debugging approach, and an undocumented behaviour resolved
by a one-cent controlled experiment is a better story than a smooth path.

---

<a id="sec-9"></a>
## 9. Standing constraints

- **Nothing is provisioned until there is stable internet.** VMs bill hourly whether or
  not they are reachable; a half-finished RKE2 install over a dropping connection is
  how credits are wasted.
- **Shut down or destroy VMs at the end of every session.** Billing is per 10-minute
  prepaid increment with refunds, so there is no penalty for doing so.
- **No payment card on the account. No auto top-up.**
- **Credentials never enter the repository, a commit, a chat log, or a synced
  document.**
- **Every non-obvious decision gets a line in `docs/decisions.md` at the time it is
  made** — the brief weights reasoning above implementation.

---

<a id="sec-10"></a>
## 10. Repository scaffolded (2026-08-17)

Created the directory structure and starter files for `terraform/`, `ansible/`,
`gitops/`, plus root `.gitignore`, `.mcp.json`, `CLAUDE.md`, `README.md`. No
`terraform apply` or `ansible-playbook` run — this is structure and pinned config
only, per Section 9's "nothing is provisioned until there is stable internet, and
not without deliberate intent" posture.

**Why scaffold now rather than write Terraform ad hoc:** the three-tool split
(Terraform / Ansible / Argo CD) decided in Section 2.1 only holds together if the
directory boundaries are fixed before real resources get added — retrofitting a
clean split after code exists invites scope creep back across the boundaries.

**Versions fetched and pinned at scaffold time** (rather than assumed from training
data — this is now standing policy, written into `CLAUDE.md`):

| Component | Version pinned | Verified against |
|---|---|---|
| `terraform-provider-verda` | 1.1.2 | github.com/verda-cloud/terraform-provider-verda/releases |
| `hashicorp/local` (renders the Ansible inventory) | 2.9.0 | github.com/hashicorp/terraform-provider-local/releases |
| RKE2 | v1.36.3+rke2r1 | github.com/rancher/rke2/releases |
| Cilium (bundled by the RKE2 version above via `cni: cilium`) | 1.19.6 (chart `rke2-cilium` 1.19.601) | RKE2 v1.36.3+rke2r1 release notes, Packaged Component Versions table |
| `community.general` (Ansible collection, needed for the `ufw` module) | 13.3.0 | github.com/ansible-collections/community.general/releases |
| Argo CD | v3.5.1 (Helm chart `argo-cd` 10.3.3) | github.com/argoproj/argo-cd/releases, github.com/argoproj/argo-helm/releases |
| `kube-prometheus-stack` chart | 88.3.0 | artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack |
| `harbor` chart | 1.19.2 | artifacthub.io/packages/helm/harbor/harbor |
| demo app image (`nginx`) | 1.29.8 | hub.docker.com/_/nginx tags |

**One finding worth flagging:** RKE2 v1.36.3+rke2r1 bundles Cilium **1.19.6**, not the
independently-latest upstream Cilium (1.20.0 at scaffold time). Selecting `cni: cilium`
in RKE2's config installs whatever Cilium chart version ships with that RKE2 release —
it is not a free-standing version choice. Recorded this explicitly in
`ansible/group_vars/all.yml` so a future version bump doesn't silently assume the
newer upstream Cilium is what actually gets installed.

**Structural decisions made during scaffolding, not yet in Section 2:**

- **RKE2 topology is 1 server + 2 agents, not a 3-node etcd HA quorum.** All three
  cluster VMs are provisioned identically by Terraform; the split into
  `rke2_server` (first node) vs `rke2_agent` (the other two) happens entirely in the
  generated Ansible inventory (`terraform/templates/inventory.tpl`). Chosen for time
  budget over resilience — a take-home cluster does not need to survive a
  control-plane node failure, and a single etcd member is simpler to reason about
  and debug. Worth a line in the report's trade-offs section.
- **`terraform/variables.tf`'s `image` variable has no default.** The exact
  plain-Ubuntu-24.04 identifier for CPU (non-CUDA) instances was flagged as
  unresolved back in Section 8, step 6, and remains unresolved — leaving it unset
  makes `terraform plan` fail loudly instead of guessing. Resolve via the Verda MCP
  server (`.mcp.json`, now wired up) or `verda images list` before the first apply.
- **Argo CD environments are namespace-suffixed overlays of the same platform base,
  promoted via git ref, not via separate manifests.** `gitops/environments/dev` syncs
  `main` with automated sync; `staging` syncs a `staging` ref; `prod` syncs a `prod`
  ref *and* drops `syncPolicy.automated`, so promoting to prod is a deliberate
  `argocd app sync` after reviewing the diff, not something that happens on merge.
  This gives a real answer to "how would you promote a change" without needing
  three divergent copies of the platform manifests.
- **Argo CD apps for kube-prometheus-stack and harbor are multi-source
  Applications** (Helm chart from its upstream repo + a `values.yaml` tracked in this
  repo). Keeps chart version and values both version-controlled and independently
  bumpable, and is the documented v3.5.1 pattern rather than a values-inlined-in-YAML
  workaround.

**Still open, unchanged from Section 7/8:** the extension/credit-expiry email, the
project-scoping question (7.1), and the CPU image identifier above. None of these
block scaffolding further; they block `terraform apply`.

---

<a id="sec-11"></a>
## 11. Topology change: RKE2 control plane goes from 1 server + 2 agents to a 3-server HA quorum (2026-08-17)

**Reversed the topology decision from Section 10.** `routa-cp-1/2/3` are now three
full RKE2 servers forming an embedded-etcd HA control plane (tolerates one node
failure), not one server with two plain agents. `routa-mgmt` (k3s + Rancher) is
unaffected. Still 4 VMs total — no budget change, see Section 4.4.

**Why reverse it:** the JD explicitly lists high-availability environments as a
competency, and Verda is a managed-Kubernetes provider — shipping a cluster whose
own control plane is a single point of failure undercuts exactly the signal this
assignment is meant to send. The original single-server choice in Section 10 traded
resilience for simplicity/time budget; on reflection that trade reads as *avoiding*
the harder, more relevant demonstration rather than budgeting sensibly. Three
servers costs nothing extra in VM count or in Terraform (`worker_count` was already
3) — the entire cost is a more careful Ansible join sequence, which is a small,
well-documented amount of complexity for a directly-relevant competency signal.

**Servers stay schedulable — no dedicated control-plane taint.** With only 3 cluster
nodes and no separate worker pool, tainting the servers NoSchedule would leave
nowhere for kube-prometheus-stack, Harbor, and the demo app to run. Confirmed via
[github.com/rancher/rke2/issues/508](https://github.com/rancher/rke2/issues/508)
that RKE2 does **not** taint server nodes by default (inherited from k3s) — so this
is the out-of-the-box behavior, not a flag that needed setting. Worth noting for the
report: this is a real trade-off (etcd and API server now share resources with
workloads) that a larger, real deployment would not make; it is acceptable here
because the whole cluster is 3 nodes.

**Config keys verified against the current RKE2 HA docs** (docs.rke2.io/install/ha,
2026-08-17), not assumed from general Kubernetes/etcd knowledge:

- The bootstrap node needs no special init flag — it starts normally and
  auto-generates a token at `/var/lib/rancher/rke2/server/node-token`.
- Joining servers need `server: https://<bootstrap-ip>:9345` (the RKE2 supervisor/
  etcd port, distinct from the Kubernetes API's 6443) and the matching `token`.
- `cni`, `cluster-cidr`, `service-cidr`, and `token` are documented as **critical**
  flags: any mismatch between servers fails the join with "critical configuration
  value mismatch," not a soft warning. `cni: cilium` now lives once in
  `ansible/group_vars/all.yml` and is templated identically onto all three servers
  for exactly this reason — it was already like that from Section 10's Cilium
  work, but it now matters for a different reason (join-time validation, not just
  consistency).
- etcd requires an odd node count to hold quorum; 3 is the documented minimum for HA
  and matches the number of cluster VMs already budgeted.

**Ansible changes:**

- `ansible/roles/rke2-server` now runs on **all three** cluster nodes instead of
  one. It takes a new `rke2_server_url` var (default `""`): empty means "bootstrap,"
  set means "join." The same role/template handles both cases — RKE2's install
  script and systemd unit are identical for a bootstrap or joining server
  (`INSTALL_RKE2_TYPE` defaults to `server` either way); only the generated
  `config.yaml` differs by a few lines.
- `ansible/roles/rke2-agent` is **deleted**, not repurposed — there are no plain
  agents left in this topology, and keeping an unused role around would be a
  dead-code trap for a future edit.
- `ansible/playbooks/rke2-cluster.yml` is now two plays: bootstrap
  `rke2_server_init` first, then join `rke2_server_join` (2 hosts) with
  `rke2_server_url` / `rke2_join_token` pulled from the bootstrap host's facts via
  `hostvars` — the same fact-passing mechanism Section 10's server→agent design
  already used, just re-pointed at server→server.
- `terraform/templates/inventory.tpl` (and the `.example` inventory) now emit
  `[rke2_server_init]` (1 host) and `[rke2_server_join]` (2 hosts) instead of
  `[rke2_server]` / `[rke2_agent]`; both roll up into `[rke2_server:children]` so
  `hardening.yml` (which targets the whole `routa` group) is unaffected.
- `ansible/playbooks/kubeconfig-fetch.yml` now targets `rke2_server_init`
  specifically (any of the 3 servers would have a valid kubeconfig; fetching from a
  fixed, deterministic host avoids 3 redundant copies).

**Not changed by this edit:** the CPU image identifier is still unresolved (Section
10), and nothing has been provisioned — this is still scaffold-only, verified with
`ansible-playbook --syntax-check` and `terraform fmt -check`, no `apply` or
`ansible-playbook` run for real.

---

<a id="sec-12"></a>
## 12. API endpoint, TLS SANs, and a latent `group_vars` bug (2026-08-17)

Two findings from reviewing the `rke2-server` role. The first was raised as "`rke2_tls_san`
is undefined and will hard-fail the template task"; the second was found while
verifying the fix and is the more serious of the two.

<a id="sec-12-1"></a>
### 12.1 The reported issue, corrected

`rke2_tls_san` **was** defined — in `ansible/roles/rke2-server/defaults/main.yml`, as
`[]`. Role defaults are a legitimate definition source with the lowest precedence, so
`{% if rke2_tls_san | length > 0 %}` would have evaluated cleanly and simply skipped
the `tls-san` block. No hard failure.

The real defect was the *value*: an empty SAN list meant the API server cert would
carry only RKE2's built-in defaults, and any client reaching a node by public IP
would fail x509 validation. So the reported symptom was wrong but the underlying
concern was right, and it is the same problem as 12.2 below — worth recording because
"the stated diagnosis was wrong, the instinct was correct" is exactly the kind of
thing the brief's debugging-approach criterion is asking about.

<a id="sec-12-2"></a>
### 12.2 API endpoint decision (and what is deliberately deferred)

**Decision: clients point at `routa-cp-1`'s public IP as the Kubernetes API
endpoint.** The fetched kubeconfig and the eventual Rancher import both use it,
defined once as `rke2_api_endpoint` in `ansible/inventory/group_vars/all.yml`.

**All three server IPs go into `tls-san`, not just the endpoint.** SANs are baked
into the serving cert at cluster creation and cannot be added to a running cluster
without regenerating it — so the cheap move is to enroll all three up front. Moving
the endpoint to another node later then costs a kubeconfig edit rather than a cluster
rebuild. `tls-san` is a YAML list under the hyphenated key, confirmed 2026-08-17
against docs.rke2.io/reference/server_config: *"Add additional hostnames or IPv4/IPv6
addresses as Subject Alternative Names on the server TLS cert."*

**The SAN list is derived from the Terraform-generated inventory, not hardcoded:**

```yaml
rke2_tls_san: "{{ ((groups['rke2_server'] | map('extract', hostvars, 'ansible_host') | list) + [rke2_api_endpoint_host]) | unique | list }}"
```

It tracks `worker_count` automatically and cannot drift from the real IPs. The
concatenation is parenthesised deliberately — Jinja binds `|` tighter than `+`, so
without the parens `a + [x] | unique` applies `unique` to `[x]` alone. Verified by
evaluating it against the example inventory (`-c local`, no host contact): it returns
a real list of three IPs, deduped, with cp-1 appearing once despite being both a
server and the endpoint.

`roles/kubeconfig-fetch` now rewrites the kubeconfig to that same
`rke2_api_endpoint` and **asserts** `rke2_api_endpoint_host in rke2_tls_san` before
doing so. Both values derive from one variable, so they cannot drift; the assert is
there to catch someone later overriding one without the other, and it fails with an
explanation rather than handing over a kubeconfig that dies on x509.

**Deferred, and this is the honest limitation: API access is not HA.** etcd genuinely
is — three members, tolerates one node failure. But every client currently talks to
one node's API server, so losing `routa-cp-1` means losing API access even though the
cluster itself survives and the remaining two servers keep serving. **The production
answer is a load balancer or a DNS name in front of all three API servers**, with the
kubeconfig pointing at that name; RKE2's docs call this the "fixed registration
address". That was skipped here because Verda's CPU instances come with public IPs but
no managed LB in this project, and standing up haproxy/keepalived on `routa-mgmt`
would make the mgmt node a new single point of failure — solving the problem only by
moving it. Since the SAN list already covers all three servers, adding a real endpoint
later is a config change, not a rebuild. Called out explicitly in the report's
"what I would improve with more time" section rather than left for a reviewer to spot.

<a id="sec-12-3"></a>
### 12.3 The bug found while verifying: `group_vars/` was never being loaded

Verifying the SAN fix meant actually rendering the template, which failed with
`'rke2_cni' is undefined` — a variable that had been sitting in `group_vars/all.yml`
since Section 10 and looked fine in review.

**Cause:** Ansible auto-loads `group_vars/` from two places only — adjacent to the
**inventory file**, and adjacent to the **playbook**. The layout had
`ansible/group_vars/`, `ansible/inventory/hosts.ini`, and `ansible/playbooks/*.yml`,
so the lookup paths were `ansible/inventory/group_vars/` and
`ansible/playbooks/group_vars/`. Neither is `ansible/group_vars/`. **Nothing in that
file was ever loaded.**

**Why it stayed hidden:** an earlier ad-hoc verification (`ansible ... -m debug -a
var=rke2_tls_san`) resolved the variables correctly and looked like confirmation. It
only worked because it was run from `cd ansible/`, making the current directory the
basedir. The test passed for a reason unrelated to what it appeared to be testing —
a false green, and a reminder that a verification run has to reproduce the real
invocation path, not merely exercise the same variables.

**Blast radius had this shipped:** the RKE2 version pin, `cni: cilium`, the token
path, and the new SAN work were all silently absent. The first real
`ansible-playbook playbooks/site.yml` would have failed at the config template with
`'rke2_cni' is undefined` — noisy and quick to diagnose, but only after provisioning
four VMs and paying for them. Worse, `rke2_version` going unset would have meant the
install script silently pulling **latest** RKE2 rather than the pinned
`v1.36.3+rke2r1` — a direct violation of `CLAUDE.md` rule 2, arriving through an
unloaded-file path rather than through anyone actually writing `latest`.

**Fix:** moved `ansible/group_vars/` → `ansible/inventory/group_vars/`, adjacent to
the inventory, which loads regardless of playbook location or working directory.
Confirmed by running a throwaway play from `playbooks/` and watching all four
variables resolve. Path references updated across `CLAUDE.md`, the Terraform inventory
template, and the role comments.

**Verification approach changed as a result.** `--syntax-check` and `terraform fmt`
validate structure but never evaluate a variable or render a template, so both passed
against a config that could not work. Anything non-trivial now gets rendered
locally (`connection: local`, no host contact) and the output parsed, before it counts
as verified. The rendered configs were checked this way: `tls-san` parses as a real
three-element list, identical across all three servers; the bootstrap node emits no
`server:` key; both joiners emit `server: https://<cp-1>:9345`.

**Still scaffold-only.** Nothing provisioned, no commits made.

---

<a id="sec-13"></a>
## 13. CPU image identifier resolved (2026-08-17)

The `image` variable flagged as unresolved since Section 8 (step 6) and reiterated
in Sections 10 and 12 is now resolved. Not changed retroactively in those earlier
entries — they're an accurate record of what was known at the time.

**Method:** the Verda MCP server declared in `.mcp.json` (`verda mcp serve`) was not
available as a tool at the time of this lookup — because it was **pending interactive
approval**, not because it was misconfigured or broken. Project-scoped `.mcp.json`
servers do not auto-start: Claude Code requires the user to approve each one
explicitly before it will run. That is a deliberate security gate, and a correct one
— a project-scoped `.mcp.json` is checked into the repo, so auto-executing it would
mean cloning a repository silently launches whatever command that file names. The
approval prompt is the thing standing between "clone a repo" and "execute arbitrary
local processes."

So the correct reading is *not* "the MCP server never surfaced / was unavailable."
It had simply not been approved yet in this session. Fell back to the CLI directly
(`verda images --type CPU.8V.32G -o json`), which is what the MCP server wraps per
docs.verda.com/cli/mcp, so the data source is identical either way. Worth a line for
the report: the MCP-first instruction in `CLAUDE.md` is a preference for freshness
over training data, not a hard dependency on the MCP transport specifically — the CLI
is an equally-live fallback, and the image slug recorded below is unaffected by which
of the two returned it.

**Resolved later the same day.** The server was approved and now reports `✔ Connected`
under `claude mcp list`, and the first lookup verified to have gone through the MCP
server's own tools (`mcp__verda__list_vms`) rather than a shell call to the CLI is
recorded in `docs/ai-usage.md` under "Verified MCP-tool use."

**Cross-checked against both instance types actually used** (`CPU.8V.32G` for
cluster nodes, `CPU.4V.16G` for mgmt) — same image compatible with both, so a single
shared `var.image` (as already structured in `instances.tf`) is valid.
(Note: this was the cluster-node type at the time of writing; see §14 for the
capacity-driven fallback to CPU.16V.64G, confirmed still running via the MCP
verified-use check above.)

**Candidates returned for Ubuntu 24.04** (all `category: ubuntu`):

| `image_type` | Notes |
|---|---|
| `ubuntu-24.04-cuda-13.0-open-docker` | CUDA 13.0 Open + Docker |
| `ubuntu-24.04-cuda-13.0-open` | CUDA 13.0 Open |
| `ubuntu-24.04-cuda-12.8-open-docker` | CUDA 12.8 Open + Docker — `is_default: true` |
| `ubuntu-24.04-cuda-12.8-open` | CUDA 12.8 Open |
| `ubuntu-24.04-cuda-12.6-docker` | CUDA 12.6 + Docker |
| `ubuntu-24.04-cuda-12.6` | CUDA 12.6 |
| **`ubuntu-24.04`** | **"Minimal Image", no CUDA — picked** |

**Picked `ubuntu-24.04`:** the only non-CUDA Ubuntu 24.04 entry in the catalog.
Every other variant ships NVIDIA CUDA userspace and drivers sized for GPU workloads —
unnecessary disk, boot time, and attack surface on CPU-only nodes that install their
own stack (RKE2, Cilium, k3s) via Ansible regardless. `is_default: true` on the
12.8-open-docker variant is Verda's default for their GPU-oriented console flow, not
a signal relevant to a CPU build — worth noting since blindly trusting `is_default`
would have picked the wrong image here.

**Confirmed the Terraform resource wants the slug, not the UUID.** `verda images`
returns both an opaque `id` (UUID) and an `image_type` (the human-readable slug, e.g.
`ubuntu-24.04`). The provider's own example usage (`docs/resources/instance.md`,
already verified in Section 10 while writing `instances.tf`) sets `image =
"ubuntu-24.04-cuda-12.8-open-docker"` — a slug, not a UUID — so `image_type` is the
correct field.

**One catalog-scope observation:** `verda images` has no `--location` flag, unlike
instance-type stock (Section 4.1), which is genuinely region-scoped and re-checked
immediately before every apply. The image catalog appears to be global rather than
per-region. Not re-verified per-region for that reason — flagging the distinction so
a future reader doesn't assume the same "re-check before apply" discipline applies
here for the same reason it does to instance types.

**Set as the default** for `variables.tf`'s `image` variable (was previously
required with no default, by design, so `plan`/`apply` would fail loudly rather than
guess). `terraform.tfvars.example`, `CLAUDE.md`, and `README.md` updated to match —
none of them still describe this as open. Still scaffold-only: no `terraform plan`
or `apply` run, nothing committed.

---

<a id="sec-14"></a>
## 14. Capacity constraint hit mid-apply: worker type falls back to CPU.16V.64G (2026-08-17)

**What happened:** `terraform apply` failed partway through with a 503 "No capacity
available" on 2 of the 3 workers. `CPU.8V.32G` — the worker type locked in Section
4.4 and re-confirmed in stock as recently as 2026-08-16 (Section 4.1) — had dropped
out of FIN-03 availability *during the apply itself*.

**Diagnosis, from live data rather than assumption:**

```
verda availability --location FIN-03
```

FIN-03 now returns 13 types. `CPU.8V.32G` is absent. The CPU types still in stock are
`CPU.4V.16G`, `CPU.16V.64G`, `CPU.180V.720G`, `CPU.360V.1440G`. Note `CPU.32V.128G`
has also since vanished relative to the Section 4.1 snapshot — the inventory really
does churn, in both directions.

**Decision: fall back to `CPU.16V.64G`** — the next type up that is actually in stock,
and the cheapest viable one (the 180V/360V types are enormous and would blow the
budget). Verified before committing to it:

| Check | Command | Result |
|---|---|---|
| In stock | `verda availability --location FIN-03` | `CPU.16V.64G` present |
| Cost | `verda cost estimate --type CPU.16V.64G --os-volume 100` | $2.68 + $0.66 = **$3.34/day** |
| Image compatible | `verda images --type CPU.16V.64G` | `ubuntu-24.04` present |

That last check mattered: the image resolved in Section 13 had only ever been
cross-checked against `CPU.8V.32G` and `CPU.4V.16G`. Changing instance type without
re-verifying image compatibility would have been exactly the kind of assumption
`CLAUDE.md` rule 3 exists to prevent.

**Cost impact, accepted:** $3.34/day per worker vs $2.00 — cluster total moves from
~$7/day to **~$11/day** ($3.34 × 3 + $1.00 mgmt). Against the remaining balance this
is still comfortably inside budget, and Section 4.4's governing trade-off still holds:
abundant credits are worth spending to protect scarce time. The upside is incidental —
64 GB per worker instead of 32 GB removes any doubt about running Harbor,
kube-prometheus-stack, KWOK and Kueue concurrently.

**All three workers move, not just the two that failed.** `routa-cp-2` had already
provisioned successfully as a `CPU.8V.32G` and is in Terraform state; changing
`worker_instance_type` means Terraform will **replace** it. That is intended and worth
the rebuild: a 3-node etcd quorum with one member on materially different hardware is
an asymmetry that shows up later as uneven resource pressure and confusing
"why is this node always the one that's slow" incidents. `routa-cp-2` holds no state
worth preserving at this stage — the cluster isn't bootstrapped yet — so replacement is
nearly free right now and would not be later.

**Section 4.4's original sizing table is deliberately left unedited** as a record of
what was planned before the constraint hit. The reasoning there (32 GB sized against
the actual workload, 64 GB rejected as unused headroom) was sound on the information
available; it was overtaken by capacity, not by being wrong. Amending it in place
would erase the more interesting fact — that the plan survived contact with reality
only up to the point where the provider ran out of the SKU it depended on.

**Operational note for the report.** Section 4.1 already called capacity "a
first-class operational fact on a GPU cloud" and argued for provisioning sooner
rather than later. This is that prediction landing, and mid-apply is the worst
moment for it. The real lesson is narrower than "check availability first" — that
*was* done, twice. It is that on a provider with live inventory, an instance type is
not a stable input: a plan validated at T-0 can be invalid at T+3 minutes. The
production answer is to design for substitutability — a prioritised list of
acceptable types with automatic fallback, rather than one hardcoded SKU whose
disappearance halts the build. Left as a documented improvement rather than built,
since Terraform has no native "first available from this list" primitive and
faking it would cost more time than the fallback it automates.

**Changed:** `terraform/variables.tf` (`worker_instance_type` default, plus the
`image` variable's provenance note now covering `CPU.16V.64G`),
`terraform/terraform.tfvars.example`. No `plan` or `apply` run — the replace plan is
to be reviewed by hand first.

---

<a id="sec-15"></a>
## 15. SSH identity: Verda's minimal image seeds root, not `ubuntu` — and the root→admin handover (2026-08-17)

**Finding.** Verda's minimal `ubuntu-24.04` image (the one resolved in Section 13)
seeds the SSH key to **`root`**, not to an `ubuntu` user. Confirmed empirically:
`ssh root@<node>` succeeds, `ssh ubuntu@<node>` returns `Permission denied
(publickey)`. Key injection is working correctly — it is just on a different account
than assumed.

**Why the assumption was there.** `terraform/templates/inventory.tpl` emitted
`ansible_user=ubuntu`, carried over from the near-universal convention on
AWS/GCP/Azure Ubuntu cloud images, which ship cloud-init configured with an `ubuntu`
sudo user and deliberately no root SSH. Verda's image is *minimal* — it does not.
This is a good example of a convention so widespread it reads as a property of
Ubuntu itself rather than of the image builder, and it was never verified against
Verda specifically. Nothing in Section 13's image-resolution work would have caught
it: `verda images` reports the image, not the account it provisions.

**Change 1 — bootstrap as root.** `inventory.tpl` (and the `.example` mirror) now
emit `ansible_user=root`. The rendered `hosts.ini` is Terraform-generated, so the
fix belongs in the template; editing the rendered file would be undone by the next
`terraform apply`.

**Change 2 — don't just run as root; hand over to an admin user.** Connecting as
root and leaving it that way would trade a broken assumption for a worse posture.
The `hardening` role now, in this order:

1. creates a non-root admin user (`routa`) with `sudo` group membership,
2. installs the same assignment public key for it,
3. grants passwordless sudo (`/etc/sudoers.d/90-routa`, written with
   `validate: visudo -cf %s` so a malformed entry is rejected before it lands),
4. **verifies** the admin user can log in *and* escalate,
5. only then disables root SSH login and password authentication.

**Step 4 is the point of the whole design.** The role's last act is to remove the
only access path it currently has. If the key install or the sudoers entry were
silently wrong, disabling root login would strand a node with no way back in — a
provider-console rebuild, not a re-run. So before the lockdown tasks, a probe task
connects *as the admin user* and escalates to root, and an `assert` gates the
lockdown on that succeeding. The probe uses task-level `vars: ansible_user`
(precedence 17), which outranks the play's root identity (12). Passwordless sudo is
not laziness here: the admin account is key-only with no password at all, so a sudo
prompt would be unsatisfiable and would hang every `become: true` task in the plays
that follow.

**Change 3 — two-phase connection.** Phase 1 (`hardening.yml`) connects as root;
phase 2 (`rke2-cluster.yml`, `kubeconfig-fetch.yml`) connects as `routa`.

**The pattern, and the documented reason for it.** The Ansible docs are explicit
that play `vars:` (precedence 12) beat inventory group vars (3–6), so setting
`ansible_user` in each play's `vars:` block reliably overrides the inventory's
`ansible_user=root`. The docs are conspicuously **silent** on how the `remote_user:`
play keyword ranks against the `ansible_user` variable — the connection-details page
lists both as ways to set the login user and defers to a precedence page that does
not resolve the pair. Choosing an SSH identity by relying on an interaction the
documentation does not define is how a hardening run locks you out of four hosts, so
`remote_user` is deliberately unused here. Verified empirically rather than trusting
the reading: with `ansible_user=root` in the inventory, phase 1 resolves to `root`,
phase 2 resolves to `routa`, and the task-level probe override resolves to `routa`.

**Re-run behaviour, handled explicitly rather than silently.** After a successful
first run root SSH is gone, so re-running `site.yml` cannot connect as root. The
hardening play takes `-e hardening_connect_as=routa` for that case. An automatic
"try root, fall back to admin" probe was considered and rejected: it would make a
genuinely broken key install look like a clean run that happened to use the other
identity, which is precisely the failure the assert in step 4 exists to surface.

**New dependency:** `ansible.posix` 2.2.2 (pinned, verified against the collection's
releases page) for `ansible.posix.authorized_key` — that module is not in
ansible-core. Added to `requirements.yml` alongside `community.general`, with a note
on which role uses each.

**Verified without running the playbook**, per the Section 12.3 lesson that
`--syntax-check` proves nothing about variable resolution: syntax check passes; both
collections resolve at the pinned versions; `ansible_user` resolves correctly in all
four cases above; `routa_ssh_public_key_path` expands `~` and the file lookup reads
the real key; and `kubeconfig-fetch`'s `delegate_to: localhost` tasks still execute
as the local user rather than being dragged onto the new `ansible_user`. That last
check also caught a portability wart in the probe (`id --user --name` is GNU-only),
now `id -un`.

**Still open — the better answer, deferred.** Bootstrapping as root at all is
avoidable: Verda's Terraform provider exposes a `verda_startup_script` resource
(confirmed in the provider docs while writing `instances.tf`), so the admin user and
its key could be seeded by cloud-init at provision time and root SSH disabled before
Ansible ever connects. That removes the two-phase connection, the re-run override,
and the window where root is reachable over the network. Not done now because it
moves node identity into Terraform and would need its own verification pass against
the provider's startup-script semantics; recorded as a concrete improvement for the
report rather than left implicit.

**Nothing provisioned, no playbook run, no commits.**

---

<a id="sec-16"></a>
## 16. Firewall port set: Cilium/RKE2 ports resolved, and split public vs node-to-node (2026-08-17)

Three defects in the hardening role's firewall, found in review before the playbook
ever ran. All three would have surfaced as "the cluster is up but pods on different
nodes can't talk to each other" — the worst class of bug to debug from inside a
half-working cluster.

<a id="sec-16-1"></a>
### 16.1 The defects

1. **`hardening_cilium_tcp_ports` / `hardening_cilium_udp_ports` were empty**, left as
   a TODO in Section 10 with an explicit "do not guess the port set from memory" note.
   Cilium's VXLAN tunnel would have been silently blocked by the default-deny policy.
2. **No UDP task existed at all.** The role looped only TCP, so the UDP variable was
   dead code — it could have been populated correctly and still done nothing. This is
   the same class of bug as Section 12.3's unloaded `group_vars`: a variable that
   looks configured but is wired to nothing.
3. **Code and comments contradicted each other.** The port list was applied flat to
   every host while the comments claimed `6443`/`9345`/`2379`/`2380` were
   "rke2_server only". The comments described the intended design; the code opened
   etcd on the mgmt node too.

<a id="sec-16-2"></a>
### 16.2 Port set, with provenance

Verified 2026-08-17 against both authorities, which agree:

- RKE2 — https://docs.rke2.io/install/requirements (Inventory of Ports)
- Cilium — https://docs.cilium.io/en/v1.19/operations/system_requirements/
  (v1.19 is the line RKE2 v1.36.3+rke2r1 bundles — Cilium 1.19.6, per Section 10)

| Port | Proto | Purpose | Exposure |
|---|---|---|---|
| 22 | TCP | SSH | public, all hosts |
| 80 | TCP | ingress + ACME HTTP-01 | public, all hosts |
| 443 | TCP | ingress (Rancher/Harbor/demo UIs) | public, all hosts |
| 6443 | TCP | Kubernetes API | public, RKE2 servers only |
| 9345 | TCP | RKE2 supervisor API | peers only |
| 2379 | TCP | etcd client | peers only |
| 2380 | TCP | etcd peer | peers only |
| 2381 | TCP | etcd metrics | peers only |
| 10250 | TCP | kubelet metrics | peers only |
| 4240 | TCP | Cilium health checks | peers only |
| 8472 | UDP | Cilium VXLAN tunnel | peers only |

**`2381` was missing from the original list entirely** — it appears in RKE2's port
table but not in the hand-written comments the list was built from. Fetching the
actual table rather than extending the existing list from memory is what caught it.

**ICMP echo needs no rule.** Both docs list ICMP type 0/8 for Cilium health checks;
Ubuntu's stock `/etc/ufw/before.rules` already ACCEPTs echo-request ahead of the
default-deny policy, so an explicit rule would be redundant. Recorded rather than
silently omitted — the next reader should not have to re-derive why ICMP is absent.

**Ports deliberately not opened**, each with its reason, enumerated in
`roles/hardening/defaults/main.yml`: WireGuard `51871/udp` (encryption not enabled),
Geneve `6081/udp` (VXLAN is the tunnel here), Hubble `4244`/`4245` (not enabled),
Cilium Prometheus `9962-9964` (scraped in-cluster, never crosses the node firewall),
Calico BGP `179` (wrong CNI), NodePort `30000-32767` (services go through ingress).
An unexplained absence is indistinguishable from an oversight; each of these is now
a decision.

<a id="sec-16-3"></a>
### 16.3 Public vs node-to-node — the substantive design change

The list is now split by **exposure**, not by component:

**Public** is only what genuinely must be: SSH, ingress (80/443), and the Kubernetes
API. `6443` is node-to-node in RKE2's own table, but this build needs it public —
the fetched kubeconfig targets a node's public IP (`rke2_api_endpoint`, Section 12)
and Rancher imports the cluster over it. That is a deliberate exposure, marked as
such in the defaults so it is not mistaken for carelessness. It is also the reason
the Section 12 API-endpoint work matters: a real load balancer would let 6443 be
restricted to it instead of the internet.

**Everything else is source-restricted** to `routa_rke2_peer_ips`, derived from the
Terraform-generated inventory (same pattern as `rke2_tls_san`, so it tracks
`worker_count` and cannot drift from the real addresses).

**Why this matters more here than on a typical cloud:** Verda CPU instances in this
build have no private network — peers reach each other over **public** IPs. There is
no VPC boundary doing this job implicitly. Opening `2379` without a source
restriction would have put an unauthenticated-by-network etcd endpoint on the public
internet, holding every cluster secret. The `src` restriction is not defence in
depth here; it is the only network-layer control there is.

**Cluster rules are skipped on the mgmt node** (`when: inventory_hostname in
groups['rke2_server']`), which runs k3s + Rancher and is not an RKE2 member — this
is what resolves defect 3. mgmt's own k3s API is deliberately left closed: Rancher
is reached over 443, and nothing external needs mgmt's API server. In this topology
all three cluster nodes are servers, so RKE2's "server nodes" and "all RKE2 nodes"
source columns collapse to the same peer set; noted in the defaults so a future
split into dedicated workers does not silently inherit the wrong scope.

<a id="sec-16-4"></a>
### 16.4 One addition beyond the reported defects

**80/443 were added**, which the review did not ask for. Not speculative: the
sslip.io + cert-manager design committed in Section 2.1 requires port 80 publicly
reachable for Let's Encrypt HTTP-01 validation, and Rancher/Harbor/the demo app are
all reached over 443. Without them the platform layer would deploy and then be
unreachable, and the failure would look like an ingress or DNS problem rather than a
firewall one. Flagged explicitly rather than slipped in — if ingress ends up confined
to a single node, `hardening_ingress_tcp_ports` should be emptied on the others.

<a id="sec-16-5"></a>
### 16.5 Verification

Rendered rather than run, per the Section 12.3 lesson. Confirmed by evaluating the
real variables against the example inventory (`-c local`, no host contact):

- **mgmt** resolves to public `[22, 80, 443]` and *no* cluster rules — defect 3 fixed.
- **cp-1/2/3** resolve to public `[22, 80, 443, 6443]`, peer-restricted TCP
  `[9345, 2379, 2380, 2381, 10250, 4240]` and UDP `[8472]`, sourced from all three
  peer IPs.
- The `product()` loop expands to the correct `src`/`port` pairing (`item.0` is the
  source IP, `item.1` the port) for both the TCP and UDP tasks — checked because a
  transposed tuple would have produced plausible-looking rules allowing port
  `203.0.113.11` from source `9345`.
- `ufw` module parameter names confirmed against its module docs: `src` is a valid
  alias for `from_ip`, and `udp` is a valid `proto` value.
- No references to the removed `hardening_allowed_tcp_ports` /
  `hardening_cilium_*_ports` remain anywhere in the repo.

**Nothing provisioned, no playbook run, no commits.**

---

<a id="sec-17"></a>
## 17. Rancher Manager on routa-mgmt: the chart's `kubeVersion` cap drives every other version (2026-08-17)

Scaffolded k3s + cert-manager + Rancher for the management node. Nothing run against
the node yet — this section records the version decisions and why, per CLAUDE.md
rule 1 (docs before syntax) and rule 2 (pin everything, with provenance).

<a id="sec-17-1"></a>
### 17.1 The constraint that decided it

The Rancher Helm chart carries a hard `kubeVersion` cap, and it differs by channel.
Read verbatim from the published chart indexes rather than from docs prose:

| Chart | Channel | `kubeVersion` | Certified downstream k8s |
|---|---|---|---|
| 2.14.3 | `server-charts/stable` (index gen 2026-06-29) | `< 1.36.0-0` | 1.33 – 1.35 |
| 2.15.0 | `server-charts/latest` (index gen 2026-07-30) | `< 1.37.0-0` | 1.34 – 1.36 |

Our RKE2 workload cluster is `v1.36.3+rke2r1` (Section 11). Rancher v2.15 is the
first release to certify Kubernetes 1.36 for imported clusters — it "adds support for
Kubernetes v1.36 while removing support for Kubernetes v1.33"
(github.com/rancher/rancher/releases/tag/v2.15.0, released 2026-07-30). **Rancher
2.14.x cannot import our cluster at all.** So the import requirement, not a
preference for novelty, selects 2.15.0.

**Accepted tradeoff, stated plainly:** v2.15.0 is a `.0` release, 18 days old at time
of writing, published only to the `latest` channel, and SUSE has *not* yet published a
support-matrix page for it — the matrix index tops out at v2.14.4 and the v2.15.0 URL
returns HTTP 404. Choosing it over stable-channel 2.14.3 is a real risk, taken
knowingly because the alternative is rebuilding the RKE2 cluster on 1.35.x. The
fallback is preserved deliberately — see 17.2.

<a id="sec-17-2"></a>
### 17.2 k3s pinned to 1.35, not 1.36 — the non-obvious call

The obvious move is to match the RKE2 cluster at 1.36.3 for symmetry. Rejected.

The local cluster's Kubernetes version has nothing to do with which downstream
versions Rancher can import; that range comes from the Rancher version, not from the
k3s underneath it. Rancher 2.15.0 imports our 1.36.3 cluster regardless.

What 1.35 buys is optionality: `v1.35.7+k3s1` satisfies **both** chart caps, so the
stable-channel 2.14.x chart stays installable on this node if 2.15.0 disappoints.
Installing k3s 1.36 would violate `< 1.36.0-0` permanently and close that door
without rebuilding the node. Zero cost, real hedge — which is exactly what the 17.1
risk needs. It also sidesteps the Traefik chart v40.x breaking change noted in the
`v1.36.3+k3s1` release notes.

<a id="sec-17-3"></a>
### 17.3 Ingress: ingress-nginx is retired, so Traefik

The first plan pinned ingress-nginx. That was wrong and was corrected before any code
was written. **`kubernetes/ingress-nginx` was retired in March 2026.** Per the
Kubernetes Steering and Security Response Committees
(kubernetes.io/blog/2026/01/29/ingress-nginx-statement/): *"There will be no more
releases for bug fixes, security patches, or any updates of any kind after the project
is retired,"* and *"choosing to remain with Ingress NGINX after its retirement leaves
you and your users vulnerable to attack."* The repo is archived and read-only.

Pinning an archived, unpatched, internet-facing controller in front of Rancher — which
holds cluster-admin credentials for the whole fleet — is the opposite of what pinning
is for. A version pin is only a safety property if someone is still shipping fixes for
that line.

Chose **Traefik chart 41.2.0** (appVersion `v3.7.10`, `kubeVersion >=1.25.0-0`,
published 2026-08-07). k3s's *bundled* Traefik is disabled via `disable: [traefik]`
and we install the chart ourselves, so the version is ours to pin rather than k3s's to
choose — the same property the ingress-nginx plan was reaching for. `servicelb` is
deliberately left enabled: on a single node with no cloud LB, klipper-lb is what gives
the Traefik Service an external address for the HTTP-01 challenge.

*(For future readers: F5's `nginxinc/kubernetes-ingress` is a different codebase and
is unaffected by the retirement. It is also not a drop-in replacement, and was not
treated as one.)*

<a id="sec-17-4"></a>
### 17.4 cert-manager — and ignoring Rancher's own docs on it

Pinned `v1.21.1`. cert-manager 1.21 supports Kubernetes 1.33 → 1.36
(cert-manager.io/docs/releases), covering our k3s 1.35.7.

Deliberately **not** taken from Rancher's documentation. Rancher's "Upgrading
Cert-Manager" page still says it "was last tested with cert-manager version v1.13.1"
and elsewhere recommends "1.6.2 and 1.7.1" over versions reaching EOL in *March 2022*.
That page is years stale. The binding, current constraint is cert-manager's own
support table. The one part of Rancher's guidance that does still hold is the
`cert-manager.io/v1` API compatibility statement — and v1 is what 1.21.x serves.

Installed from OCI (`oci://quay.io/jetstack/charts/cert-manager`), which cert-manager's
install docs now call the source of truth, "published immediately upon release". CRD
flag is `crds.enabled=true`; the older `installCRDs=true` is superseded.

Helm CLI pinned at `v3.21.4` (newest v3, 2026-08-14). The releases page now warns
"Helm v3 is approaching end-of-life. Please update to Helm v4." Not taken now:
migrating chart tooling to a new major version *while* standing up Rancher would
confuse two independent failure modes. Logged as future work.

<a id="sec-17-5"></a>
### 17.5 Let's Encrypt over sslip.io is a known trap

`ingress.tls.source=letsEncrypt` with hostname `rancher.95.133.252.175.sslip.io`.

**sslip.io is not on the Public Suffix List.** Let's Encrypt therefore treats all of
sslip.io as ONE registered domain, and every sslip.io user on the internet shares a
single weekly certificate quota. That quota has been exhausted before —
github.com/cunnie/sslip.io/issues/108, "Let's Encrypt Rate Limit Exhausted for
sslip.io". Issuance can fail for reasons entirely unrelated to our configuration.

Mitigation, encoded in the vars rather than left to memory:
`letsEncrypt.environment` defaults to **`staging`** here, so the full path (DNS →
ingress → HTTP-01 → cert) is proven before spending a production issuance. Staging
certs are browser-untrusted — that warning is expected output, not a fault. If
production is rate-limited, the fallback is `ingress.tls.source=rancher` (self-signed
via cert-manager), which needs no external CA. The cert-status task reports rather
than asserts, precisely so a rate-limit does not fail an otherwise-correct run.

<a id="sec-17-6"></a>
### 17.6 Structure: Ansible, not gitops/

`ansible/roles/k3s-server`, `ansible/roles/rancher`, `playbooks/mgmt-rancher.yml`
targeting the existing `[mgmt]` inventory group, pins in
`inventory/group_vars/mgmt.yml`, appended to `site.yml`.

Not in `gitops/`, and the reason is not filing convenience: Argo CD delivers workloads
*into* the RKE2 cluster, whereas Rancher *manages* clusters and must outlive the
cluster it manages. Putting it in `gitops/` would make the management plane a tenant
of the thing it manages.

Credentials stay out of the repo (CLAUDE.md): `bootstrapPassword` is read from
`$RANCHER_BOOTSTRAP_PASSWORD` and the role asserts it is set and ≥12 characters before
touching the cluster, rather than letting Rancher generate a random password nobody
recorded. The Helm task is `no_log: true`.

<a id="sec-17-7"></a>
### 17.7 Verification so far (rule 4 — render, don't syntax-check)

`--syntax-check` passes, but per Section 12 that proves nothing about variables. Vars
were rendered with `-c local` (no SSH to the node) **from the repository root, not
from `ansible/`** — deliberately, so the check cannot pass for the cwd-dependent
reason that produced the false green in Section 12.2. Resolved values:

```
hostname=rancher.95.133.252.175.sslip.io | k3s=v1.35.7+k3s1 | rancher_chart=2.15.0
traefik=41.2.0 | certmgr=v1.21.1 | helm=v3.21.4 | disable=['traefik']
tls_source=letsEncrypt | le_env=staging | le_class=traefik | admin_user=routa
```

The hostname derives from the inventory's real IP rather than being hardcoded, and
that IP was independently confirmed against Verda's live API via the MCP server
(`describe_vm`, see docs/ai-usage.md) — inventory and provider agree.

The credential gate was tested in both directions: env unset → length 0 (assert
fails), env set → length 16 (assert passes). A gate that has only ever been observed
passing is not a verified gate.

<a id="sec-17-8"></a>
### 17.8 Deferred, deliberately

Cluster import and SSO are **not** part of this step, by instruction — Rancher itself
comes up and is reachable first, then each is a separately verified step. One item
found while reading the chart values, to resolve at import time and not before:
`agentTLSMode` defaults to `strict` on v2.9+, and Rancher's docs note that under
strict mode a private/non-standard CA requires `privateCA=true` plus uploading the CA.
Whether that applies to a publicly-trusted Let's Encrypt *production* cert (probably
not) versus a *staging* cert (probably yes) is unverified — flagged rather than
guessed.

**Nothing run against routa-mgmt, no playbook executed, no commits.**

---

<a id="sec-18"></a>
## 18. Rancher TLS: the production cert flip that silently didn't happen (2026-08-17)

Rancher came up as planned. Getting a *browser-trusted* cert onto it took one
non-obvious debugging step, recorded here because the failure mode reported success.

**Staging first, deliberately.** Installed with
`rancher_letsencrypt_environment=staging` — sslip.io is not on the Public Suffix List,
so all of sslip.io shares a single Let's Encrypt weekly quota (Section 17.5). The
point was to prove DNS → ingress → HTTP-01 → cert end to end before spending a
production issuance. It worked.

**The flip that wasn't.** Re-ran the play with
`rancher_letsencrypt_environment=production`. The play reported success and the
`Certificate` object reported `Ready=True`. Both were true and both were misleading —
the server was still serving the staging cert:

```
openssl s_client -connect rancher.95.133.252.175.sslip.io:443 -servername ...
issuer=... (STAGING) Dastardly Durum YR1
```

**Root cause.** cert-manager does not re-issue while a valid, unexpired certificate
already exists in the target secret. Changing the Issuer's ACME environment is not by
itself a trigger for renewal. The staging cert was still well inside its validity
window, so the production flip was a no-op for issuance — nothing failed, nothing
retried, and `Ready=True` was reporting on the *staging* cert it already held.

The general lesson, which is the reason this is written down: `Ready=True` on a
`Certificate` answers "do I hold a valid cert?", not "do I hold the cert you just
asked for?" Those diverge exactly when you change issuer config mid-life. Verifying
against the object rather than the wire would have missed this indefinitely.

**Fix.** Deleted the `tls-rancher-ingress` secret in `cattle-system`. Its absence
triggered a fresh `CertificateRequest`, which went to the now-production Issuer.

**One transient worth not misreading.** For roughly 30 seconds while the secret was
absent, Traefik served its built-in self-signed placeholder (`TRAEFIK DEFAULT CERT`).
An `openssl s_client` check landing in that window looks like a broken issuance but is
just the gap before the new secret lands. Re-check rather than react.

**Confirmed resolved on the wire, not in the API.** Production cert issued, issuer
`CN=YR2` chaining to ISRG Root X1, expiring 2026-11-15; browser-trusted on both laptop
and phone. This is a prerequisite for the deferred cluster import — with a publicly
trusted cert the import can use the plain registration command instead of
`--insecure`, so the downstream agent verifies Rancher's certificate properly rather
than being told not to.

---

<a id="sec-19"></a>
## 19. RKE2 cluster import: `agentTLSMode: strict` vs a public Let's Encrypt cert (2026-08-17)

First import attempt of the RKE2 cluster into Rancher failed. `cattle-cluster-agent`
crash-looped with:

```
Strict CA verification is enabled but encountered error finding root CA
```

**Why.** Rancher gates how downstream agents validate Rancher's own TLS certificate
with the `agent-tls-mode` setting (`settings.management.cattle.io/agent-tls-mode`),
two values:

- `strict` — agents trust *only* the CA named in the `cacerts` setting: a pinned
  private CA. Default for new installs on Rancher 2.9+ (Section 17 chart notes).
- `system-store` — agents trust any CA already in the OS trust store, which covers
  public CAs including Let's Encrypt.

We serve a public Let's Encrypt certificate (Section 18), not a pinned private CA, so
`cacerts` was never set — there was no private root for `strict` mode to find. The
error message is literally accurate: it found no root CA, because none exists to find
under this TLS setup. `strict` and a public cert are simply incompatible; this was not
a misconfiguration of `cacerts`, it was the wrong mode for the certificate we run.

**One easy-to-misread detail while confirming the default.** `kubectl get
settings.management.cattle.io agent-tls-mode -o jsonpath='{.value}'` returned nothing.
That is not "unset" in the sense of undefined — it means Rancher hasn't been told an
explicit override, so it's running on `.default`, which for a 2.9+ new install is
`strict`. The active value has to be read from `.default` when `.value` is empty, not
assumed absent. Checking `.value` alone and seeing blank would read as "no policy
configured," when the policy in force is `strict`.

**Fix applied live.** Patched `agent-tls-mode` to `system-store`, then re-applied the
cluster's registration manifest so `cattle-cluster-agent` regenerated under the new
mode. Cluster went `Active`, agent `1/1 Running` (2 replicas).

**Made reproducible.** Set at Rancher install time as a Helm chart value —
`--set agentTLSMode=system-store` in `roles/rancher/tasks/main.yml`, sourced from
`rancher_agent_tls_mode` in `inventory/group_vars/mgmt.yml` — rather than left as a
manual post-install `kubectl patch` someone has to remember on every rebuild. This
was a deliberate choice between two docs-endorsed mechanisms, not the only one
available: the docs (ranchermanager.docs.rancher.com, installation-references/
tls-settings, verified 2026-08-17) also support patching the
`settings.management.cattle.io` resource directly. They were not treated as
interchangeable — the same page states "If you specify the value through the Helm
chart, you may only modify the value with Helm," i.e. the two mechanisms are
mutually exclusive once one has touched the setting. The Helm value was preferred
specifically because it's what makes the fix survive a rebuild without depending on
anyone remembering the manual patch step.

**Blast-radius note, for the record.** The docs warn that changing `agent-tls-mode`
can disconnect currently-connected downstream agents if their certificate
configuration doesn't line up with the new mode. Not a concern in this instance: no
agents were connected yet — this was the first import attempt, so there was nothing
live to drop.

**Predicted, not stumbled into.** This failure mode — `agentTLSMode` defaulting to
`strict` while the install uses a public Let's Encrypt cert — was called out as an
open risk during planning, before the import was attempted (Section 17.8: *"Whether
[strict mode] applies to a publicly-trusted Let's Encrypt production cert ... is
unverified — flagged rather than guessed"*). Flagging it in advance is why it was
diagnosed from the first log line rather than treated as a mystery.

**Verification.** Rendered, not applied — `rancher_agent_tls_mode` resolves to
`system-store` from the repo root; `ansible-playbook site.yml --syntax-check` passes
from the `ansible/` basedir. Not re-run against routa-mgmt as part of this change;
the value now matches what was already patched live, so the next full rebuild
reproduces the fix instead of regressing to `strict`.

---

<a id="sec-20"></a>
## 20. Argo CD: self-managing bootstrap plan (2026-08-17)

Plan only — nothing installed. Records pinned versions, the bootstrap sequence, how it
wires into the existing `gitops/` scaffold, and the two things still blocking.

<a id="sec-20-1"></a>
### 20.1 Versions pinned

| Component | Pin | Source, verified 2026-08-17 |
|---|---|---|
| `argo-cd` Helm chart | **10.4.0** | `argoproj.github.io/argo-helm/index.yaml` |
| Argo CD app version | **v3.5.1** | appVersion of chart 10.4.0; latest stable, released 2026-08-12 |

Chart 10.4.0 declares `kubeVersion: ">=1.25.0-0"`. Argo CD 3.5 is tested against
Kubernetes v1.33–v1.36; our RKE2 is v1.36.3, inside that range at the top end. Both
constraints checked rather than assumed, because 1.36 is new enough (Section 17) that
being outside a project's tested range is a live possibility, not a formality.

The scaffold already referenced v3.5.1 in `gitops/bootstrap/project.yaml`; that
reference is confirmed still current rather than left to rot. Note the chart is
*community maintained* per Argo CD's own install docs — worth knowing, since it means
chart version and app version move on separate cadences.

<a id="sec-20-2"></a>
### 20.2 RKE2 already has an ingress controller — and it is Traefik

This was the open question in the task ("flag whether RKE2 needs an ingress controller
+ cert-manager first"). Answered empirically against the live cluster, not from docs:

```
kubectl get ds rke2-traefik -n kube-system
  -> DaemonSet, 3/3 Running, hostPort 80->8000, 443->8443
kubectl get ingressclass
  -> traefik (default)   traefik.io/ingress-controller
kubectl get crd | grep traefik
  -> ingressroutes.traefik.io, middlewares.traefik.io, tlsoptions.traefik.io, ...
```

**No ingress controller install is needed on RKE2.** The reason is a notable upstream
change: RKE2 bundles both `rke2-ingress-nginx` (chart 4.15.107) and `rke2-traefik`
(chart 40.1.009), and per the v1.36.3+rke2r1 release notes *"Traefik is now the default
for new clusters starting in v1.36 (existing clusters will keep their current ingress
upon upgrade to avoid breakage)"* — with *"The `ingress-nginx` chart will not receive
any additional updates and will be completely removed in v1.37 for community users."*
Our cluster is new, so it came up on Traefik.

That is the same conclusion reached independently for the mgmt node in Section 17.3,
for the same underlying reason (ingress-nginx's March 2026 retirement). Convergent, not
coordinated — RKE2 upstream and this repo made the same call from the same facts.

Because Traefik is a DaemonSet with `hostPort` 80/443 on every node, and the hardening
role already opens 80/443 publicly on all hosts (`hardening_ingress_tcp_ports`,
Section 16), external ingress works today with no firewall change.

Two follow-ups, neither blocking:

- **Pin it explicitly.** The cluster relies on a *default* that changed in the version
  we happen to run. Per CLAUDE.md rule 2 that should be `ingress-controller: traefik`
  in the RKE2 server config rather than implicit, so a future version bump cannot
  silently move it. Setting it to match what is already running should be a no-op.
- **Version skew, accepted.** RKE2's bundled Traefik is chart 40.1.009 with Rancher's
  `hardened-traefik:v3.7.8-build20260717`; the mgmt node pins Traefik chart 41.2.0
  (appVersion v3.7.10). Different clusters, independently pinned, no shared state — not
  worth forcing into lockstep. The install job logs a warning about the "non-standard
  image tag"; that is Rancher's hardened rebuild, expected here, not a fault.

**cert-manager, by contrast, is genuinely absent** from the RKE2 cluster (no
`cert-manager` namespace, no CRDs). It is required for a real certificate on the Argo CD
hostname, so it has to be part of this work.

<a id="sec-20-3"></a>
### 20.3 The structural call: singletons go in `bootstrap/`, not `platform/`

The existing scaffold has `platform/` as a base that all three of
`environments/{dev,staging,prod}` overlay. All three root Applications target the *same*
cluster (`https://kubernetes.default.svc`) and separate environments by namespace suffix
(`-staging`, `-prod`). That is a sound single-cluster model, but it has a consequence:

**anything placed in `platform/` is instantiated three times.**

For namespaced workloads (demo-app, Harbor) that is exactly right. For cluster-singleton
infrastructure it is wrong — three Applications would contend for one set of
cluster-scoped resources. Argo CD itself, cert-manager (cluster-scoped CRDs), and the
Let's Encrypt `ClusterIssuer` are all singletons. So they go in `gitops/bootstrap/`,
beside the `AppProject` and root apps, which are singletons for the same reason.

This is a wiring decision, not new structure: no new top-level directory, and
`platform/`, `environments/` and the promotion model are untouched.

*Pre-existing issue noticed while working this out, flagged not fixed (out of scope):*
`kube-prometheus-stack` sits in `platform/` and ships cluster-scoped CRDs
(`prometheuses.monitoring.coreos.com` et al). Instantiated three times, the three
Applications will contend over one set of CRDs. The usual fix is to install the CRDs
once as a singleton and set `crds.enabled=false` in the per-environment releases. Worth
a separate pass.

<a id="sec-20-4"></a>
### 20.4 Self-management: `ServerSideApply=true` is mandatory

Argo CD documents self-management — *"Argo CD is able to manage itself since all
settings are represented by Kubernetes manifests"* — with one hard requirement:
*"When managing Argo CD with Argo CD, you **must** enable the `ServerSideApply=true`
sync option."* Without it, field-ownership conflicts make the self-managing Application
behave unpredictably as it rewrites the controller that is doing the rewriting.

The self-managing Application uses a **multi-source** Application (chart from
`argo-helm` pinned at 10.4.0 + `argocd-values.yaml` from this repo) — the same pattern
`kube-prometheus-stack` and `harbor` already use, so there is one mechanism in the repo
rather than two. The pinned chart version in Git then *is* the Argo CD upgrade lever.

**Honest risk.** Self-management means a bad commit to `argocd-values.yaml` can break
the thing that would otherwise fix it, and `prune: true` on an app that owns its own
Deployment can in principle prune Argo CD. Mitigations: `ServerSideApply=true` as
required; the initial Helm install is reproducible from the same values file, so
re-bootstrapping is always possible; and `prune` stays **off** for the self-managing
app until a first sync shows a clean diff. Every other app keeps prune on.

<a id="sec-20-5"></a>
### 20.5 Bootstrap sequence

Four layers, one imperative seed:

1. **Seed (imperative, once):** `helm install argo-cd argo/argo-cd --version 10.4.0`
   into namespace `argocd`, using the *same* `argocd-values.yaml` that Git will manage —
   so the handover in step 3 is a no-op diff rather than a reconciliation fight.
2. **`kubectl apply -f gitops/bootstrap/bootstrap.yaml`** — the single self-referential
   Application whose source path is `gitops/bootstrap/` itself. From here on, adding a
   singleton app is a git commit, not another `kubectl apply`.
3. **Argo adopts itself.** `bootstrap` renders the `AppProject`, the `argocd`
   self-managing Application, `cert-manager`, the `ClusterIssuer`, and
   `root-dev/staging/prod`. The `argocd` app takes ownership of the release from step 1
   via server-side apply.
4. **Root apps sync** → `environments/dev` → `platform/` → the existing child apps.

Ordering note: Argo CD's own Ingress certificate cannot issue until cert-manager is
running, and cert-manager arrives via step 3. So the Argo CD `Certificate` will sit
pending for the first couple of minutes and then resolve on its own. Per the Section 18
lesson, that is a transient to wait out, not a failure to react to.

<a id="sec-20-6"></a>
### 20.6 UI exposure, consistent with Rancher

Hostname `argocd.95.133.252.180.sslip.io` (routa-cp-1, the same node as
`rke2_api_endpoint_host`), served by the in-cluster Traefik, certificate from
cert-manager via Let's Encrypt.

- `configs.params."server.insecure": true` and TLS terminated at Traefik. Argo CD's docs
  require this when the ingress terminates TLS, otherwise the ingress and argocd-server
  both try to own TLS.
- Standard `Ingress` with `ingressClassName: traefik`, not a Traefik `IngressRoute`.
  Rationale: it matches how Rancher was exposed, and the CLI's gRPC traffic is handled
  with `argocd login --grpc-web` rather than protocol-specific routing. The docs' Traefik
  `IngressRoute` approach (a `Header(Content-Type, application/grpc)` rule with
  `scheme: h2c`, terminating both protocols on one port) is the alternative if native
  gRPC becomes worth the extra CRD.
- `global.domain` carries the hostname through the chart; it also sets the `url` Argo
  uses for redirects, which matters for SSO later.
- **Let's Encrypt staging first**, then production — same discipline as Section 18, and
  the same trap applies: flipping the `ClusterIssuer` does not re-issue while a valid
  cert is still in the secret, so the staging secret must be deleted to force
  re-issuance. sslip.io's shared rate limit (Section 17.5) is unchanged and is the
  reason staging comes first.

Single hostname means a single node as the entry point, so cp-1 remains a single point
of *access* while etcd stays genuinely HA — the same deliberate limitation recorded for
the API endpoint in Section 12, with the same answer (an LB or round-robin DNS) deferred
for the same reason.

<a id="sec-20-7"></a>
### 20.7 Blocking: the repo has no Git remote

`git remote -v` is empty. Argo CD pulls manifests from Git, so it cannot function until
this repo is reachable from the cluster. Seven placeholders are waiting on it:

```
gitops/bootstrap/root-dev.yaml:15                       repoURL: REPLACE_ME
gitops/bootstrap/root-prod.yaml:14                      repoURL: REPLACE_ME
gitops/bootstrap/root-staging.yaml:12                   repoURL: REPLACE_ME
gitops/platform/kube-prometheus-stack/application.yaml:19  repoURL: REPLACE_ME
gitops/platform/harbor/application.yaml:16              repoURL: REPLACE_ME
gitops/platform/demo-app/application.yaml:13            repoURL: REPLACE_ME
gitops/platform/harbor/values.yaml:10                   externalURL: https://REPLACE_ME
```

Needs a decision from the operator: **public repo** (Argo pulls anonymously, no
credential in the cluster — simplest, and consistent with "no credentials in this repo")
versus **private repo** (needs a read-only deploy key or PAT as a Secret in the `argocd`
namespace, which is new credential-handling surface). Not guessed — the choice changes
what gets built. `AppProject.spec.sourceRepos` should be tightened from `"*"` to the
real URL at the same time.

<a id="sec-20-8"></a>
### 20.8 Deferred

SSO stays out of scope until Argo CD is up and self-managing, by instruction. Noted for
then: SSO depends on `global.domain` being correct, which 20.6 sets.

---

<a id="sec-21"></a>
## 21. Argo CD bootstrap manifests written (2026-08-17)

Section 20 was a plan. This is the write-up of turning it into files — what changed
from the plan while writing it, and how it was verified. Nothing installed, nothing
pushed, nothing committed; the repo has no Git remote configured in this environment
(operator will create and push it separately).

<a id="sec-21-1"></a>
### 21.1 Files

```
gitops/bootstrap/bootstrap.yaml         self-referential Application (the one seed)
gitops/bootstrap/argocd.yaml            self-managing Argo CD (multi-source, chart 10.4.0)
gitops/bootstrap/argocd-values.yaml     Helm values for the argo-cd chart
gitops/bootstrap/cert-manager.yaml      cert-manager (v1.21.1, OCI source, cluster singleton)
gitops/bootstrap/cluster-issuer.yaml    letsencrypt-staging + letsencrypt-production
gitops/bootstrap/kustomization.yaml     (modified) wires the above into the existing scaffold
```

`repoURL` is `https://github.com/AmirMoshfeghi/routa-platform`; ingress hostname is
`argocd.95.133.252.180.sslip.io` (routa-cp-1, matching `rke2_api_endpoint_host`). Both
supplied by the operator this session, not guessed.

<a id="sec-21-2"></a>
### 21.2 The bug the plan didn't catch: `bootstrap` referencing its own not-yet-created project

Every child Application in this repo uses `project: routa-platform`. Section 20's plan
did not flag that `bootstrap.yaml` — the one Application created imperatively, before
anything else exists — cannot use that same project, because `routa-platform` is
itself one of the resources `bootstrap` manages (`project.yaml`). Referencing it from
`bootstrap.yaml` would mean the very first `kubectl apply -f bootstrap.yaml` names a
project that doesn't exist yet: a chicken-and-egg reference that only breaks on a
genuinely first-time bootstrap, not on any later reconcile once the project already
exists — the kind of bug that is invisible in every state except the one that matters.

Fixed by putting `bootstrap.yaml` alone in the `default` AppProject — the one project
Argo CD creates automatically on install ("If unspecified, an application belongs to
the `default` project, which is created automatically" —
argo-cd.readthedocs.io/en/stable/user-guide/projects/, verified 2026-08-17). Every
other Application in the repo stays on `routa-platform`.

<a id="sec-21-3"></a>
### 21.3 Sync-wave sequencing, and why it's needed at all

`cluster-issuer.yaml` defines two `ClusterIssuer` objects, cluster-scoped like
`cert-manager.yaml`, for the same reason documented in Section 20.3 (platform/ is
instantiated three times; cluster-singletons don't belong there).

A `ClusterIssuer` cannot be created before its CRD exists, and the CRD doesn't exist
until cert-manager's own Helm release has actually deployed — creating cert-manager's
*Application object* is not the same moment as cert-manager being *running*. Annotated
`cert-manager.yaml` and `argocd.yaml` as `sync-wave: "0"` and `cluster-issuer.yaml` as
`sync-wave: "1"`. Confirmed against docs (argo-cd.readthedocs.io/en/stable/user-guide/
sync-waves/, verified 2026-08-17) that waves advance only once every resource in the
current wave is both Synced and Healthy — and a child `Application`'s Health reflects
its own deployed resources' health, not just its own existence as an object — so wave 1
genuinely waits for cert-manager to be running, not merely requested.

`argocd.yaml` shares wave 0 with `cert-manager.yaml` rather than waiting on it: Argo
CD's own Deployments don't need TLS to report Healthy, only its Ingress's certificate
does, and that resolves asynchronously once cert-manager exists — the same
transient-not-failure pattern as Section 18 (Rancher's cert sat pending for a couple of
minutes after chart install; expected, not a fault to chase).

<a id="sec-21-4"></a>
### 21.4 Two things reused from earlier incidents rather than re-derived

**Both ClusterIssuers, always present, never edited in place.** Traces directly to
Section 18: cert-manager does not re-issue while a valid cert already sits in the
target Secret, so mutating one Issuer's `server` field in place is a change that
*looks* like it did something (object updates, `Ready` stays `True`) while silently not
re-issuing anything. Defining `letsencrypt-staging` and `letsencrypt-production` as two
separate, always-present objects makes "switch to production" an unambiguous action —
change which issuer an Ingress annotation names, delete the old Secret to force
re-issuance — instead of a mutation of shared state with a non-obvious side effect.

**`ServerSideApply=true` on `cert-manager.yaml`, predicted rather than hit live.**
cert-manager's CRDs are large enough to exceed Kubernetes' 262144-byte
last-applied-configuration annotation limit under client-side apply — a documented,
common Argo CD + cert-manager failure ("Too long: must have at most 262144 bytes").
Flagged and fixed while writing the manifest, the same posture as the `agentTLSMode`
prediction in Section 19: reasoned out from known failure modes before touching the
cluster, not discovered by watching something crash-loop.

<a id="sec-21-5"></a>
### 21.5 Scope held, gaps flagged rather than silently closed

Only the five files above were written, matching what was asked. Left deliberately
untouched, and worth listing so nothing is mistaken for finished:

- `gitops/bootstrap/root-{dev,staging,prod}.yaml` and
  `gitops/platform/{kube-prometheus-stack,harbor,demo-app}/application.yaml` still
  carry `repoURL: REPLACE_ME` (7 occurrences total, including Harbor's
  `externalURL`). `bootstrap`'s own Kustomize output includes the three root apps, so
  these have to be resolved before any real sync would work end-to-end — not done
  here because the operator's request scoped this step to the five bootstrap files.
- `project.yaml`'s `sourceRepos: ["*"]` is unchanged. Tightening it to the real list
  (this repo, `https://argoproj.github.io/argo-helm`, `quay.io/jetstack/charts`) is
  still correct future hardening per Section 20.7, just not done now, since a
  premature tightening that missed one of the three would break `argocd.yaml` or
  `cert-manager.yaml` with a project-permission error.
- `cluster-issuer.yaml`'s `email` field is `REPLACE_ME_LETSENCRYPT_EMAIL` in both
  issuers — never supplied this session, not guessed.

<a id="sec-21-6"></a>
### 21.6 Verification (rule 4 — rendered, not eyeballed)

`kubectl kustomize gitops/bootstrap` builds clean (exit 0) and produces exactly the 9
expected resources: 1 `AppProject`, 6 `Application` (`argocd`, `bootstrap`,
`cert-manager`, `routa-dev`, `routa-staging`, `routa-prod`), 2 `ClusterIssuer`. Checked
the rendered output field-by-field for the three things most likely to be wrong by
inspection alone rather than by build success: `bootstrap` really does render with
`project: default` (not `routa-platform`); `argocd` and `cert-manager` both carry
`ServerSideApply=true` in `syncOptions`; `argocd`'s `syncPolicy.automated` has no
`prune` key (the deliberate omission holds).

`argocd-values.yaml` is deliberately excluded from `kustomization.yaml`'s `resources:`
— it has no `apiVersion`/`kind`, so Kustomize would fail trying to parse it as a
Kubernetes object. Verified separately: `yaml.safe_load` parses it cleanly, and the
resulting structure matches the exact field paths pulled from the chart source at the
`argo-cd-10.4.0` tag (`server.ingress.*`, `configs.params."server.insecure"`,
`configs.cm.url`, `global.domain`) rather than from memory or docs prose alone —
`templates/argocd-server/ingress.yaml` was read directly to confirm `tls: true`
produces a `tls:` block naming `secretName: argocd-server-tls`, which is the name
cert-manager's ingress-shim annotation targets.

One self-check caught and fixed before this write-up: the first draft of
`argocd-values.yaml` claimed in a comment that its hostname marker
(`ROUTA_ARGOCD_HOSTNAME`) appeared in exactly two places, but the literal hostname
string actually appears three times (`global.domain`, `configs.cm.url`,
`server.ingress.hostname`) and only two carried the inline marker. A comment asserting
a rebuild is "one grep away" is itself a claim that needs to be true, not just written
— fixed by tagging all three occurrences and correcting the count in the comment,
then re-verified by grep.

---

<a id="sec-22"></a>
## 22. Placeholders resolved: repo is push-ready (2026-08-17)

Filled in every remaining input the plan (Section 20) and the write-up (Section 21)
were blocked on. Still nothing installed, nothing committed, nothing pushed.

<a id="sec-22-1"></a>
### 22.1 What was filled in

- **6 `repoURL: REPLACE_ME` occurrences** → `https://github.com/AmirMoshfeghi/routa-platform`,
  each tagged with a `# ROUTA_REPO_URL` marker for a one-grep rebuild (same convention
  the Section 21 files already established):
  `gitops/bootstrap/root-{dev,staging,prod}.yaml`,
  `gitops/platform/{kube-prometheus-stack,harbor,demo-app}/application.yaml`.
- **`cluster-issuer.yaml`'s two `email: REPLACE_ME_LETSENCRYPT_EMAIL`** →
  `amh.moshfeghi@gmail.com`, tagged `# ROUTA_LETSENCRYPT_EMAIL`.
- `root-dev.yaml`'s now-stale "TODO: fill in repoURL once this repo has a remote"
  comment was rewritten rather than left inaccurate once the value it was warning
  about no longer applies — a stale TODO left in place next to a resolved value reads
  as evidence nobody checked the fill-in actually happened.

<a id="sec-22-2"></a>
### 22.2 One instruction that didn't cleanly apply: Harbor's `externalURL`

The count "7 `REPLACE_ME` occurrences" carried over from Section 21's write-up
included `gitops/platform/harbor/values.yaml:10` — `externalURL: https://REPLACE_ME`.
That one is **not** a repo URL and not the Argo CD hostname; it's Harbor's own
registry hostname, a separate, not-yet-made decision. Setting it to
`argocd.95.133.252.180.sslip.io` would collide it with Argo CD's own hostname — two
different backends claiming the same Ingress host rule, an actual routing conflict,
not a naming preference. Left as `REPLACE_ME`, not resolved by inference from an
instruction that named a different value for a different purpose. `harbor/values.yaml`
already documents itself as "Placeholder only" pending `docs/decisions.md` Section
2.1's sslip.io plan — this is that same pre-existing, already-flagged gap, not a new
one. So the accurate count for this step was 6 repo-URL fills, not 7; the 7th
(`externalURL`) stays open and is called out explicitly rather than folded into "zero
`REPLACE_ME` left."

<a id="sec-22-3"></a>
### 22.3 TODO before this is production: `project.yaml` sourceRepos is still `"*"`

Per instruction, left as-is this step — tightening needs the full, correct list of
external repos or it breaks `argocd.yaml`/`cert-manager.yaml` with a project-permission
error, and getting that list right belongs with a deliberate pass, not a rushed one
bundled into filling in placeholders. Recorded here as the thing to not forget:

**TODO, before this repo is considered production-ready:** tighten
`gitops/bootstrap/project.yaml`'s `sourceRepos` from `["*"]` to the exact list this
build actually uses — `https://github.com/AmirMoshfeghi/routa-platform`,
`https://argoproj.github.io/argo-helm`, `quay.io/jetstack/charts`,
`https://helm.goharbor.io`, `https://prometheus-community.github.io/helm-charts` — so
the `AppProject` is doing the access-control job an `AppProject` exists to do, rather
than acting as an unscoped passthrough. `sourceRepos: ["*"]` on a project meant to
gate what can be deployed into this cluster defeats the point of having a project at
all; it was a reasonable placeholder for a scaffold with no confirmed source list, not
a reasonable steady state.

<a id="sec-22-4"></a>
### 22.4 Verification (rule 4 — rendered, all four affected roots, not just one)

`grep`-equivalent scan of every file under `gitops/` for `REPLACE_ME`: one hit,
`gitops/platform/harbor/values.yaml:10`, matching Section 22.2 exactly — nothing
unaccounted for.

Section 21 only verified `kubectl kustomize gitops/bootstrap`. This step's edits also
touched files consumed by `gitops/platform` and all three `gitops/environments/*`
overlays, so all four were built, not assumed to follow from the bootstrap build
passing:

```
gitops/bootstrap             exit 0
gitops/platform               exit 0
gitops/environments/dev       exit 0
gitops/environments/staging   exit 0
gitops/environments/prod      exit 0
```

Went one step further for `environments/prod` specifically, since it's the one root
that *patches* the base rather than passing it through unchanged (namespace suffixes,
`targetRevision: prod`, dropped `syncPolicy.automated` — Section 11/promotion model) —
rendered its full output and confirmed the patched Applications still carry the real
`repoURL`, not a value the patch step silently reverted to something stale:

```
repoURL: https://github.com/AmirMoshfeghi/routa-platform   (routa-prod itself)
repoURL: https://helm.goharbor.io                            (harbor chart source)
repoURL: https://github.com/AmirMoshfeghi/routa-platform   (harbor values source)
repoURL: https://prometheus-community.github.io/helm-charts  (kube-prometheus-stack chart)
repoURL: https://github.com/AmirMoshfeghi/routa-platform   (kube-prometheus-stack values)
```

---

<a id="sec-23"></a>
## 23. Bootstrap sync failure: ClusterIssuer bundled in the same Application as cert-manager (2026-08-17)

Reported failure, from a real `kubectl apply -f bootstrap.yaml` attempt: Argo's sync
of the `bootstrap` Application errored with `no matches for kind ClusterIssuer in
version cert-manager.io/v1`. This passed local `kubectl kustomize gitops/bootstrap`
(pure offline YAML templating — it doesn't know or care what kind a resource is)
but failed once Argo's own repo-server/application-controller processed the same
output against a live cluster.

<a id="sec-23-1"></a>
### 23.1 Why sync-waves didn't save this, and why that's not a sync-wave bug

Section 21 put `cert-manager.yaml` at `sync-wave: "0"` and the (then-bundled)
`cluster-issuer.yaml` at `sync-wave: "1"`, reasoning that waves only advance once
everything in the current wave is Synced and Healthy. That reasoning is correct as
far as it goes — but it answers the wrong question. Sync-waves order *when Argo
applies* resources within one Application's sync. They say nothing about the
*validation/comparison pass* Argo runs over an Application's entire target resource
list to build that sync plan in the first place. `project.yaml`, `bootstrap.yaml`,
`argocd.yaml`, `cert-manager.yaml`, and (in the old shape) `cluster-issuer.yaml` were
all resources belonging to the SAME Application (`bootstrap`) and therefore the SAME
comparison pass — and that pass needs every target kind registered on the API server
to process the list at all. On a first bootstrap, `clusterissuers.cert-manager.io`
genuinely does not exist yet, because cert-manager — the thing that would create that
CRD — is itself one of the things this same sync is bringing up. Wave `"1"` on the
resource never got a chance to matter; the failure happened before wave-gating began.

<a id="sec-23-2"></a>
### 23.2 The fix: a separate Application, not a suppressed check

Per Argo CD's own docs (`argo-cd.readthedocs.io/en/stable/user-guide/sync-options/`,
verified 2026-08-17), there are exactly two supported shapes for "a CR depends on a
CRD that might not exist yet":

1. **CRD and CR in the same sync** — Argo auto-skips the dry run for the CR; no
   configuration needed. (Not our case: cert-manager's CRDs and the ClusterIssuers
   were never going to be in the literal same Helm/Kustomize render — cert-manager's
   CRDs come from its own chart.)
2. **CRD created elsewhere** — "the CRD is not part of the sync, but it could be
   created in another way, e.g. by a controller in the cluster" — Argo's own example
   is Gatekeeper, structurally identical to our cert-manager case. Docs are explicit
   this fails without a flag: *"Argo CD cannot find the CRD in the sync and will
   fail... `the server could not find the requested resource`"* — matching the
   reported error almost verbatim.

Restructured to match shape 2 properly:

```
gitops/bootstrap/cluster-issuer-app.yaml   NEW — Application wrapping the directory below
gitops/bootstrap/cluster-issuer/
  cluster-issuer.yaml                      MOVED from gitops/bootstrap/cluster-issuer.yaml
gitops/bootstrap/kustomization.yaml        (modified) cluster-issuer.yaml -> cluster-issuer-app.yaml
```

`cluster-issuer/` has no `kustomization.yaml` — confirmed against
`argo-cd.readthedocs.io/en/stable/user-guide/directory/` that Argo CD auto-detects a
path with no `kustomization.yaml`/`Chart.yaml`/Jsonnet marker as a plain-manifest
"Directory" app and applies the YAML directly, **without invoking Kustomize on that
path at all**. That's the actual mechanism of the fix: the ClusterIssuer objects no
longer go through the same `kustomize build --enable-helm` render, or the same
Application comparison pass, as `bootstrap`'s own resource list. They get their own,
independent sync cycle.

The wave annotation moved with the restructure: `cluster-issuer-app.yaml` (the
Application object, one of `bootstrap`'s own managed resources) carries
`sync-wave: "1"`, `cert-manager.yaml` stays at `"0"`. This is still worth keeping —
it means `bootstrap` doesn't even attempt to create the `cluster-issuer` Application
until `cert-manager`'s Application reports Healthy, reducing how often the next
mechanism below actually has to do anything. But per 23.1, it's a hint, not the fix.

<a id="sec-23-3"></a>
### 23.3 `SkipDryRunOnMissingResource=true` — required, and why it's safe to leave on

Added to `cluster-issuer-app.yaml`'s `syncOptions`, matching Argo's documented
scenario-2 remedy exactly. Safe as a standing setting, not just a one-time unblock:
the same docs page states *"The dry run will still be executed if the CRD is already
present in the cluster"* — it only skips dry-run in the genuinely-missing case, so
once cert-manager is up and stays up, ordinary validation resumes on every later sync.

**Deliberately did NOT add `ServerSideApply=true` to this Application** — the
question was asked directly and the answer is no, for a specific reason: that option
(already correctly present on `cert-manager.yaml`) solves an unrelated problem —
cert-manager's own CRDs are large enough to exceed the 262144-byte
last-applied-configuration annotation limit under client-side apply (Section 21.4).
The ClusterIssuer objects are tiny; there is no annotation-size problem here.
Copying `ServerSideApply=true` onto this Application anyway would be applying a fix
for a failure mode that doesn't exist on this resource — worth naming explicitly
since the two options are easy to reach for as a pair out of habit once one of them
is known to be needed nearby.

<a id="sec-23-4"></a>
### 23.4 Verification (rendered, both the split-out piece and everything around it)

- `kubectl kustomize gitops/bootstrap` — exit 0. Resource list is now `AppProject` +
  6 `Application` objects only (`argocd`, `bootstrap`, `cert-manager`,
  `cluster-issuer`, `routa-dev`, `routa-staging`, `routa-prod`) — **zero**
  `ClusterIssuer` objects in this build, confirmed by listing every rendered
  kind/name, not just checking the exit code. That absence is the actual fix:
  `bootstrap`'s own comparison pass no longer has anything cert-manager-dependent
  in it.
- `gitops/bootstrap/cluster-issuer-app.yaml` rendered inside that same build,
  checked field-by-field: `sync-wave: "1"`, `path: gitops/bootstrap/cluster-issuer`,
  `syncOptions` contains `SkipDryRunOnMissingResource=true` and does NOT contain
  `ServerSideApply=true`.
- `gitops/bootstrap/cluster-issuer/cluster-issuer.yaml` parsed directly with
  `yaml.safe_load_all` (not via `kubectl kustomize`, which requires a
  `kustomization.yaml` and would fail on this directory for an unrelated, expected
  reason) — both `ClusterIssuer` objects present and well-formed.
- Re-built `gitops/platform` and all three `gitops/environments/*` overlays — exit 0
  on all four, confirming the restructure didn't disturb anything outside
  `gitops/bootstrap/`.
- Full `REPLACE_ME` sweep across `gitops/` — zero remaining (the one legitimate
  survivor from Section 22 was resolved separately before this step).

Nothing installed, committed, or pushed as part of this fix.

---

<a id="sec-24"></a>
## 24. kube-prometheus-stack hit the same CRD-size failure as cert-manager (2026-08-17)

Reported failure, same shape as Section 21.4's advance flag on cert-manager, now
actually observed: the Prometheus Operator CRDs this chart installs (`prometheuses`,
`alertmanagers`, `thanosrulers`, `scrapeconfigs`, `alertmanagerconfigs`,
`prometheusagents`) exceed the 262144-byte last-applied-configuration annotation
limit under client-side apply. The CRDs' own apply hard-fails, and because they never
land, the chart's `Prometheus`/`Alertmanager` custom resources then fail separately
with "ensure CRDs are installed first" — one root cause, two visible symptoms.

**Fix:** `ServerSideApply=true` added to `gitops/platform/kube-prometheus-stack/
application.yaml`'s `syncOptions` — identical fix, identical reasoning to
`cert-manager.yaml` (Section 21.4).

**Checked whether this chart needs anything beyond that**, per instruction, rather
than assuming the cert-manager fix transfers unexamined:

- **Not `Replace=true`.** Confirmed against
  blog.ediri.io/kube-prometheus-stack-and-argocd-25-server-side-apply-to-the-rescue:
  `ServerSideApply=true` alone has been the fix since Argo CD >2.5 (we're on 3.5.1 —
  Section 20.1); `Replace=true` was only ever the pre-2.5 workaround, not a pairing
  for current versions.
- **No chart-specific values.yaml workaround.** The chart's own README documents CRDs
  as following Helm's standard "not auto-installed/updated on upgrade" behavior, with
  no ArgoCD-specific guidance and no separate-CRD-management recommendation the way
  some charts carry.
- **No cross-Application split needed**, unlike Section 23's ClusterIssuer fix. That
  case needed structural separation because the CRD (cert-manager's) and the CR
  (ClusterIssuer) belonged to two DIFFERENT Applications with two different sync
  cycles. Here, the CRDs and the CRs that depend on them are both part of the SAME
  chart and the SAME Application — the case Argo's own sync-options docs already
  describe as handled automatically once the CRD can actually apply at all
  ("the CRD manifest is part of the same sync" — quoted fully in Section 23.2).
  `ServerSideApply=true` fixes exactly that blocking step, so there was no ordering
  problem left to solve by splitting anything out.

**Not addressed, and not the same problem:** Section 20.3 separately flagged that
`kube-prometheus-stack` sits in `platform/`, which is instantiated three times (once
per environment), so three Applications will eventually contend over one set of
cluster-scoped CRDs. That is still open. This fix makes the CRDs installable at all;
it does not resolve three environments installing them redundantly.

**Verification (rendered):** `kubectl kustomize gitops/platform` — exit 0. Rendered
all three `gitops/environments/{dev,staging,prod}` overlays and confirmed
`ServerSideApply=true` survives the Kustomize patch layer in each — worth checking
explicitly since prod/staging patch this same Application's `spec.destination.namespace`
and `targetRevision` via JSON patches, and a patch touching nearby paths is exactly
the kind of change that could silently clobber an unrelated sibling field if the
patch path were slightly wrong. It didn't. Full `REPLACE_ME` sweep across `gitops/`
still clean. Nothing installed, committed, or pushed.

---

<a id="sec-25"></a>
## 25. Root cause found: RKE2 never bundled a default StorageClass — this was never disabled (2026-08-17)

Reported symptom: all Harbor PVCs `Pending` ("no storage class is set"), no PVCs at
all for monitoring (Prometheus on ephemeral `emptyDir`), no StorageClass, no
local-path pods anywhere in `kube-system`. The investigation request assumed RKE2
normally ships `rke2-local-path-storage` enabled and asked whether our config turned
it off. **That premise doesn't hold — worth stating plainly rather than quietly
working around it**, because the actual fix is different depending on which is true.

<a id="sec-25-1"></a>
### 25.1 What was actually checked, and what it shows

`ansible/roles/rke2-server` and `inventory/group_vars/all.yml` were searched for any
`disable:` directive or local-path reference — there is none. This is not a case of
finding a suppressed setting; there was never a setting to suppress.

Confirmed against the primary source, not a summary: `docs.rke2.io/reference/
server_config`'s `disable` flag documentation, verified 2026-08-17, lists its entire
valid value set verbatim: *"Do not deploy packaged components and delete any deployed
components (valid items: rke2-coredns, rke2-metrics-server,
rke2-snapshot-controller, rke2-snapshot-controller-crd,
rke2-snapshot-validation-webhook)"* — **no local-path-storage component is in that
list at all**, because RKE2 does not package one. (Consistent with the `ingress-
controller` flag being a *separate*, dedicated flag rather than a `disable` value,
which Section 20.2 already established — RKE2 groups its packaged components
differently depending on the component, and storage isn't grouped in with `disable`
because it was never grouped in as a component in the first place.)

**Corroborated live**, not just from docs: the mgmt node's k3s cluster — a genuinely
different distro, provisioned independently — has a `local-path (default)`
StorageClass with provisioner `rancher.io/local-path`, live and working, with no
extra configuration from this repo at all:

```
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   5h18m
```

That confirms the actual distinction: **k3s bundles a default StorageClass out of the
box; RKE2 — described in its own ecosystem as the more production-oriented
distribution — deliberately does not.** This was true on day one of this cluster; it
is not a regression, and nothing in this repo turned it off. Worth a note on how this
was missed until now: the exact `kube-system` HelmChart listing that would have shown
this absence was already captured once, in Section 20.2's ingress investigation — it
simply wasn't looked at with storage in mind at the time.

<a id="sec-25-2"></a>
### 25.2 The fix — and why "enable it via RKE2 config" was never actually an option

Because there's no `disable` entry to omit and no RKE2-native flag to flip (unlike
`ingress-controller`, storage has no equivalent toggle), the Ansible/RKE2-config route
named as option 1 in the request isn't just less clean than the alternative — it
doesn't exist. The only real mechanism is deploying a provisioner as a workload,
which is also exactly what this repo's own stated division of labor already calls
for: "gitops/ Everything inside the cluster, via Argo CD app-of-apps" (CLAUDE.md).

Vendored the upstream `rancher/local-path-provisioner` deploy manifest — the same
provisioner k3s uses internally — pinned at `v0.0.37` (latest stable,
github.com/rancher/local-path-provisioner/releases, verified 2026-08-17):

```
gitops/bootstrap/local-path-provisioner/
  local-path-storage.yaml     vendored upstream manifest, one deliberate edit (25.3)
  kustomization.yaml          patch: is-default-class annotation on the StorageClass
gitops/bootstrap/local-path-provisioner-app.yaml   wrapping Application
gitops/bootstrap/kustomization.yaml                (modified) wires the app in
```

**Cluster singleton, so `gitops/bootstrap/`, not `gitops/platform/`** — same reasoning
as `cert-manager.yaml` and `cluster-issuer-app.yaml` (Section 20.3): `StorageClass`,
`ClusterRole`, and `ClusterRoleBinding` are all cluster-scoped, and three
environment-overlay Applications would collide over one set of them.

**No sync-wave, no `ServerSideApply`, no `SkipDryRunOnMissingResource`** — deliberately
absent, not overlooked. Unlike cert-manager/ClusterIssuer (Section 23), nothing this
Application manages is a CRD or depends on one; `Namespace`, `ServiceAccount`,
`Role`/`ClusterRole`, `RoleBinding`/`ClusterRoleBinding`, `Deployment`,
`StorageClass`, `ConfigMap` are all built-in types on every API server, so there is no
ordering race of the kind Sections 23/24 had to solve. And unlike kube-prometheus-
stack (Section 24), this manifest is small — no 262144-byte annotation risk. Adding
either option here would be applying a fix for a failure mode that doesn't exist on
this resource, the same caution already named in Sections 23.3 and 24.

<a id="sec-25-3"></a>
### 25.3 Vendoring discipline: patch what's addressable, edit what isn't, and say which is which

**Step 3 of the request — mark the StorageClass as cluster-default —** done via a
genuine Kustomize structured-field patch (`storageclass.kubernetes.io/is-default-class:
"true"`), not a hand-edit of the vendored file. That's the normal, correct way to
customize a vendored resource: the upstream file stays a clean, diffable copy of its
source, and the customization is visible as its own patch.

**One thing the patch mechanism genuinely cannot reach**, found while vendoring:
upstream's `local-path-config` ConfigMap embeds a full Pod manifest as a YAML string
value (`data.helperPod.yaml`) — opaque text from Kustomize's perspective, not a
structured field, so no patch path can address the `image:` line inside it. That
embedded Pod spec pins `docker.io/library/busybox` with **no tag** (implicit
`latest`), which conflicts with CLAUDE.md rule 2. Fixed by directly editing that one
line in the vendored copy — a deliberate, narrow exception to "never hand-edit a
vendored file," made because the alternative (a giant strategic-merge patch
reproducing the entire string value just to change one substring) would be far less
readable than the edit itself, not more disciplined. Pinned to `busybox:1.38.0`
(latest stable, verified 2026-08-17). The file's own header comment names this as the
one deliberate deviation from upstream, so a future re-vendor pass knows exactly what
to re-apply rather than diffing the whole file blind.

<a id="sec-25-4"></a>
### 25.4 Verification (rendered, every level: the sub-kustomization, the wrapping app, and every root)

- `kubectl kustomize gitops/bootstrap/local-path-provisioner` — exit 0. Parsed with
  `yaml.safe_load_all` (not a text-search) to confirm exactly the 9 expected
  resources render with their correct names, the `StorageClass` carries
  `storageclass.kubernetes.io/is-default-class: "true"`, and the helper-pod image
  line reads `docker.io/library/busybox:1.38.0`.
- `kubectl kustomize gitops/bootstrap` — exit 0; `local-path-provisioner` appears as
  an `Application` alongside the other seven bootstrap resources, fields checked
  directly (`path: gitops/bootstrap/local-path-provisioner`,
  `destination.namespace: local-path-storage`).
- Re-built every other kustomize root in the repo — `gitops/bootstrap/cluster-issuer`
  (still fails as expected: no `kustomization.yaml`, by design, Section 23),
  `gitops/platform`, and all three `gitops/environments/*` — exit 0 on everything
  that's supposed to build via Kustomize.
- Full `REPLACE_ME` sweep across `gitops/` — still zero.

Nothing installed, committed, or pushed. Once this syncs, Harbor's already-defined
PVCs should bind against the new default StorageClass with no Harbor-side change
needed — its `values.yaml` never specified a storage class, so it was always relying
on a cluster default that didn't exist until now.

<a id="sec-25-5"></a>
### 25.5 Flagged, not decided: Prometheus on `emptyDir`

Per the request, this is a decision to surface, not one to make unilaterally.
`kube-prometheus-stack`'s current `values.yaml` sets no persistence, so Prometheus
(and Alertmanager) run on ephemeral storage — all metrics history and alert state is
lost on every pod restart or reschedule, whether or not a StorageClass exists to use.
Adding persistence now is a small, well-scoped `values.yaml` change (a
`prometheus.prometheusSpec.storageSpec` / `alertmanager.alertmanagerSpec.storage`
block referencing the new `local-path` default class) — genuinely optional for what
the assignment is grading, and not implemented in this step.

---

<a id="sec-26"></a>
## 26. Storage fix, split by risk: Argo for the live cluster, documentation for Ansible (2026-08-17)

Follow-up to Section 25. The instruction was to fix both the live cluster
(non-disruptively) and the reproducibility gap (in Ansible). This section is about
*how* the Ansible half was actually done, because the obvious reading of that
instruction — "update the RKE2 disable list" — turned out not to be executable, and
the real alternative turned out to be a bigger decision than a config tweak.

<a id="sec-26-1"></a>
### 26.1 Re-stated plainly: there is nothing to update in RKE2's `disable` list

Section 25.1 already established this, so this is a restatement, not a new finding:
RKE2's `disable` flag has a fixed, exhaustive value set — `rke2-coredns,
rke2-metrics-server, rke2-snapshot-controller, rke2-snapshot-controller-crd,
rke2-snapshot-validation-webhook` (docs.rke2.io/reference/server_config, verified
2026-08-17) — and local-path-storage was never a member of it. "Update the disable
list" cannot be executed literally because the setting doesn't exist. Worth saying
again briefly here because the alternative — quietly inventing a config change that
*looks* like a fix without doing anything — would be worse than the gap it claims to
close: a future reader trusting that comment would believe RKE2 has a storage toggle
it doesn't have.

<a id="sec-26-2"></a>
### 26.2 A real mechanism exists — checked, and deliberately not used

While confirming 26.1, found that RKE2 does have a genuine addon mechanism:
`/var/lib/rancher/rke2/server/manifests/`, documented as applied "both on startup and
when the file is changed on disk," and confirmed to be literally how RKE2 deploys its
own packaged components (coredns, metrics-server, the ingress controller) internally.
Dropping a pinned local-path-provisioner manifest there via Ansible would have been a
genuine RKE2-native answer to "fix in Ansible for reproducibility" — not a
documentation stand-in.

Two things ruled it out for this pass, both surfaced during the check rather than
assumed:

- **A live-cluster risk the docs undersell.** Live-reapply-on-change is documented,
  but open upstream issues — `rancher/rke2#6830` ("Manifest folder behaviour vs
  documentation") and `#5481` ("Static manifests are not automatically reapplied") —
  suggest real-world behavior doesn't always match what's documented. Exactly the
  kind of gap this repo has hit before (Section 12's group_vars bug, Section 21.3's
  undocumented sync-wave). Not something to test against a live 3-node etcd control
  plane holding real workloads, which is precisely the caution the request already
  asked for.
- **A real design decision, not a config tweak.** Using this mechanism on a rebuild
  would mean RKE2 seeds the provisioner at first boot and Argo CD's
  `local-path-provisioner-app.yaml` later adopts the same objects declaratively — a
  coherent pattern (the same "seed once, then hand off to declarative management"
  shape already used for Argo CD's own self-management, Section 20.4/21.2) but a
  bigger architectural choice than "update a setting," and worth the operator's
  explicit call rather than a default I picked silently.

Offered both paths explicitly; the operator chose the smaller, safer one.

<a id="sec-26-3"></a>
### 26.3 What was actually done in Ansible

`ansible/inventory/group_vars/all.yml` gets a documentation-only addition, placed
immediately after the `rke2_ingress_controller` block it's structurally parallel to
(same "here's a default that needs a deliberate decision" shape as that block,
opposite conclusion): a clear, provenance-cited note stating RKE2 packages no storage
component, that this is confirmed against the same `disable` list already cited in
Section 25.1, that the mgmt node's k3s having a StorageClass with zero configuration
is the live corroboration, and that storage is provisioned via
`gitops/bootstrap/local-path-provisioner-app.yaml` — pointing at Sections 25 and 26
for anyone who finds this note while investigating the same symptom Section 25
started from. No functional RKE2 config changed; nothing here affects a real install.

The actual reproducibility guarantee is structural, not a config toggle: any fresh
cluster built from this repo already requires running the Argo bootstrap sequence
(Section 20.5) for *anything* under `gitops/` to exist — Rancher's import, the demo
app, monitoring, all of it. Storage isn't a special case needing its own separate
Ansible-side mechanism; it's one more thing that arrives via the bootstrap sequence
that already has to run. The comment's job is narrower and more honest: make sure the
NEXT person reading `all.yml` doesn't have to re-run this entire investigation to
learn that.

<a id="sec-26-4"></a>
### 26.4 The live cluster — unchanged from Section 25, re-verified

No changes to `gitops/bootstrap/local-path-provisioner/` or
`gitops/bootstrap/local-path-provisioner-app.yaml` this step — Section 25's fix was
already correct. Re-verified rather than assumed, per instruction to "fetch current
docs" and "verify by rendering" again:

- `v0.0.37` reconfirmed as the latest stable `rancher/local-path-provisioner` release
  (github.com/rancher/local-path-provisioner/releases, re-checked 2026-08-17).
- `storageclass.kubernetes.io/is-default-class: "true"` reconfirmed as the correct,
  canonical annotation directly against
  kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/ — this is
  core Kubernetes behavior, not something specific to local-path-provisioner's own
  docs, which is why its README doesn't document it directly.
- Re-rendered `gitops/bootstrap/local-path-provisioner` and confirmed both the
  `StorageClass` annotation and the `busybox:1.38.0` pin (Section 25.3) are still
  exactly as vendored — nothing had drifted.

<a id="sec-26-5"></a>
### 26.5 Verification

- `ansible mgmt -i ansible/inventory/hosts.ini -c local -m debug` — rendered
  `rke2_ingress_controller`, `rke2_cni`, and `rke2_version` from `all.yml` after the
  comment addition; all three resolve unchanged. A pure-comment change shouldn't be
  able to break variable resolution, but per the rule-4 discipline established in
  Section 12, "shouldn't" is checked, not assumed.
- `ansible-playbook playbooks/site.yml --syntax-check` — clean, from the `ansible/`
  basedir.
- `kubectl kustomize` on every kustomize root in the repo (`gitops/bootstrap`,
  `gitops/bootstrap/local-path-provisioner`, `gitops/platform`, and all three
  `gitops/environments/*`) — exit 0 on all six.
- Full `REPLACE_ME` sweep across `gitops/` — still zero.

Nothing installed, committed, or pushed. Prometheus's `emptyDir` persistence
question (Section 25.5) is unchanged and still open — explicitly the operator's call,
not addressed in this step either.

---

<a id="sec-27"></a>
## 27. The storage fix wasn't actually ordered relative to its consumers (2026-08-17)

A fair challenge to Section 25/26's fix: those sections established that a rebuild
*eventually* gets storage via the Argo bootstrap sequence, but never established that
it gets it *before* Harbor and kube-prometheus-stack request PVCs. Those are
different claims, and only the second one actually prevents reproducing the Pending-
PVC symptom Section 25 investigated.

<a id="sec-27-1"></a>
### 27.1 What was actually true before this section

```
project.yaml                    wave -1
argocd.yaml                     wave 0
cert-manager.yaml                wave 0
local-path-provisioner-app.yaml  (unannotated -> implicit wave 0)
cluster-issuer-app.yaml          wave 1
root-dev.yaml                    (unannotated -> implicit wave 0)
root-staging.yaml                (unannotated -> implicit wave 0)
root-prod.yaml                   (unannotated -> implicit wave 0)
```

`local-path-provisioner-app.yaml` and `root-dev/staging/prod.yaml` were **all**
implicitly wave 0 — the same wave. Same wave means no ordering guarantee: on a
from-scratch bootstrap, nothing stopped `routa-dev` from being created (and, in turn,
syncing Harbor, whose Helm chart requests a PVC) before the storage provisioner's
Deployment was actually Ready. This was a real, live gap, not a theoretical one — it
would have reproduced Section 25's exact symptom on the very rebuild this repo's
storage fix was supposed to prevent.

<a id="sec-27-2"></a>
### 27.2 Why the fix belongs on the root apps, not on Harbor or kube-prometheus-stack

Worth stating explicitly, because it's the non-obvious part: `argocd.argoproj.io/
sync-wave` orders resources **within one Application's own sync**, not across the
app-of-apps hierarchy. `harbor` and `kube-prometheus-stack` are synced by
`routa-dev`'s (or `-staging`'s / `-prod`'s) own reconcile — a completely separate sync
operation from `bootstrap`'s. A wave annotation on `harbor/application.yaml` would
only order Harbor relative to *its own siblings* (kube-prometheus-stack, demo-app)
within `routa-dev`'s sync; it has no relationship whatsoever to
`local-path-provisioner-app.yaml`, which lives in a different Application's resource
list entirely. Annotating Harbor directly would have looked like a fix and done
nothing.

The only place storage and the root apps are siblings in the *same* sync is
`bootstrap`'s own resource list — so that's the only place a wave annotation between
them can mean anything.

<a id="sec-27-3"></a>
### 27.3 The fix

`local-path-provisioner-app.yaml`: made its wave **explicit** (`"0"`, same value as
the previous implicit default) — consistent with this repo's standing preference for
explicit over implicit-and-relied-upon (the `ingress-controller` pin in Section 20.2,
the `hostname` field in Section 21, both made the same call for the same reason: a
correct default is not the same guarantee as a value nobody can accidentally change
out from under you).

`root-dev.yaml`, `root-staging.yaml`, `root-prod.yaml`: moved to wave **`"2"`** —
strictly after `local-path-provisioner-app.yaml` (wave 0) and, deliberately, after
`cluster-issuer-app.yaml` (wave 1) too. Nothing in `platform/` currently needs
`cluster-issuer` (Harbor's TLS is still disabled — Section 22.2), so waiting for it is
more conservative than strictly required. Chose the conservative version anyway:
"every environment's platform apps wait for all of bootstrap's day-0 infrastructure"
is a simpler, more robust invariant to reason about and maintain than hand-tuning a
separate wave number per actual dependency edge, and the extra wait is negligible —
`cluster-issuer`'s own Application becomes Healthy quickly once cert-manager is up,
since it manages only two small `ClusterIssuer` objects.

`root-prod.yaml` keeps its own `syncPolicy` with no `automated` block (manual-sync
promotion gate, Section 11) — noted explicitly in that file that the two policies
don't conflict: the wave annotation governs when *bootstrap* creates the `routa-prod`
Application object; the missing `automated` block governs whether *routa-prod itself*,
once created, syncs on its own. Independent concerns, both honored.

<a id="sec-27-4"></a>
### 27.4 Verification (rendered — the actual wave numbers, not the annotations in isolation)

Rendered `gitops/bootstrap` and printed every resource's resolved
`argocd.argoproj.io/sync-wave` value, sorted:

```
wave -1  AppProject   routa-platform
wave  0  Application  argocd
wave  0  Application  cert-manager
wave  0  Application  local-path-provisioner
wave  1  Application  cluster-issuer
wave  2  Application  routa-dev
wave  2  Application  routa-prod
wave  2  Application  routa-staging
```

Storage sorts strictly before every environment root, confirmed from the rendered
output rather than from reading the annotations file-by-file and trusting they'd
compose correctly. Re-built every kustomize root in the repo — all still exit 0
(`gitops/bootstrap/cluster-issuer` still fails as expected, no `kustomization.yaml`
there by design, Section 23). Confirmed `harbor/application.yaml` and
`kube-prometheus-stack/application.yaml` remain deliberately unannotated — per 27.2,
a wave number there would be meaningless noise, not a fix. Full `REPLACE_ME` sweep
across `gitops/` still zero.

Nothing installed, committed, or pushed.

---

<a id="sec-28"></a>
## 28. Persistent storage for Prometheus and Alertmanager (2026-08-17)

Flagged as open in Section 25.5, decided now that a default StorageClass exists.
Prometheus and Alertmanager were running on ephemeral `emptyDir` — all metrics
history and alert state lost on every pod restart or reschedule, independent of
whether a StorageClass existed.

<a id="sec-28-1"></a>
### 28.1 The asymmetry the request warned about — confirmed real

Fetched the pinned chart's own `values.yaml` directly at the exact tag
(`kube-prometheus-stack-88.3.0`, not a newer or older version, not a summary) rather
than assuming a generic Prometheus Operator example applies unchanged. It doesn't
nest the same way for both components:

```
prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec...   ("storageSpec")
alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec...   ("storage" — no "Spec")
```

Both confirmed at the exact line numbers in the fetched file (`storageSpec: {}` under
`prometheus.prometheusSpec`; `storage: {}` under `alertmanager.alertmanagerSpec`,
elsewhere in the same file). Also confirmed `alertmanager.enabled: true` is this
chart's own default — Alertmanager is genuinely deployed by our existing values
(nothing disables it), so its storage config isn't a no-op.

<a id="sec-28-2"></a>
### 28.2 A second layer of the same asymmetry, found only by rendering — not a problem, but worth recording

Templated the actual pinned chart (`helm template` against the pulled
`kube-prometheus-stack-88.3.0.tgz`, not a mental model of what it should produce) and
inspected the real output. The rendered `Prometheus` and `Alertmanager` custom
resources — the objects the Prometheus Operator actually reads to create the real
StatefulSet and PVC at runtime — both end up with the storage config under
**`spec.storage`**, identically, regardless of which values.yaml key fed them:

```
Prometheus/...    spec.storage.volumeClaimTemplate.spec = {storageClassName: local-path, accessModes: [ReadWriteOnce], resources.requests.storage: 10Gi}
Alertmanager/...  spec.storage.volumeClaimTemplate.spec = {storageClassName: local-path, accessModes: [ReadWriteOnce], resources.requests.storage: 2Gi}
```

So the `storageSpec` vs `storage` naming asymmetry exists only at the Helm
values-input layer — the chart's own naming choice for how you configure it, not a
difference in what gets configured. Both map onto the same underlying Prometheus
Operator CRD field (`spec.storage`) once rendered. Worth recording specifically
because it means the values.yaml-level asymmetry (28.1) was the right and only thing
to get right — there wasn't a second, deeper inconsistency lurking in the actual CRD
schema underneath it that a values-only review would have missed.

<a id="sec-28-3"></a>
### 28.3 Design choices in the values

- **`storageClassName: local-path` set explicitly**, not left unset to fall back to
  the cluster default (which local-path already is). Same reasoning as the explicit
  `ingress-controller` pin (Section 20.2) and the explicit sync-wave values
  (Section 27): a correct default is not the same guarantee as a value nobody can
  change out from under this chart, and a reader of this file shouldn't need to
  already know local-path is cluster-default to understand what storage this uses.
- **`accessModes: ["ReadWriteOnce"]`** — not copied from the chart's commented-out
  example by habit; it's what local-path-provisioner actually supports. It's a
  hostPath-based, node-local provisioner (Section 25), so `ReadWriteMany` was never
  on the table here regardless of what the chart's own example shows.
- **Sizes**: Prometheus 10Gi, Alertmanager 2Gi — modest and deliberate for a demo
  cluster on 100GB node disks, not a capacity-planned figure for a real workload.

<a id="sec-28-4"></a>
### 28.4 WaitForFirstConsumer — naming why a `Pending` PVC here is not Section 25 again

`local-path`'s `volumeBindingMode: WaitForFirstConsumer` (set in
`gitops/bootstrap/local-path-provisioner/local-path-storage.yaml`, upstream default,
unchanged) means these PVCs stay `Pending` until a Prometheus/Alertmanager pod
actually schedules onto a node — expected, correct behavior for this binding mode,
not a regression of Section 25's bug. Worth stating the distinction plainly since
both look identical at a glance (`Pending` PVC): Section 25's failure was PVCs
`Pending` because no StorageClass existed to bind against **at all**; this is PVCs
`Pending` for a few seconds because binding is deliberately deferred until pod
placement is known. Noted directly in `values.yaml`'s own comment so a future reader
seeing `Pending` here doesn't reflexively reopen Section 25's investigation.

<a id="sec-28-5"></a>
### 28.5 Verification

- `yaml.safe_load` on `values.yaml` — confirmed the exact structure matches the
  chart's schema field-for-field.
- **Rendered the real chart, not just the source YAML**: `helm pull
  prometheus-community/kube-prometheus-stack --version 88.3.0`, then `helm template
  ... -f gitops/platform/kube-prometheus-stack/values.yaml` — clean render, no
  errors. Parsed the output and confirmed the `Prometheus` and `Alertmanager` CRs
  carry the exact intended `storageClassName`, `accessModes`, and size (28.2's
  table). This is the strongest verification available short of a live cluster: it
  proves the values actually flow through the chart's templates into the object the
  Operator will read, not just that the input YAML is well-formed.
- Re-built `gitops/platform` and all three `gitops/environments/*` overlays — exit 0
  on all four (sanity check; `values.yaml` isn't itself a Kustomize resource, so
  this mainly confirms nothing else was disturbed).
- Full `REPLACE_ME` sweep across `gitops/` — still zero.

Nothing installed, committed, or pushed.

---

<a id="sec-29"></a>
## 29. Prometheus Operator running but not reconciling — stale webhook certs (2026-08-18)

After the kube-prometheus-stack CRDs applied in two batches (02:42, then 03:42 once
the `ServerSideApply` fix from Section 24 landed), the `Prometheus` and
`Alertmanager` CRs existed with `DESIRED 1` but blank `READY`/`RECONCILED`/
`AVAILABLE` — no StatefulSets, no PVCs, `Events: <none>` on the CRs. The operator pod
itself was `Running`.

**The diagnostic lesson, stated plainly because it's the reusable part:** a `Running`
operator pod is not evidence it is reconciling anything. `Events: <none>` on the CR
is what actually distinguished "operator hasn't attempted this yet" from "operator
tried and failed" — a failed reconcile would have left an error Event; none existed,
so nothing had been attempted at all.

**Root cause:** operator logs showed `tls: bad certificate` handshake errors at
exactly `03:42:13` — matching the second CRD batch precisely — pointing at stale
admission-webhook certs left over from before the CRDs re-applied.

**Fix:** restarted the operator Deployment. Both StatefulSets were created
immediately after, and the PVCs from Section 28 bound successfully.

Nothing installed, committed, or pushed as part of logging this.

---

<a id="sec-30"></a>
## 30. TLS enabled on Harbor (2026-08-18)

Harbor was serving plain HTTP on a public IP — a real security gap, and a blocker
for `docker push`/`docker login` (Docker refuses to talk to an insecure registry
without `--insecure-registry`, which is not something to rely on for task 3). Fixed
using the same cert-manager + Traefik pattern already proven for Rancher and Argo CD.

<a id="sec-30-1"></a>
### 30.1 Traced the actual chart templates, not just the values.yaml comments

Pulled the pinned chart (`harbor@1.19.2`) and read `templates/ingress/ingress.yaml`
and the `harbor.tlsCoreSecretForIngress` helper in `templates/_helpers.tpl` directly,
because `expose.tls.certSource` has a real trap in it that a values.yaml skim would
miss:

- `certSource: "auto"` does **not** mean "let cert-manager handle it." It means
  Harbor's own Helm-hook Job generates a self-signed certificate, and the Ingress's
  `tls.secretName` becomes the Ingress object's own name — a secret cert-manager
  would then be fighting the same hook Job over, silently.
- `certSource: "secret"` is the mode that means "I am supplying this externally."
  Confirmed directly in the helper: under this mode, `tls.secretName` becomes
  exactly `expose.tls.secret.secretName` — the name cert-manager's ingress-shim will
  create and manage via the `cert-manager.io/cluster-issuer` annotation.
- `certSource: "none"` skips the `tls.secretName` field entirely — also wrong here.

Separately, `expose.tls.enabled` (not `certSource`) is what actually gates whether
the Ingress template emits a `tls:` stanza at all — confirmed directly:
`{{- if $tls.enabled }} tls: ... {{- end }}` in `templates/ingress/ingress.yaml`.
Both fields have to be set correctly together: `enabled: true` with
`certSource: auto` would have silently served Harbor's own self-signed certificate
instead of a real Let's Encrypt one — exactly the "wrong mode, wrong silent result"
failure mode this instruction asked to guard against, and exactly the kind of thing
that would not show up as an error, only as a browser warning nobody was expecting.

<a id="sec-30-2"></a>
### 30.2 The values

```
expose.tls.enabled: true
expose.tls.certSource: secret
expose.tls.secret.secretName: harbor-ingress-tls
expose.ingress.hosts.core: harbor.95.133.252.180.sslip.io   (already set, Section 22.2 fix)
expose.ingress.annotations["cert-manager.io/cluster-issuer"]: letsencrypt-production
```

`expose.ingress.annotations` was set to only the one new key, not a full copy of the
chart's default annotation map — Helm deep-merges nested maps between chart defaults
and override values, so this preserves the chart's own default
`ingress.kubernetes.io/ssl-redirect` and `proxy-body-size` annotations already live
on this Ingress rather than dropping them. Confirmed by rendering (30.3), not assumed
from general Helm knowledge alone.

<a id="sec-30-3"></a>
### 30.3 `letsencrypt-production` used directly — a deliberate exception to staging-first, stated plainly

Every earlier cert on this cluster (Rancher, Argo CD) went staging-first per Section
18's discipline, proving the DNS → Traefik → cert-manager → HTTP-01 path before
spending a production issuance. That path is now proven **twice** on
`95.133.252.180`. Going straight to `letsencrypt-production` for Harbor is an
informed exception to that discipline, not a reversion to skipping it — confirmed
both `ClusterIssuer`s are `READY=True` and have been for over two hours before making
this call, rather than assuming they still are.

<a id="sec-30-4"></a>
### 30.4 Section 18 lesson — checked, confirmed not applicable, said so anyway

Per instruction, explicitly checked rather than waved away: `kubectl get secrets -n
harbor` showed no existing TLS secret for this hostname before this change — nothing
stale to collide with, so cert-manager's "won't re-issue over a valid existing
secret" behavior (Section 18) genuinely does not apply here. Recorded for the future
anyway: if `harbor-ingress-tls` is ever left behind by a failed attempt and this
hostname is reused, that secret would need deleting to force re-issuance, exactly as
it did for Rancher.

<a id="sec-30-5"></a>
### 30.5 Verification — rendered against the real pinned chart, not just parsed

`helm template` against the actual pulled `harbor-1.19.2.tgz` with
`--show-only templates/ingress/ingress.yaml`, confirming the real, fully-templated
object rather than trusting the values file alone:

```yaml
annotations:
  cert-manager.io/cluster-issuer: letsencrypt-production
  ingress.kubernetes.io/proxy-body-size: "0"
  ingress.kubernetes.io/ssl-redirect: "true"
  nginx.ingress.kubernetes.io/proxy-body-size: "0"
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - secretName: harbor-ingress-tls
    hosts:
    - harbor.95.133.252.180.sslip.io
  rules:
  - ...
    host: harbor.95.133.252.180.sslip.io
```

Confirms, field by field: the merge in 30.2 worked (cert-manager annotation added,
chart defaults preserved); `certSource: secret` produced exactly the intended
`secretName`; host and TLS host match. Re-built every kustomize root in the repo —
all still exit 0. Full `REPLACE_ME` sweep across `gitops/` — still zero.

Nothing installed, committed, or pushed.

---

<a id="sec-31"></a>
## 31. demo-app image: arm64 build, amd64 nodes (2026-08-18)

After pushing `harbor.95.133.252.180.sslip.io/routa/demo-app:v1`, the Deployment
failed with `ImagePullBackOff` / `no match for platform in manifest: not found`.

**Not a registry, TLS, or auth problem** — all of that worked: pull was anonymous
against the public `routa` project exactly as designed (Section 31 title aside, no
`imagePullSecret` needed, per Section 30's own note), TLS from Section 30 validated
fine, Harbor served the manifest without complaint. The manifest just had no variant
for the platform being pulled.

**Root cause:** built on Apple Silicon (arm64) and pushed as-is; the three RKE2 nodes
are amd64 (`CPU.16V.64G`, Section 14). A single-arch arm64 image has nothing for an
amd64 kubelet to pull.

**Fix:** `docker build --platform linux/amd64 -t harbor.95.133.252.180.sslip.io/routa/demo-app:v1 .`, re-push, same tag. Pod scheduled and pulled cleanly after.

Nothing else about the Harbor/TLS/GitOps path needed touching.

---

<a id="sec-32"></a>
## 32. Argo CD SSO via Dex + GitHub OAuth (2026-08-18)

Plan and manifests only in this section — the Secret creation is imperative and run
by the operator directly, never through Git. Nothing pushed or committed as part of
this entry.

<a id="sec-32-1"></a>
### 32.1 Callback path — verified against current docs, matches what's already registered

`/api/dex/callback` confirmed against
`argo-cd.readthedocs.io/en/stable/operator-manual/user-management/` as the fixed
path Argo CD always uses for OAuth2 connectors — there is no `redirectURI` field to
configure; Argo derives it from `configs.cm.url` (Section 20.6) automatically. The
GitHub OAuth App's registered redirect URI,
`https://argocd.95.133.252.180.sslip.io/api/dex/callback`, is already correct. No
change needed on the GitHub side.

<a id="sec-32-2"></a>
### 32.2 Config location — traced in the pinned chart, not assumed

Two candidate locations existed in the chart's values schema, and only one is
correct: a top-level `dex:` block (chart line 1142) and `configs.cm` (chart line
191). Read both directly. The top-level `dex:` block is Dex-server *runtime*
settings only — `enabled`, `resources`, `metrics` — and has no field for connector
configuration at all. The actual Dex connector config lives under `configs.cm`, as
the literal dotted key `"dex.config"` (chart's own commented-out example, lines
227-238) — the same top-level map this repo's `configs.cm.url` already lives in
(Section 21). Confirmed by rendering the real `argocd-cm` ConfigMap against the
pinned chart + our values and finding `dex.config` present with exactly the intended
content, byte for byte.

<a id="sec-32-3"></a>
### 32.3 `useLoginAsID` — the non-obvious flag that makes username-based RBAC possible at all

Without an org/team to scope the GitHub connector against, the natural read is "just
match my GitHub username in RBAC." That silently doesn't work by default: traced
Dex's own source (`connector/github/github.go`, dexidp/dex) and confirmed the `sub`
claim Argo's RBAC evaluates is GitHub's **internal numeric user ID** unless
`useLoginAsID: true` is set, which makes `identity.UserID = user.Login` — the actual
handle. Separately confirmed against
`argo-cd.readthedocs.io/en/stable/operator-manual/rbac/` that `sub` is always
examined for `g,` subject matching "in addition to" whatever `scopes` configures, so
this flag is what makes `g, AmirMoshfeghi, role:admin` resolve to anything at all —
without it, that line would silently never match, and the more common real-world
pattern (matching on `email` instead) was deliberately not used here since it would
put a personal email address in a policy.csv line in a public repository, when the
GitHub username is already public in this repo's own remote URL.

<a id="sec-32-4"></a>
### 32.4 No `orgs:` — a real access consequence, not a missing detail

No org/team exists to scope the connector against, so `orgs:` is omitted entirely.
**Consequence, stated plainly:** any GitHub account can complete the OAuth login —
authentication is open to the internet, not gated to a specific organization. This
is exactly why `configs.rbac.policy.default: role:readonly` is not left empty:
authentication succeeding must not by itself imply any access. `role:readonly` is
one of Argo CD's built-in roles (no `p,` lines needed to define it) and grants
view-only access; only the one `g,` binding below grants anything more.

<a id="sec-32-5"></a>
### 32.5 The RBAC mapping — proposed, not yet confirmed

```
policy.default: role:readonly
policy.csv: |
  g, AmirMoshfeghi, role:admin
```

`AmirMoshfeghi` is inferred from this repo's own `repoURL`
(`gitops/bootstrap/argocd.yaml`), **not independently confirmed as a real GitHub
login via any API call**. Presented for the operator's explicit confirmation before
applying, per instruction. Worth noting the failure mode if it's wrong: a mistyped
username here fails safe, not open — nobody gets `role:admin`, everyone (including
the operator) is stuck at `role:readonly` until corrected. Not a lockout risk beyond
"go fix the policy.csv line and re-sync," since Argo's own local `admin` account
(Section 20.6) remains a separate, always-available fallback login independent of
SSO entirely.

<a id="sec-32-6"></a>
### 32.6 The Secret — imperative, never through Git

```bash
kubectl create secret generic argocd-github-oauth \
  --namespace argocd \
  --from-literal=dex.github.clientSecret="$ARGOCD_GITHUB_CLIENT_SECRET"

kubectl label secret argocd-github-oauth \
  --namespace argocd \
  app.kubernetes.io/part-of=argocd
```

Two commands, not one: `kubectl create secret generic` has no built-in `--labels`
flag in the kubectl versions this was verified against, so the label is applied as a
separate step rather than assumed available. The label is not cosmetic — Argo CD
only honors `$<secret-name>:<key>` references (confirmed against
`argo-cd.readthedocs.io/en/stable/operator-manual/user-management/`) for Secrets
carrying `app.kubernetes.io/part-of: argocd`; without it, the reference in
`dex.config` resolves to nothing and Dex fails to start with a config error, not a
silent skip. Deliberately a **separate** Secret (`argocd-github-oauth`), not an
addition to the chart's own `argocd-secret` — that Secret is managed by Argo CD
itself (session signing key, admin password hash) and this avoids hand-editing it.

<a id="sec-32-7"></a>
### 32.7 Verification

- `helm template` against the actual pulled `argo-cd-10.4.0.tgz` chart, not just
  parsed values — rendered both `templates/argocd-configs/argocd-cm.yaml` and
  `templates/argocd-configs/argocd-rbac-cm.yaml` and confirmed `dex.config`,
  `policy.default`, and `policy.csv` all appear exactly as intended in the real
  ConfigMaps Argo CD will actually read.
- Re-checked live cluster state before writing anything: Argo's own Ingress still
  carries `cert-manager.io/cluster-issuer: letsencrypt-staging`, matching the
  committed file — no undocumented drift to account for.
- Full repo sweep for `clientSecret` — the only two matches are the reference syntax
  and its explanatory comment; no secret *value* appears anywhere.
- Re-built every kustomize root in the repo — all still exit 0. Full `REPLACE_ME`
  sweep — still zero.

Nothing installed, committed, or pushed. The Secret command above is for the
operator to run directly, outside this session's write path, per instruction.

---

<a id="sec-33"></a>
## 33. SSO implemented on Rancher and Argo CD (2026-08-18)

Section 32 was the Argo CD SSO plan; this records what actually got built and
applied for both Rancher and Argo CD, and the one live snag hit doing it.

<a id="sec-33-1"></a>
### 33.1 Argo CD — GitHub OAuth via Dex

Built per Section 32's plan, applied as planned. The two-candidate config-location
question resolved to `configs.cm`'s `"dex.config"` key, not the chart's top-level
`dex:` block (Dex-server runtime settings only, no connector field). `useLoginAsID:
true` confirmed required, not decorative: without it, Dex's `sub` claim is GitHub's
numeric user ID, not the username, so the RBAC binding would have silently never
matched — no error, just permanent `role:readonly` for an admin who'd assume the
binding was working. Client secret referenced via
`$argocd-github-oauth:dex.github.clientSecret`, a separate Secret from the
chart-managed `argocd-secret`, labeled `app.kubernetes.io/part-of=argocd` — Argo only
honors `$secret:key` syntax for Secrets carrying that label; missing it is a silent
no-op, not an error. RBAC: `policy.default: role:readonly` (authentication alone
never implies access) plus one explicit `g, AmirMoshfeghi, role:admin` binding.

<a id="sec-33-2"></a>
### 33.2 Rancher — native GitHub auth provider

Separate GitHub OAuth App from Argo CD's, with its own callback requirement — Rancher
and Dex don't share one. An initial guess at the callback path assumed a
`/verify-auth` suffix, carried over from a different Rancher version; wrong.
Rancher's own auth-provider setup screen displays the actual expected callback URL
directly — `https://rancher.95.133.252.175.sslip.io`, no path suffix at all — so the
fix was reading what Rancher itself showed rather than trusting a remembered pattern.

One further snag on first login: GitHub returned "redirect_uri is not associated
with this application." Traced to the registered callback URL not being
byte-for-byte identical to what Rancher actually sent (a scheme/trailing-slash-level
mismatch, not a wrong host). Fixed by re-entering the callback URL in the GitHub
OAuth App exactly as Rancher's own UI displayed it, rather than retyping it from
memory.

Both are live: GitHub login works end-to-end on Rancher
(`https://rancher.95.133.252.175.sslip.io`) and Argo CD
(`https://argocd.95.133.252.180.sslip.io`).

---

<a id="sec-34"></a>
## 34. Argo CD flipped to Let's Encrypt production (2026-08-18)

Same class of issue as Section 18 (Rancher) and Section 30 (Harbor): Argo CD's
Ingress was still serving the Let's Encrypt staging cert, confirmed via `openssl`
(`issuer CN=(STAGING) Ersatz Emmer YR2`).

**The key, confirmed rather than assumed to be the same shape as Rancher/Harbor**:
`server.ingress.annotations["cert-manager.io/cluster-issuer"]` in
`gitops/bootstrap/argocd-values.yaml` — the same annotation-driven mechanism as
Harbor (Section 30), not a chart-native `letsEncrypt.environment` toggle the way
Rancher's chart has one. Flipped `letsencrypt-staging` → `letsencrypt-production`.

**Secret name confirmed two ways, not one**: read from the file's own existing
comment (`argocd-server-tls`, originally documented when `server.ingress.tls: true`
was first set — Section 21.2) and cross-checked live —
`kubectl get secret -n argocd` shows `argocd-server-tls` exists, 10h old, matching.

**§18 applies here too, exactly as flagged.** Changing the annotation alone does not
force re-issuance — cert-manager will not re-issue while a valid cert already sits
in `argocd-server-tls`. **Not deleted as part of this change** — this is a values
edit only, per instruction. The operator's next step, after this pushes and Argo
re-syncs:

```bash
kubectl delete secret argocd-server-tls -n argocd
```

That forces a fresh `CertificateRequest` against `letsencrypt-production`. Until
that secret is deleted, Argo CD will keep serving the staging cert indefinitely
despite the Issuer reference already having changed — the same trap, not a new one.

**Verification**: `helm template` against the actual pulled `argo-cd-10.4.0.tgz`
chart with the updated values, `--show-only templates/argocd-server/ingress.yaml` —
confirmed both fields in the real rendered object:
`cert-manager.io/cluster-issuer: "letsencrypt-production"` and
`tls[0].secretName: argocd-server-tls` (unchanged, as expected — only the issuer
reference changes, not the secret name). Re-built every kustomize root in the
repo — all still exit 0. Full `REPLACE_ME` sweep — still zero.

Nothing pushed as part of this change.

---

<a id="sec-35"></a>
## 35. `project.yaml` sourceRepos tightened from `"*"` (2026-08-18)

The TODO flagged since Section 22.3 and never circled back to (confirmed still open
during last night's pre-submission sweep). Closed now: `sourceRepos` on the
`routa-platform` AppProject tightened from `["*"]` to the exact list this platform
uses.

**Grepped, not compiled from memory.** Every `repoURL:` field across `gitops/`,
structurally parsed from each `Application` object's `spec.source`/`spec.sources`
(not a text grep, which produces false positives — see the verification note below)
gives exactly five distinct sources:

```
https://github.com/AmirMoshfeghi/routa-platform      # this repo — root apps, $values refs
https://argoproj.github.io/argo-helm                  # argo-cd chart
quay.io/jetstack/charts                                # cert-manager chart, OCI
https://prometheus-community.github.io/helm-charts    # kube-prometheus-stack chart
https://helm.goharbor.io                               # harbor chart
```

**Two sources deliberately NOT added, despite being reasonable to expect:** Traefik's
chart repo and Rancher's chart repo. Grepped for both — neither appears anywhere
under `gitops/`. Traefik is deployed via RKE2's own bundled `HelmChart` CR on
`routa-cp-1..3` (Section 20.2) and via Ansible/Helm CLI on the mgmt node (Section
17.3); Rancher is installed entirely via Ansible on the mgmt node's k3s (Section 17).
Neither goes through Argo CD, so neither belongs in an Argo `AppProject`'s access
list — adding them would have been scope creep past what's actually gated here, not
caution.

**Verification, and why the naive approach was wrong.** A plain text `grep -n
"repoURL:"` across `gitops/` produces a false positive: this very entry's own
provenance comment in `project.yaml` contains the literal text `` `repoURL:` `` in
markdown backticks, which a regex happily matches and mis-extracts as a value. Redid
the check properly — `yaml.safe_load_all` every file under `gitops/`, filter to
`kind: Application`, pull `spec.source.repoURL` or `spec.sources[].repoURL`
structurally — and cross-referenced the resulting set against the new allowlist:
zero used-but-not-allowed, zero allowed-but-unused. Exact match. Re-built every
kustomize root in the repo (`bootstrap`, `bootstrap/local-path-provisioner`,
`platform`, all three `environments/*`) — all still exit 0. Full `REPLACE_ME`
sweep across `gitops/` — still zero.

No live Application would be rejected by this tightening — confirmed by the exact
cross-reference above, not by inspection.

Nothing pushed as part of this change.

---

<a id="sec-36"></a>
## 36. Kueue (bonus task) added (2026-08-18)

The last unstarted item on the optional list (Section 1.1/1.2) — the brief calls it
out specifically because Verda documents Kueue for their own Instant Clusters, so
this is a real Verda-operated capability, not generic filler. Built, not yet pushed.

<a id="sec-36-1"></a>
### 36.1 Version, verified two ways — and a real doc-vs-tag mismatch caught by that

`kueue.sigs.k8s.io/docs/getting-started/installation/` names **v0.19.1** as current
stable and gives the Helm OCI install command. Cross-checked against
`github.com/kubernetes-sigs/kueue/releases`: v0.19.1 (2026-08-12) is the latest
non-prerelease tag, ahead of v0.19.0 and v0.18.5. Then cross-checked a third way —
pulled `charts/kueue/Chart.yaml` at the actual `v0.19.1` git tag: `version: 0.19.1`,
`appVersion: "v0.19.1"`, chart and app release move together for this project.

**The doc-vs-tag mismatch, exactly the kind CLAUDE.md rule 1 exists to catch:** the
installation page's own prose/rendered examples show `kueue.x-k8s.io/v1beta1` for
ResourceFlavor/ClusterQueue/LocalQueue in places. Rather than trust that, fetched the
actual example manifest shipped in the pinned tag directly —
`site/static/examples/admin/single-clusterqueue-setup.yaml` at `v0.19.1` — via `curl`
(not the summarizing fetch tool, deliberately, after the fetch tool's own summary of
a different page had already misreported the chart's install command in one attempt
during this same investigation). That file uses `kueue.x-k8s.io/v1beta2`,
consistently with what Verda's own Instant Clusters Kueue doc
(`docs.verda.com/clusters/instant-clusters/kubernetes/queueing/`, already listed in
Section 5) references. **v1beta2 used throughout** — the doc page's prose was stale
relative to its own pinned tag's files, not the other way around.

<a id="sec-36-2"></a>
### 36.2 Architecture: cluster singleton, same shape as cert-manager/ClusterIssuer

Kueue's CRDs (`ClusterQueue`, `ResourceFlavor`, `Workload`, `LocalQueue`, etc.) are
cluster-scoped and there is exactly one `kueue-system` controller for the whole
cluster — the same reasoning already established for cert-manager and the
local-path-provisioner (Section 20.3): three environment-overlay Applications would
collide over one set of objects. So the controller install and the shared
ResourceFlavor/ClusterQueue live in `gitops/bootstrap/`, not `gitops/platform/`.

Split into **two** Applications, replaying the exact structural fix from Section 23
(cert-manager/ClusterIssuer) rather than rediscovering it by hitting the same
failure live:

- `gitops/bootstrap/kueue.yaml` (wave "0") — the Helm OCI install
  (`registry.k8s.io/kueue/charts/kueue` @ `0.19.1`, no `oci://` prefix in `repoURL`,
  same convention as `cert-manager.yaml`'s `quay.io/jetstack/charts`). No helm
  parameters — pulled `values.yaml` at the tag and confirmed the relevant defaults
  already fit: `enableCertManager: false` (Kueue manages its own webhook cert
  internally — no dependency on this cluster's cert-manager install, unlike
  `cluster-issuer`), `integrations.frameworks` already includes `"batch/job"`, the
  only workload type the demo needs.
- `gitops/bootstrap/kueue-config-app.yaml` (wave "1") + `gitops/bootstrap/kueue-config/`
  — the shared `ResourceFlavor`/`ClusterQueue`, as their own Application with
  `SkipDryRunOnMissingResource=true`, for the identical reason `cluster-issuer-app.yaml`
  needs it: these objects depend on a CRD a *sibling* Application installs, and Argo's
  comparison pass for bootstrap's own sync would trip over "no matches for kind
  ClusterQueue" before wave-gating ever got a chance to help, if these were bundled
  into bootstrap's own resource list instead.

`ServerSideApply=true` added to `kueue.yaml` proactively, not after hitting the
failure live this time (unlike cert-manager's first encounter, Section 21.4/24, or
kube-prometheus-stack's, Section 24) — pulled the chart's actual CRD templates at the
`v0.19.1` tag and measured them directly: `kueue.x-k8s.io_workloads.yaml` is 1.3 MB,
`kueue.x-k8s.io_clusterqueues.yaml` is 88 KB, both well over the 262144-byte
last-applied-configuration limit client-side apply would try to store. Applying the
already-learned pattern ahead of the failure, rather than waiting to rediscover it, is
the point of writing these decisions down in the first place.

<a id="sec-36-3"></a>
### 36.3 The demo: sized to actually prove queueing, not just installation

`gitops/platform/kueue-demo/` (namespaced — `kueue-demo` — so it follows the
`gitops/platform/` convention, instantiated via `platform/kustomization.yaml` like
`demo-app/`) holds one `LocalQueue` bound to `cluster-queue`, plus two identical
`Job`s (`kueue-demo-job-a`, `kueue-demo-job-b`) each requesting 2 CPU total
(`parallelism: 2` x `1` CPU/pod — image and command copied verbatim from
`kueue.sigs.k8s.io/docs/tasks/run/jobs/`'s own sample,
`registry.k8s.io/e2e-test-images/agnhost:2.53`, `sleep 60`).

**Quota chosen deliberately small**: `cluster-queue`'s `cpu` `nominalQuota` is `"2"`,
against ~48 allocatable vCPU across the three `CPU.16V.64G` nodes (Section on the
`CPU.16V.64G` fallback) — a quota sized to "whatever fits" would let both demo Jobs
admit immediately and demonstrate nothing. At `cpu: "2"`, `job-a` fits exactly and
admits immediately; `job-a` + `job-b` together demand 4 CPU, so `job-b` stays
suspended (`QuotaReserved=False`) until `job-a` completes (~60s) and releases its
quota — real, observable FIFO admission, checkable via `kubectl get workloads -n
kueue-demo`. `memory` quota (`2Gi`) set well above what the demo needs (2 jobs x
512Mi = 1Gi) so CPU is unambiguously the constraint being demonstrated, not an
interaction between two limits.

**Single shared instance, not one per environment** — considered replicating this
the way `demo-app`/`harbor`/`kube-prometheus-stack` are (per-environment destination-
namespace patches in `environments/{staging,prod}/kustomization.yaml`) and rejected
it: `cluster-queue` is a genuine cluster singleton (36.2), so three `LocalQueue`s
would just be three names bound to the one shared quota, not three independent
demonstrations. One instance, in its own `kueue-demo` namespace, is enough to prove
the mechanism.

`ttlSecondsAfterFinished: 300` on both Jobs so completed runs clean themselves up
rather than sitting `Completed` forever, and so a future edit to these Jobs' specs
doesn't hit "field is immutable" against a `Completed` Job Argo still owns.

<a id="sec-36-4"></a>
### 36.4 A pre-existing condition this inherits, not one it creates

Live-cluster check (`kubectl get applications -n argocd`) surfaced something worth
recording plainly rather than quietly working around: there is exactly **one** Argo
`Application` object each named `harbor`, `kube-prometheus-stack`, `demo-app` — not
one per environment — even though `routa-staging`/`routa-prod` are both live roots
and `harbor-staging`/`monitoring-staging`/`demo-staging` namespaces already exist
(from a past `routa-staging` sync). Neither `environments/staging/kustomization.yaml`
nor `environments/prod/kustomization.yaml` applies a `namePrefix`/`nameSuffix` — only
`destination.namespace`/`targetRevision` patches — so `platform/kustomization.yaml`'s
child Applications are named identically across all three environments' Kustomize
builds. `routa-dev`, `routa-staging`, `routa-prod` are therefore all reconciling the
**same** Argo `Application` objects (`argocd` namespace, name is the only key) toward
different `destination.namespace`/`targetRevision` values — a real fight, not a
theoretical one, and almost certainly why `kube-prometheus-stack`, `routa-prod`, and
`routa-staging` were already showing `OutOfSync` before this change.

**Not fixed as part of this task** — diagnosing/redesigning the environment-promotion
model is materially larger than "add the Kueue bonus task" and wasn't asked for.
`kueue-demo` was designed as a single shared instance from the start (36.3), so it
doesn't add a NEW instance of this problem — it experiences exactly the same
contention `harbor`/`kube-prometheus-stack`/`demo-app` already do, no more and no
less. Flagged here so it's not mistaken for something this change introduced, and as
a candidate for the report's "what would be improved with more time" section — the
fix is most likely a `namePrefix: dev-`/`staging-`/`prod-` (or similar) in each
environment overlay, which Argo CD's own multi-environment app-of-apps examples use
for exactly this reason.

<a id="sec-36-4b"></a>
### 36.4b Demo runtime bumped 60s → 180s — the quota was never wrong, the window was too short (2026-08-18)

Once this was actually live, the demo didn't show what it was built to show: both
Jobs' `Workload` objects came back `ADMITTED: True, FINISHED: True` with no
contention visibly caught in progress. Checked the quota mechanism itself before
touching anything else — `kubectl get clusterqueue cluster-queue` showed
`ADMITTED WORKLOADS: 1` throughout, never 2, and `job-b`'s `Workload` had only
flipped `Admitted` after `job-a`'s finished and released its quota. The 2 CPU
quota / 2×2 CPU demand from 36.3 was working exactly as designed — the problem was
that at `sleep 60`, the full sequence (admit A → run 60s → finish → admit B → run
60s → finish) completes in under two minutes, easy to check after the fact and see
both already finished with nothing caught in progress.

Fixed by bumping both Jobs' `sleep 60` to `sleep 180` in
`gitops/platform/kueue-demo/jobs.yaml` — no change to the `ClusterQueue`/quota math,
none was needed. This changes `.spec.template`, which is immutable on an existing
`Job` — the two Jobs already applied from the previous definition cannot be patched
in place; Argo's own `selfHeal` would just fail the sync against an immutable-field
error, not fix it. **Manual cleanup required once this is pushed and Argo re-syncs**,
before the new 180s definitions take effect:

```bash
kubectl delete job -n kueue-demo kueue-demo-job-a kueue-demo-job-b
```

Run this *after* the updated `jobs.yaml` has landed on `main` and `kueue-demo` has
picked it up (or immediately after a manual `argocd app sync kueue-demo`) — not
before. Deleting first while the old `sleep 60` definition is still what's in git
just gets the old Jobs recreated unchanged by `selfHeal`. Deleting after the new
definition is live lets `selfHeal` recreate them fresh with `sleep 180`. Job deletion
cascades to each Job's Pods and its Kueue `Workload` object via normal Kubernetes
garbage collection (both carry an `ownerReference` to the Job) — no separate
`kubectl delete workload`/`pod` needed.

<a id="sec-36-5"></a>
### 36.5 Verification

- `kubectl kustomize` (kustomize v5.8.1, bundled with kubectl v1.36.3) against every
  root in the repo — `bootstrap`, `bootstrap/local-path-provisioner`,
  `bootstrap/kueue-config` (new), `platform`, `platform/kueue-demo` (new), all three
  `environments/*` — all still exit 0. (`bootstrap/cluster-issuer/` has no
  `kustomization.yaml` by design, per its own file's comment — it's synced as a
  plain-manifest directory, not a Kustomize root; unchanged by this work.)
- `helm template kueue oci://registry.k8s.io/kueue/charts/kueue --version 0.19.1
  --namespace kueue-system` against the real pinned chart — rendered cleanly, 11
  CRDs, the controller `Deployment`, both webhook configurations, all present as
  expected.
- Hand-written `ResourceFlavor`/`ClusterQueue`/`LocalQueue`/`Job` manifests checked
  field-for-field against the actual example manifests fetched from the `v0.19.1` git
  tag (36.1) — same shape, only names/quota values/labels differ.
- `yaml.safe_load_all` parse of every new file — all parse, `kind`s are what's
  expected.
- Full `REPLACE_ME` sweep across `gitops/` — still zero.
- `project.yaml`'s `sourceRepos` re-grepped (not just appended to) per Section 35's
  own instruction to re-grep rather than assume the list is stale; only addition is
  `registry.k8s.io/kueue/charts`.

**Not done**: no live `kubectl apply`/Argo sync of any of this — nothing pushed to
`main` yet, so nothing has reached the cluster. Server-side dry-run validation of the
custom resources themselves (`ResourceFlavor`/`ClusterQueue`/`LocalQueue`) was
considered and skipped deliberately: it would require the Kueue CRDs actually
registered on the live API server first, i.e. a real (if reversible) cluster mutation
just to validate YAML shape — the field-for-field comparison against the verified
upstream example (36.1, 36.5) was judged sufficient, consistent with how this repo
has validated Application manifests elsewhere (`helm template` against the pinned
chart, not a live dry-run) when a live CRD dependency would otherwise be required.

---

<a id="sec-37"></a>
## 37. Environment Application-name collision: root cause confirmed, orphaned resources cleaned up, root cause NOT fixed (2026-08-18)

Investigated in response to a direct question about the "improve with more time" item
flagged while building Kueue (Section 36.4): is the dev/staging/prod overlay
situation cosmetic, or a real bug? It's real. This entry records what was found, what
was cleaned up (by Argo CD itself, not by hand — see 37.3), and what is deliberately
left open.

<a id="sec-37-1"></a>
### 37.1 Root cause, confirmed directly against the live cluster

`gitops/environments/{dev,staging,prod}/kustomization.yaml` all list `resources:
[../../platform]` and only patch `spec.destination.namespace` /
`spec.source(s).targetRevision` on the child Applications — none applies a
`namePrefix`/`nameSuffix`. `platform/kustomization.yaml`'s child Applications
(`harbor`, `kube-prometheus-stack`, `demo-app`) therefore render with the **same
`metadata.name`** regardless of which environment's Kustomize build produced them,
and Argo `Application` objects are keyed by name within the `argocd` namespace — so
`routa-dev`, `routa-staging`, and `routa-prod` are all reconciling the same three
Application objects toward three different desired states.

Confirmed, not inferred: Argo CD's own `SharedResourceWarning` status condition on
both `routa-staging` and `routa-prod` names exactly these three —
`"Application/harbor is part of applications argocd/routa-staging and routa-dev"`,
same wording for `kube-prometheus-stack` and `demo-app`. This is Argo's own built-in
collision detector, not a conclusion reached by inspection.

**`kueue-demo` (Section 36) does not join this collision** — it was deliberately
built as a single shared instance across environments from the start (36.3), so it
never had a competing per-environment name to begin with.

<a id="sec-37-2"></a>
### 37.2 Correction: this is what was actually behind `kube-prometheus-stack`'s bad health

Originally reported to the operator as "unrelated" — wrong, corrected here.
`kube-prometheus-stack`'s own `status.resources[]` had ~90 entries in the
`monitoring-staging` namespace (`requiresPruning: true`) left over from a past round
where `routa-staging` had momentarily won the fight over that Application object.
Among them, a `DaemonSet` (`prometheus-node-exporter`) whose pods were permanently
stuck `Pending` (`FailedScheduling`: "didn't have free ports for the requested pod
ports" — hostPort 9100 conflicting with the healthy copy already bound on the same
three nodes in the real `monitoring` namespace). Argo aggregates an Application's
health across everything it still tracks, healthy or not — so this one stuck
DaemonSet in an orphaned namespace was dragging `kube-prometheus-stack`'s reported
health to `Progressing` even though the live, correctly-routed copy in `monitoring`
was fully healthy the entire time. Same bug as 37.1, not a second one.

<a id="sec-37-3"></a>
### 37.3 A live, cluster-wide side effect checked *before* anything was deleted

Before touching anything, checked whether the orphaned `monitoring-staging` copy had
any cluster-scoped footprint that deleting the namespace wouldn't clean up. It did:
`ValidatingWebhookConfiguration`/`MutatingWebhookConfiguration`
`kube-prometheus-stack-admission` are cluster-scoped and name-fixed by the chart —
only one instance can exist — and at the time of checking, `clientConfig.service`
on all three of its rules (`prometheusrulevalidate`, `alertmanagerconfigsvalidate`,
`prometheusrulemutate`) pointed at `kube-prometheus-stack-operator.monitoring-staging`,
not the live `monitoring` copy. Read `.webhooks[].failurePolicy` on all three rules
directly (`kubectl get validatingwebhookconfiguration/mutatingwebhookconfiguration
... -o json`) before deciding anything: **`Ignore`** on every rule. That's what made
deleting the orphaned namespace safe from this angle — an unreachable webhook backend
under `failurePolicy: Ignore` means Kubernetes skips admission validation/mutation
for `PrometheusRule`/`AlertmanagerConfig` writes cluster-wide rather than rejecting
them; no hard failure for the live `monitoring` copy while the stale `clientConfig`
field waits for Argo's own `selfHeal` to correct it (which is `kube-prometheus-stack`
Application's own declared desired state already — the field was `OutOfSync`, not an
orphan Argo had abandoned).

Also checked: the three `ClusterRole`/`ClusterRoleBinding`/CRD sets tied to this
release are cluster-scoped, chart-generated regardless of destination namespace, and
already part of the live Application's own desired manifest (`requiresPruning`
unset, `status: OutOfSync` instead) — deleting the orphaned namespace does not
delete these; they stay, correctly, as the live Application's own resources.

<a id="sec-37-4"></a>
### 37.4 What actually got cleaned up — and by whom

Plan going in was to run `kubectl delete namespace monitoring-staging` by hand plus
delete `harbor-staging`'s three PVCs (`data-harbor-redis-0` 1Gi,
`data-harbor-trivy-0` 5Gi, `database-data-harbor-database-0` 1Gi — confirmed
untracked by any Argo Application, zero `argocd.argoproj.io/instance` label, unlike
`monitoring-staging`'s resources which the live `kube-prometheus-stack` Application
still tracked with `requiresPruning: true`). Presented the exact scope to the
operator for confirmation first, per instruction, before running anything
destructive.

**Neither delete was executed by hand.** By the time confirmation came back and the
commands were about to run, both `monitoring-staging` and `harbor-staging` had
already been removed — confirmed via `kubectl get ns` (`NotFound` on both) and via
the PV list (no `Released`/`Failed` PVs left over from either namespace; all five
backing PVs — 2Gi + 10Gi from `monitoring-staging`, 1Gi + 5Gi + 1Gi from
`harbor-staging` — are gone cleanly, consistent with their `reclaimPolicy: Delete`).
The most likely explanation: Argo CD's own `prune: true` + `selfHeal: true`
automated sync on `kube-prometheus-stack` (and whatever last reconciled `harbor`)
caught up on its normal reconciliation cadence in the time between the plan being
presented and confirmed. `kube-prometheus-stack` now reads `Synced` / `Healthy`, and
its admission webhook's `clientConfig.service.namespace` now correctly reads
`monitoring` — the stale field from 37.3 self-healed as predicted, without any
manual edit.

**What this means for the numbers already stated to the operator**: they still
stand as an accurate description of what was cleaned up — Argo removed the same
~90 `monitoring-staging` resources (including the 2Gi + 10Gi PVCs and their backing
data) and the 3 orphaned `harbor-staging` PVCs (~7Gi) — just via its own reconcile
loop rather than a manual `kubectl delete`. `demo-staging` namespace was left
untouched: confirmed genuinely empty (no PVCs, no workloads), so there was nothing
there costing anything to clean up.

<a id="sec-37-5"></a>
### 37.5 What's still actually broken — cleanup is not a fix

**The root cause (37.1) is unresolved.** `routa-staging` and `routa-prod` still read
`OutOfSync` right now, with the same `SharedResourceWarning` conditions still
present — dev happens to be the current "winner" for `harbor`/
`kube-prometheus-stack`/`demo-app` after this reconcile round, but nothing stops a
future automated sync of `routa-staging` or `routa-prod` from winning the same fight
back and recreating an orphaned `-staging`/`-prod` copy of these components again.
Tonight's cleanup fixed the symptom (resource/storage cost, degraded health
reporting) for right now; it did not fix the cause, and the exact same drift can
reappear on its own without anyone changing anything.

**Separately, and independently of the naming collision**: `git branch -a` /
`git ls-remote --heads origin` show this repository has only a `main` branch — no
`staging`, no `prod`. `routa-staging`'s and `routa-prod`'s multi-source child
Applications (`harbor`, `kube-prometheus-stack`) patch their `$values`
`targetRevision` to `staging`/`prod` (Section on the environments overlay), and those
refs do not exist. So even with the name collision fixed, the "promotion is a git-ref
bump" model this repo's docs describe (top of this file, "Repository layout") is not
actually wired end to end yet — there is nothing for `staging`/`prod` to diverge to
until those branches (or an equivalent ref) exist.

**Correct long-term fix, scoped for later, not done tonight**: a `namePrefix`
(`dev-`/`staging-`/`prod-`, or similar) in each `gitops/environments/*/kustomization.yaml`,
which is the same shape Argo CD's own multi-environment app-of-apps documentation
uses for exactly this reason, plus actually creating `staging`/`prod` branches (or
switching the promotion model to something that doesn't depend on them existing).
Neither attempted here — this entry documents the finding and the immediate
cleanup only, per instruction to scope the structural fix separately.

<a id="sec-37-6"></a>
### 37.6 Verification

- `kubectl get application <name> -n argocd -o json`, `status.resources[]` and
  `status.conditions[]` read directly for all six Applications involved
  (`routa-dev/staging/prod`, `harbor`, `kube-prometheus-stack`, `demo-app`) — not
  inferred from `kubectl get applications` summary output.
- `kubectl get validatingwebhookconfiguration/mutatingwebhookconfiguration
  kube-prometheus-stack-admission -o json`, `.webhooks[].failurePolicy` and
  `.webhooks[].clientConfig.service` read directly, before and after.
- `kubectl get ns`, `kubectl get pv` re-checked immediately before writing this entry
  — `monitoring-staging`/`harbor-staging` both `NotFound`, no `Released`/`Failed` PVs
  outstanding from either.
- `git branch -a` and `git ls-remote --heads origin` — only `main` exists.
- Nothing in this repository's tracked files changed as part of this investigation —
  no `kubectl apply`, no `kubectl delete` run by hand, no git changes beyond this
  entry. The cleanup that happened, happened via Argo CD's own existing
  `syncPolicy.automated` on `kube-prometheus-stack`/`harbor`, not via any command run
  in this session.

<a id="sec-37-7"></a>
### 37.7 `routa-staging`'s auto-sync removed — closes the recurrence risk 37.5 flagged, not the root cause

37.5 left the root cause (37.1, no `namePrefix`) explicitly unfixed and warned the
same orphaning could recur on its own, without anyone changing anything, the next
time `routa-staging` or `routa-prod`'s automated sync won a race against `routa-dev`
over the shared `harbor`/`kube-prometheus-stack`/`demo-app` Application objects.

**`root-staging.yaml`'s `syncPolicy.automated` (`prune: true`, `selfHeal: true`)
removed.** `routa-prod.yaml` needed no change — checked first, and it already has no
`automated` block; it's been manual-sync-only since it was written, for an unrelated
reason (deliberate prod-promotion gating, its own file's original comment). That
turns out to have been silently doing double duty: prod was never able to win the
naming race in the first place, purely as a side effect of a policy chosen for a
different reason. Recorded in both files' own comments now that the connection is
understood, not because `root-prod.yaml`'s behavior changed.

**What this does and does not fix, stated plainly:**
- **Removes the recurrence mechanism.** With `routa-staging` no longer auto-syncing,
  there is exactly one automated writer (`routa-dev`) contesting the shared
  Application objects — a race needs two periodic actors, and now there is only one.
  The specific failure from 37.2–37.4 (an environment's auto-sync winning a round,
  leaving the loser's workloads orphaned when the other side wins the next round)
  can no longer happen on its own.
- **Does not remove the collision itself.** `harbor`/`kube-prometheus-stack`/
  `demo-app` still render with identical names from every environment's Kustomize
  build (37.1) — that structural fact is unchanged. A manual `argocd app sync
  routa-staging` (or `routa-prod`) still overwrites whichever environment currently
  holds those objects, same as before; the guardrail is now that a human has to
  invoke it and see the diff first, not that the collision stopped existing.
- **Also matches the promotion model better**, independent of the bug fix: this repo's
  own layout description (top of this file) already frames environment promotion as
  a deliberate ref/overlay change, not something that happens automatically on every
  `main` merge. `routa-prod` already had that discipline; `routa-staging` did not,
  despite being a promotion target the same way. Both are now deliberately gated;
  only `routa-dev` is "always current."
- **`namePrefix` (or equivalent) in the environment overlays remains the correct
  long-term fix** for 37.1 itself, still not done, still scoped for later — this
  change reduces the blast radius and removes the self-triggering recurrence path,
  it does not resolve the underlying naming collision.

**Verification**: `kubectl kustomize gitops/bootstrap` — exit 0. Parsed the rendered
output (not just visually inspected) and confirmed `routa-dev`'s `spec.syncPolicy`
still carries `automated: {prune: true, selfHeal: true}` while `routa-staging`'s and
`routa-prod`'s both show `automated: None`, and all three retain
`syncOptions: [CreateNamespace=true]`. Nothing pushed.
