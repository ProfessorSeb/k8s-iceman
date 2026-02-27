# Pools for k8s-iceman services

# --- Argo CD ---
resource "bigip_ltm_pool" "argocd" {
  name                = "/Common/k8s_iceman_argocd_pool"
  load_balancing_mode = "round-robin"
  monitors            = [bigip_ltm_monitor.argocd.name]
}

resource "bigip_ltm_pool_attachment" "argocd" {
  for_each = var.k8s_nodes
  pool     = bigip_ltm_pool.argocd.name
  node     = "${bigip_ltm_node.k8s_nodes[each.key].name}:${var.nodeport_argocd}"
}

# --- Vault ---
resource "bigip_ltm_pool" "vault" {
  name                = "/Common/k8s_iceman_vault_pool"
  load_balancing_mode = "round-robin"
  monitors            = [bigip_ltm_monitor.vault.name]
}

resource "bigip_ltm_pool_attachment" "vault" {
  for_each = var.k8s_nodes
  pool     = bigip_ltm_pool.vault.name
  node     = "${bigip_ltm_node.k8s_nodes[each.key].name}:${var.nodeport_vault}"
}

# --- kagent ---
resource "bigip_ltm_pool" "kagent" {
  name                = "/Common/k8s_iceman_kagent_pool"
  load_balancing_mode = "round-robin"
  monitors            = [bigip_ltm_monitor.kagent.name]
}

resource "bigip_ltm_pool_attachment" "kagent" {
  for_each = var.k8s_nodes
  pool     = bigip_ltm_pool.kagent.name
  node     = "${bigip_ltm_node.k8s_nodes[each.key].name}:${var.nodeport_kagent}"
}
