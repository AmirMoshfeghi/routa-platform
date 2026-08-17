# Resource schema verified 2026-08-17 against:
#   https://github.com/verda-cloud/terraform-provider-verda/blob/main/docs/resources/instance.md
# (provider v1.1.2 — see versions.tf). `image` has no default: resolve the correct
# plain-Ubuntu identifier via the Verda MCP server / `verda images list` before apply.

resource "verda_instance" "mgmt" {
  instance_type = var.mgmt_instance_type
  image         = var.image
  hostname      = "${var.hostname_prefix}-mgmt"
  description   = "k3s + Rancher Manager + cert-manager"
  location      = var.location

  ssh_key_ids = [verda_ssh_key.routa.id]

  os_volume = {
    name = "${var.hostname_prefix}-mgmt-os"
    size = var.mgmt_os_volume_gb
    type = "NVMe"
  }
}

resource "verda_instance" "cluster" {
  for_each = toset([for i in range(var.worker_count) : tostring(i + 1)])

  instance_type = var.worker_instance_type
  image         = var.image
  hostname      = "${var.hostname_prefix}-cp-${each.key}"
  description   = "RKE2 cluster node ${each.key}"
  location      = var.location

  ssh_key_ids = [verda_ssh_key.routa.id]

  os_volume = {
    name = "${var.hostname_prefix}-cp-${each.key}-os"
    size = var.worker_os_volume_gb
    type = "NVMe"
  }
}
