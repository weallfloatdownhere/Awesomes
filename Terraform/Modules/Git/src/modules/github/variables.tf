variable "token" {
  description = "Token to use as credentials for log in the repository"
  default     = ""
}

variable "owner" {
  description = "Owner of the argocd gitops repository"
  default     = ""
}

variable "name" {
  description = "Repository name"
  default     = ""
}

variable "exists" {
  description = "Specify if the repository already exists"
  default     = false
  type        = bool
}

variable "tls_private_key" {
  description = "TLS Private key to add to the repository trusted keys"
  default     = ""
}

variable "tls_public_key" {
  description = "TLS Public key part to export"
  default     = ""
}