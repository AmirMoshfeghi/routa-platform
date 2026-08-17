# routa-platform

Verda Senior Platform Engineer take-home: Terraform provisions 4 CPU VMs on Verda
Cloud, Ansible hardens them and installs RKE2 (Cilium CNI), Argo CD (app-of-apps)
delivers everything above the cluster. Full reasoning and decision history lives in
`docs/decisions.md` — read it before making architectural changes.

## Standing instructions for any AI assistant working in this repo

**1. Docs before syntax.** Before writing or changing any tool configuration —
Terraform (provider or resources), Helm charts, Argo CD manifests, RKE2 config,
Cilium, Kueue — fetch the current official docs for that tool first. Do not rely on
training data for version-specific syntax or schema; it goes stale and this provider
ecosystem (Verda's Terraform provider especially) is young and moves fast. State
which version you targeted and where you verified it (comment in the file, or in
your response) so the next reader doesn't have to re-derive trust in the config.

**2. Pin every version explicitly. Never use `latest`.** Terraform provider
versions, Helm chart versions, RKE2 release, container image tags — all pinned,
all traceable to a source. An unpinned version is a future incident, not a
convenience. Every versioned file in this repo (`terraform/versions.tf`,
`ansible/inventory/group_vars/all.yml`, `gitops/platform/*/application.yaml`) carries
a comment naming the doc/release page the version was verified against and the date.
Keep that pattern going — update the comment when you bump the version, don't just
change the number.

**3. Use the Verda MCP server for anything Verda-specific.** Instance types,
regional availability, image identifiers, pricing — query the `verda` MCP server
(wired up in `.mcp.json`, backed by `verda mcp serve`) rather than assuming or
recalling from training data. Verda's on-demand inventory genuinely changes between
sessions (see `docs/decisions.md` Section 4.1) — a value that was true yesterday may
not be true now. `terraform/variables.tf`'s `image` variable is a worked example of
this: its default (`ubuntu-24.04`) was resolved via `verda images`, not guessed —
re-verify against the live catalog rather than trusting that default indefinitely,
since Verda's image catalog can change.

## Repository layout

```
terraform/    Provisioning only: 4 verda_instance resources (1 mgmt + 3 cluster
              nodes), an SSH key, and an outputs.tf that renders
              ansible/inventory/hosts.ini via local_file + templatefile(). Provider
              block is empty — credentials come from VERDA_CLIENT_ID /
              VERDA_CLIENT_SECRET in the environment (~/.config/verda/env).

ansible/      Configuration only. Roles: hardening (baseline OS/SSH/firewall),
              rke2-server (all 3 cluster nodes — a 3-server RKE2 HA control plane
              with embedded etcd, not a single server + agents; the bootstrap node
              generates a join token, the other two read it via a play-level var
              and join with it), kubeconfig-fetch (pulls and rewrites the admin
              kubeconfig). playbooks/site.yml runs hardening then rke2-cluster
              (bootstrap play, then join play) then kubeconfig-fetch, in order.
              inventory/group_vars/all.yml pins the RKE2 version, records which
              Cilium version ships bundled with it, and derives the API endpoint
              and TLS SAN list from the generated inventory. It lives under
              inventory/ (not ansible/group_vars/) because Ansible only auto-loads
              group_vars adjacent to the inventory or the playbook — see
              docs/decisions.md Section 12.

gitops/       Everything inside the cluster, via Argo CD app-of-apps:
                bootstrap/     AppProject + one root Application per environment
                               (root-dev/staging/prod.yaml)
                platform/      Base: child Applications for kube-prometheus-stack,
                               harbor, and a demo app — each version-pinned
                environments/  dev|staging|prod Kustomize overlays over platform/,
                               namespace-suffixed and pinned to different git refs
                               (main / staging / prod) — that ref bump *is* the
                               promotion step. prod additionally drops
                               syncPolicy.automated: promotion to prod requires a
                               manual `argocd app sync`.

docs/         decisions.md is the running decision log — append to it, don't
              replace it. It is the primary deliverable per the assignment brief
              ("reasoning, tradeoffs, and debugging approach matter more than a
              copy-paste happy path").
```

## Working conventions

- **Terraform's surface stays small.** Provisioning only (VMs, SSH key, IP outputs).
  Anything that configures the OS or the cluster belongs in Ansible or gitops/, not
  Terraform. Don't grow `terraform/` into a config-management tool.
- **Naming.** Verda project: `amir-platform-assignment` (billing object, keeps the
  assignment context). Everything below that — hostnames, SSH key, DNS — uses the
  codename `routa` and reads as if it were headed to production. See
  `docs/decisions.md` Section 3 Step 6 for the full table.
- **No credentials in this repo, ever** — not in Terraform files, not in Ansible
  vars, not in a commit, not in a chat transcript. `.gitignore` covers `.env`,
  `.tfvars`, `.tfstate`, kubeconfigs. Verda credentials live in
  `~/.config/verda/env`, sourced before starting a work session.
- **Every non-obvious decision gets a line in `docs/decisions.md` at the time it's
  made.** This is not optional documentation hygiene — the brief explicitly weights
  reasoning and debugging approach above implementation polish.
- **Do not run `terraform apply` or any Ansible playbook without being explicitly
  asked to.** Plans/dry-runs are fine; provisioning spends real credits and time.
