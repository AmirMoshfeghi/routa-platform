# Verda Senior Platform Engineer Assignment — Day 0 Decision Log

**Date:** 2026-08-09
**Status:** Account, tooling and WSL2 environment complete. Sizing and region locked from
live discovery data. No infrastructure provisioned. No credits consumed.
**Balance:** $115.35 USD (coupon redeemed into the dedicated project)
**Target region:** FIN-03
**Stated deadline:** 2026-08-13 (extension not yet requested — see Open Items)

> **Note:** This document is intended to become the seed of `docs/decisions.md` in the
> submitted repository. The assignment brief states that reasoning, trade-offs and
> debugging approach matter more than a perfect implementation, so a running decision
> log written *as decisions are made* is worth more than one reconstructed at the end.

---

## 1. Assignment analysis

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

### 1.3 The most important sentence in the brief

> "We care more about your reasoning, tradeoffs, debugging approach, and final summary
> than a copy-paste happy path."

Repeated in the covering email. Two consequences that shape the whole approach:

1. The **written report is likely worth as much as the cluster**. Budget real time for it.
2. **"What did not work" is a scoring section, not a confession.** Documenting a real
   failure and the debugging path to resolution is the strongest available signal of
   seniority. Do not hide failures; instrument them.

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

## 3. Steps completed today, in order, with reasoning

### Step 1 — Analysed assignment and job ad; mapped rubric
**Why first:** understanding what is being tested determines where effort goes.
Building before understanding the rubric risks a technically fine cluster that misses
the point.

### Step 2 — Drafted deadline extension request
**Why:** travel this week compresses available time, and the bonus tasks are
high-signal. Two extra days cost the employer nothing. Asked early, before being deep
in the work, because a late request reads as poor planning while an early one reads as
planning.

The email also asks whether **compute credits expire a fixed period after redemption**
— the one genuine unknown that affects sequencing.

### Step 3 — Resolved a misreading: signup does not start a timed session
**Concern raised:** would logging in start the assignment clock?

**Resolution:** no. The brief describes a normal cloud account and a coupon code; the
deadline is a calendar date, not a countdown. The covering email supplies a
self-service coupon code (`ASSIGNMENT-XXXXX`), which supersedes the brief's
"share your email and we will add credits" instruction — nothing is queued on Verda's
side.

**Why this mattered:** the misreading was costing a day of preparation time for no
reason.

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

### Step 6 — Established the working environment: macOS with WSL2 as an earlier step

Initial CLI setup and account verification were done via WSL2 on Windows (Ansible has
no supported native Windows control node). When a MacBook with Claude Code became
available, consolidated onto it as the single working environment rather than
maintaining two divergent machines with separate credential files and keys.

**Toolchain**, via Homebrew and the documented Verda quick-install script:

```bash
curl -sSL https://raw.githubusercontent.com/verda-cloud/verda-cli/main/scripts/install.sh | sh
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
brew install ansible kubectl helm git kind
```

**Note:** `brew install terraform` fails directly — HashiCorp moved Terraform out of
Homebrew core over licensing terms, hence the explicit tap. Worth flagging: **OpenTofu**
is a fully open-source, drop-in-compatible fork born from that same licensing dispute,
and Verda's Terraform provider works with either. Terraform was kept here as the more
universally recognised name in an interview context — a deliberate trade-off, not a
default.

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

