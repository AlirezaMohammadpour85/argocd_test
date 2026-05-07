variable "argocd_server_addr" {
  description = "Argo CD API server address."
  type        = string
  default     = "localhost:8080"
}

variable "argocd_username" {
  description = "Argo CD username."
  type        = string
  default     = "admin"
}

variable "argocd_password" {
  description = "Argo CD password."
  type        = string
  sensitive   = true
}

variable "argocd_insecure" {
  description = "Allow insecure TLS when connecting to Argo CD."
  type        = bool
  default     = true
}
