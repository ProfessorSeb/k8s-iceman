# Virtual Servers (VIPs) for k8s-iceman services
# VIP range: 172.16.20.60-80

# --- Argo CD UI (HTTPS) ---
resource "bigip_ltm_virtual_server" "argocd" {
  name                       = "/Common/k8s_iceman_argocd_vs"
  destination                = var.vip_argocd
  port                       = 443
  pool                       = bigip_ltm_pool.argocd.name
  ip_protocol                = "tcp"
  profiles                   = ["/Common/tcp"]
  source_address_translation = "automap"
}

# --- Vault UI (HTTP) ---
resource "bigip_ltm_virtual_server" "vault" {
  name                       = "/Common/k8s_iceman_vault_vs"
  destination                = var.vip_vault
  port                       = 8200
  pool                       = bigip_ltm_pool.vault.name
  ip_protocol                = "tcp"
  profiles                   = ["/Common/tcp", "/Common/http"]
  source_address_translation = "automap"
}

# --- kagent UI (HTTP) ---
resource "bigip_ltm_virtual_server" "kagent" {
  name                       = "/Common/k8s_iceman_kagent_vs"
  destination                = var.vip_kagent
  port                       = 8080
  pool                       = bigip_ltm_pool.kagent.name
  ip_protocol                = "tcp"
  profiles                   = ["/Common/tcp", "/Common/http"]
  source_address_translation = "automap"
}
