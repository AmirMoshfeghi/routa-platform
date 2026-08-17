output "mgmt_ip" {
  value = verda_instance.mgmt.ip
}

output "cluster_ips" {
  value = { for k, v in verda_instance.cluster : k => v.ip }
}

locals {
  # Node "1" bootstraps the RKE2 etcd cluster; nodes "2" and "3" join it. All three
  # are full servers (3-node etcd quorum, HA) — see ansible/inventory/group_vars/all.yml.
  bootstrap_host = [
    for k, v in verda_instance.cluster : { hostname = v.hostname, ip = v.ip }
    if k == "1"
  ][0]
  join_hosts = [
    for k, v in verda_instance.cluster : { hostname = v.hostname, ip = v.ip }
    if k != "1"
  ]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    mgmt_hostname      = verda_instance.mgmt.hostname
    mgmt_ip            = verda_instance.mgmt.ip
    bootstrap_hostname = local.bootstrap_host.hostname
    bootstrap_ip       = local.bootstrap_host.ip
    join_hosts         = local.join_hosts
  })
  filename        = "${path.module}/../ansible/inventory/hosts.ini"
  file_permission = "0600"
}
