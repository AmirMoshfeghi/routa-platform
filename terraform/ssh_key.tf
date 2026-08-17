resource "verda_ssh_key" "routa" {
  name       = "${var.hostname_prefix}-ed25519"
  public_key = file(pathexpand(var.ssh_public_key_path))
}
