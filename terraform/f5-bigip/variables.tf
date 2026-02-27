variable "bigip_host" {
  description = "F5 BIG-IP management IP address"
  type        = string
  default     = "172.16.10.10"
}

variable "bigip_username" {
  description = "F5 BIG-IP admin username"
  type        = string
  default     = "admin"
}

variable "bigip_password" {
  description = "F5 BIG-IP admin password"
  type        = string
  sensitive   = true
}

# Talos k8s node IPs
variable "k8s_nodes" {
  description = "Kubernetes node IPs (Talos)"
  type = map(string)
  default = {
    "talos-cp"     = "172.16.10.157"
    "talos-worker" = "172.16.10.160"
  }
}

# VIP assignments (172.16.20.60-80 range)
variable "vip_argocd" {
  description = "VIP for Argo CD UI"
  type        = string
  default     = "172.16.20.60"
}

variable "vip_vault" {
  description = "VIP for Vault UI"
  type        = string
  default     = "172.16.20.61"
}

variable "vip_kagent" {
  description = "VIP for kagent UI"
  type        = string
  default     = "172.16.20.62"
}

# NodePort assignments (set these after converting services to NodePort)
variable "nodeport_argocd" {
  description = "NodePort for argocd-server HTTPS"
  type        = number
  default     = 30443
}

variable "nodeport_vault" {
  description = "NodePort for vault UI"
  type        = number
  default     = 30820
}

variable "nodeport_kagent" {
  description = "NodePort for kagent UI"
  type        = number
  default     = 30808
}
