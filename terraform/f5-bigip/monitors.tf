# Health monitors for k8s-iceman services

resource "bigip_ltm_monitor" "argocd" {
  name     = "/Common/k8s_iceman_argocd_monitor"
  parent   = "/Common/tcp"
  interval = 10
  timeout  = 31
}

resource "bigip_ltm_monitor" "vault" {
  name     = "/Common/k8s_iceman_vault_monitor"
  parent   = "/Common/http"
  send     = "GET /v1/sys/health?standbyok=true HTTP/1.1\\r\\nHost: vault\\r\\nConnection: close\\r\\n\\r\\n"
  receive  = "200"
  interval = 10
  timeout  = 31
}

resource "bigip_ltm_monitor" "kagent" {
  name     = "/Common/k8s_iceman_kagent_monitor"
  parent   = "/Common/tcp"
  interval = 10
  timeout  = 31
}
