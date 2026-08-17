variable "location" {
  description = "Verda region. FIN-03 is the only region with the required CPU types in stock as of 2026-08-16 — see docs/decisions.md Section 4.1. Re-check `verda availability --location FIN-03` before apply, inventory is live."
  type        = string
  default     = "FIN-03"
}

variable "image" {
  description = <<-EOT
    Verda OS image identifier for CPU-only instances (plain Ubuntu 24.04, no CUDA).
    UNRESOLVED as of scaffolding time — decisions.md Section 8 step 6 flags that the
    documented examples are all CUDA/GPU variants (e.g. ubuntu-24.04-cuda-13.0-open-docker).
    Resolve via the Verda MCP server or `verda images list` before the first apply;
    do not guess an identifier here. Left with no default on purpose so a plan/apply
    fails loudly instead of silently provisioning the wrong image.
  EOT
  type        = string
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
