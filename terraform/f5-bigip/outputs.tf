output "vip_argocd" {
  description = "Argo CD UI URL"
  value       = "https://${var.vip_argocd}:443"
}

output "vip_vault" {
  description = "Vault UI URL"
  value       = "http://${var.vip_vault}:8200"
}

output "vip_kagent" {
  description = "kagent UI URL"
  value       = "http://${var.vip_kagent}:8080"
}