**SSH key generated fresh for this assignment**, no passphrase:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/routa_ed25519 -C "routa"
```

**Decision, not an oversight:** a passphrase would prompt on every automated
connection — Ansible runs, Terraform SSH provisioners, calls made on the assignment's
behalf by Claude Code — disproportionate friction for a key that is narrowly scoped
(only these VMs), short-lived (torn down at the end of the assignment), and trivially
revocable.

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

**Full environment verified in one pass** before provisioning: all tool versions
present, `verda doctor` fully green, credentials file and SSH keypair permissions
correct (600 private / 644 public), balance unchanged at $115.35, and FIN-03 CPU
availability re-confirmed immediately before starting the build (see 4.1).

---

## 4. Discovery results — region, sizing and cost model (locked)

Discovery was run *before* any design was committed. This was the correct order: it
surfaced a regional capacity constraint that would have invalidated the plan if
discovered mid-build.

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

### 4.2 Instance pricing (CPU)

| Type | vCPU | RAM | $/hr |
|---|---|---|---|
| CPU.4V.16G | 4 | 16 GB | $0.0279 |
| CPU.8V.32G | 8 | 32 GB | $0.0558 |
| CPU.16V.64G | 16 | 64 GB | $0.1116 |
| CPU.32V.128G | 32 | 128 GB | $0.2232 |

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

### 4.6 Spot pricing — considered and rejected

Spot pricing is available (`--spot`) and cheaper. Rejected for this build: spot
instances can be reclaimed, and losing an etcd member mid-build would cost hours.

Spot *would* be appropriate for KWOK simulation nodes or CI runners — workloads that
are stateless and cheap to restart. This distinction belongs in the report; it
demonstrates understanding of the platform's own cost model, which is directly
relevant to the role.

---

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

### Key facts extracted

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

## 7. Open items

| Item | Status |
|---|---|
| Coupon redeemed into the dedicated project | **Done** — balance confirmed at $115.35 |
| Credentials moved out of Google Drive to `~/.config/verda/env` | **Done** — verify Drive Trash also emptied (30-day retention) |
| WSL2 environment with Verda CLI authenticated | **Done** — `verda doctor` passing |
| Region and sizing locked from live discovery | **Done** — see Section 4 |
| Send extension + credit-expiry email | **Pending — send next** |
| Determine which project the CLI/API credentials operate against | **Open** — see 7.1 below |
| Billing notification thresholds adjusted (72h / 1 day) | Optional; confirm and save |
| Codename for cluster/hostnames/DNS | Deferred until provisioning |

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

## 8. Next session — first actions

1. **Send the extension email.** Blocking nothing technically, but the answer is more
   useful the earlier it arrives.

2. **Complete the remaining WSL2 toolchain**
   ```bash
   # already installed: verda CLI (authenticated, doctor passing)
   # still needed:
   terraform   # or opentofu
   ansible
   kubectl
   helm
   git
   kind        # local rehearsal of the in-cluster layer
   ```

3. **Resolve the project-scoping question** (Section 7.1) — cheapest checks first,
   then the one-cent empirical test if needed. Do this before writing Terraform, so
   the provisioning path is known-good.

4. **Re-check availability immediately before provisioning**
   ```bash
   verda availability --location FIN-03
   ```
   Inventory is live and changes. Confirm `CPU.8V.32G` is still in stock rather than
   assuming yesterday's result holds.

5. **Scaffold the repository** — directory structure, `.gitignore` first,
   `docs/decisions.md` seeded from this document.

   `.gitignore`, before the first `terraform apply`:
   ```
   *.tfstate
   *.tfstate.*
   .terraform/
   *.tfvars
   .envrc
   .env
   kubeconfig
   *.kubeconfig
   ```
   Terraform state is the single most commonly leaked file in take-home assignments
   and may contain sensitive values.

6. **Write the Terraform** — roughly four resource types: `verda_ssh_key`,
   `verda_startup_script` (optional), `verda_instance` (×4 via `for_each`), and an
   `instance_ips` output feeding the Ansible inventory.

   Values are now fixed rather than assumed:

   ```hcl
   location      = "FIN-03"
   mgmt_type     = "CPU.4V.16G"   # os_volume 50 GiB
   worker_type   = "CPU.8V.32G"   # os_volume 100 GiB, ×3
   ```

   Provider block stays empty — credentials come from `VERDA_CLIENT_ID` /
   `VERDA_CLIENT_SECRET` in the environment, so no secret material enters the repo:

   ```hcl
   provider "verda" {}
   ```

   Still to confirm: the exact Ubuntu image identifier for CPU instances. The
   documented examples are all CUDA variants intended for GPU nodes
   (`ubuntu-24.04-cuda-13.0-open-docker`), which are the wrong choice here. Check
   `verda vm create --help` or the images endpoint for a plain Ubuntu 24.04 image.

---

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

## 12. API endpoint, TLS SANs, and a latent `group_vars` bug (2026-08-17)

Two findings from reviewing the `rke2-server` role. The first was raised as "`rke2_tls_san`
is undefined and will hard-fail the template task"; the second was found while
verifying the fix and is the more serious of the two.

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

## 13. CPU image identifier resolved (2026-08-17)

The `image` variable flagged as unresolved since Section 8 (step 6) and reiterated
in Sections 10 and 12 is now resolved. Not changed retroactively in those earlier
entries — they're an accurate record of what was known at the time.

**Method:** the Verda MCP server declared in `.mcp.json` (`verda mcp serve`) is not
actually connected in this Claude Code session — it never surfaced when searching
available tools. Fell back to the CLI directly (`verda images --type CPU.8V.32G -o
json`), which is what the MCP server wraps per docs.verda.com/cli/mcp, so the data
source is the same either way. Worth a line for the report: the MCP-first instruction
in `CLAUDE.md` is a preference for freshness over training data, not a hard
dependency on the MCP transport specifically — the CLI is an equally-live fallback.

**Cross-checked against both instance types actually used** (`CPU.8V.32G` for
cluster nodes, `CPU.4V.16G` for mgmt) — same image compatible with both, so a single
shared `var.image` (as already structured in `instances.tf`) is valid.

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
