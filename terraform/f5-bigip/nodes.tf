# Kubernetes Talos nodes
resource "bigip_ltm_node" "k8s_nodes" {
  for_each    = var.k8s_nodes
  name        = "/Common/${each.key}"
  address     = each.value
  monitor     = "/Common/icmp"
  description = "Talos k8s node - k8s-iceman cluster"
}
