variable "location" {
  description = "Verda region. FIN-03 is the only region with the required CPU types in stock as of 2026-08-16 — see docs/decisions.md Section 4.1. Re-check `verda availability --location FIN-03` before apply, inventory is live."
  type        = string
  default     = "FIN-03"
}

variable "image" {
  description = <<-EOT
    Verda OS image identifier for CPU-only instances (plain Ubuntu 24.04, no CUDA).
    Resolved 2026-08-17 via `verda images --type CPU.8V.32G -o json` (cross-checked
    against `--type CPU.4V.16G` — same image compatible with both). The `image_type`
    field (not the `id` UUID) is what the verda_instance resource's `image` argument
    expects — see terraform/instances.tf's schema-verification comment.
    Candidates returned for Ubuntu 24.04, all under category "ubuntu":
      - ubuntu-24.04-cuda-13.0-open-docker  — CUDA 13.0 Open + Docker
      - ubuntu-24.04-cuda-13.0-open         — CUDA 13.0 Open
      - ubuntu-24.04-cuda-12.8-open-docker  — CUDA 12.8 Open + Docker (is_default: true)
      - ubuntu-24.04-cuda-12.8-open         — CUDA 12.8 Open
      - ubuntu-24.04-cuda-12.6-docker       — CUDA 12.6 + Docker
      - ubuntu-24.04-cuda-12.6              — CUDA 12.6
      - ubuntu-24.04                        — "Minimal Image", no CUDA  <- picked
    Picked ubuntu-24.04: it's the only non-CUDA Ubuntu 24.04 entry. The others all
    ship NVIDIA CUDA userspace and drivers meant for GPU instances — dead weight and
    attack surface on the CPU-only mgmt/RKE2 nodes here, which install their own
    stack (k3s/RKE2, Cilium) via Ansible regardless. `is_default: true` on the
    12.8-open-docker variant is Verda's default for GPU workloads, not a signal to
    use it here.
    The image catalog has no --location flag (unlike instance-type stock, which is
    region-scoped and re-checked before apply per docs/decisions.md Section 4.1) —
    it appears to be global, not per-region.
  EOT
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to the public half of the assignment SSH keypair (see docs/decisions.md Section 3 Step 6)."
  type        = string
  default     = "~/.ssh/routa_ed25519.pub"
}

variable "mgmt_instance_type" {
  description = "Instance type for the mgmt node (k3s + Rancher + cert-manager). Locked in docs/decisions.md Section 4.4."
  type        = string
  default     = "CPU.4V.16G"
}

variable "mgmt_os_volume_gb" {
  type    = number
  default = 50
}

variable "worker_instance_type" {
  description = "Instance type for the RKE2 cluster nodes. Locked in docs/decisions.md Section 4.4."
  type        = string
  default     = "CPU.8V.32G"
}

variable "worker_os_volume_gb" {
  type    = number
  default = 100
}

variable "worker_count" {
  description = "Number of RKE2 cluster nodes (mgmt node is separate). All 3 are full RKE2 servers forming an HA etcd quorum — see ansible/inventory/group_vars/all.yml."
  type        = number
  default     = 3
}

variable "hostname_prefix" {
  type    = string
  default = "routa"
}
