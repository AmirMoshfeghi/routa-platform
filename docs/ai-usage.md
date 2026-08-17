# AI-assisted engineering — usage and verification

The job description asks for someone who can "leverage AI-assisted engineering tools
to improve automation, operations, and troubleshooting." This document records how AI
tooling was actually used to build this platform, where the boundaries were drawn, and
— most importantly — the cases where AI output was wrong or misleading and how that was
caught. The last part is the point: the value of an AI-assisted workflow is not that
the AI is always right, but that the engineer keeps a verification loop tight enough to
catch it when it isn't.

## Tools used

| Tool | Role |
|---|---|
| Claude (chat) | Planning, rubric analysis, architecture review, catching design gaps. Did not touch the filesystem. |
| Claude Code | Execution — writing Terraform, Ansible, and GitOps manifests; running local validation; editing files in-repo. |
| Verda MCP server (`verda mcp serve`) | Live source of truth for Verda-specific facts — instance types, regional availability, pricing, image identifiers — queried instead of relying on model training data. Wired up in `.mcp.json`. |

The Verda MCP server is worth calling out specifically: it means Verda-specific facts
come from Verda's live API at the moment of use, not from a model's recollection. Verda's
on-demand inventory genuinely changes between sessions (documented in
`decisions.md` §4.1 — the FIN-03 instance-type list changed on every check), so a
recalled value would have been actively wrong. This is the correct division: the model
reasons about architecture; the MCP server supplies current facts.

## Division of labor

The intent throughout was for the engineer to **direct** and the AI to **execute and
draft**, not the reverse. Concretely:

- **Decided by the engineer, then implemented by AI:** the overall architecture (Terraform
  for provisioning / Ansible for config / Argo CD for delivery), the region and instance
  sizing, the choice to install Rancher rather than justify skipping it, the promotion
  model, and — as a mid-build correction — overriding a single-server control plane back
  to a 3-server HA control plane (see below).
- **Drafted by AI, reviewed by the engineer:** the actual Terraform resources, the Ansible
  roles, the GitOps manifests, the version pins (fetched live, then checked), and the
  commit messages.
- **Refused by AI, correctly:** the plain-Ubuntu-24.04 image identifier was left unset
  rather than guessed, so `terraform plan` fails loudly until it is resolved via the MCP
  server. A guess here would have been worse than an error.

## Verification practice

The standing rules encoded in `CLAUDE.md` govern how AI output is trusted:

1. **Docs before syntax** — fetch current official documentation before writing
   version-specific config, and record which version was verified and where.
2. **Pin every version, never `latest`** — with a provenance comment naming the source
   and date.
3. **Use the Verda MCP server for Verda-specific facts** rather than recalling them.
4. **Verify by rendering, not by syntax check** — `terraform fmt`,
   `ansible-playbook --syntax-check`, and YAML/JSON linters do not evaluate variables.
   Configuration is confirmed by rendering it with variables resolved and inspecting the
   *values*, not just the syntax.

Rule 4 was not theoretical. It was added in direct response to the incident below.

## Cases where AI output was wrong or misleading — and how it was caught

### 1. A group_vars file that was silently not loading

**What happened.** The Ansible variables file — RKE2 version pin, `cni: cilium`, token
path, the whole set — was initially placed at `ansible/group_vars/all.yml`. Ansible only
auto-loads `group_vars/` when it sits adjacent to the inventory or the playbook, and this
location was adjacent to neither. Every variable in the file was invisible at runtime.

**Why it mattered.** This was not a crash. `--syntax-check` and `terraform fmt` both
passed against it, because neither evaluates a variable. The real consequence was worse
than a crash: with `rke2_version` unset, the RKE2 install script pulls the *latest*
release rather than the pinned `v1.36.3+rke2r1` — an unpinned-version defect (a violation
of the repo's own rule 2) arriving through an unloaded file rather than anyone typing
`latest`. A safeguard was written correctly and silently not applied.

**How it was caught.** Attempting to *render* the RKE2 config template with variables
resolved (to verify an unrelated fix) failed with `'rke2_cni' is undefined`. The file was
moved to `ansible/inventory/group_vars/all.yml`, and the configs were then re-rendered and
parsed to confirm the values were actually present. Documented in `decisions.md` §12.

### 2. A verification that passed for the wrong reason ("false green")

**What happened.** In an earlier step, an ad-hoc `-m debug` check appeared to confirm that
the group_vars variables resolved correctly. It did not actually confirm that. It passed
only because it happened to be run from within the `ansible/` directory, which made the
current working directory the Ansible basedir — so `group_vars/` was adjacent to the cwd
for that one invocation, and the variables resolved for a reason entirely unrelated to
whether a normal playbook run would load them.

**Why it mattered.** This is the more instructive of the two, because the failure was in
the *verification itself*, not the config. A green check that is green for the wrong
reason is more dangerous than a red one, because it stops you looking. Had that false
green been trusted, the group_vars bug above would have shipped.

**How it was caught.** On re-examination while investigating the group_vars path issue, the
earlier check was recognized as cwd-dependent rather than a genuine confirmation. This is
what produced rule 4 above: verify by rendering with variables resolved, from a fixed and
known basedir — never from a location that happens to make the check pass.

### 3. A single-server control plane presented as a settled scaffold choice

**What happened.** During scaffolding, the RKE2 topology was quietly set to one server plus
two agents and labelled a time-budget decision. For a role that names high-availability
environments as a competency, at a company that operates managed Kubernetes, a
single-node control plane is exactly the wrong signal — one node loss destroys the
cluster.

**How it was caught.** Flagged in architecture review as a decision that should be made
deliberately rather than accepted by default, and overridden to a 3-server HA control
plane (etcd quorum, tolerates one node failure) within the existing 4-VM budget by making
the three servers schedulable. Documented in `decisions.md` §12. The lesson: AI-drafted
"reasonable defaults" still need to be checked against the specific thing the work is
meant to demonstrate.

## Summary

AI tooling meaningfully accelerated this build — live-fetched and pinned versions, correct
HA bootstrap/join config, a clean repository structure. It also produced a silently-broken
variable path, a misleading green check, and a default that undercut the assignment's
intent. All three were caught, and two of them hardened the process (rule 4, and the
override to HA). That loop — delegate, then verify by rendering rather than by trust — is
the actual skill, and it is the one this document is meant to evidence.
