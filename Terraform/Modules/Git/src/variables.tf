# owner              = "myusergit"
# token              = "ghp_c0a0a0a0a00a0a0a0a0aa0"
# kubeconfig         = "./cluster.kubeconfig"
# kubeconfig_context = "default"
# repo_name          = "argocd-sample"
# repo_exists        = true
# repo_provider      = "github"

variable "token" {
  description = "Token to use as credentials for log in the repository"
}

variable "owner" {
  description = "Owner of the argocd gitops repository"
}

variable "repo_exists" {
  description = "Specify if the repository already exists"
  type        = bool
}

variable "repo_provider" {
  description = "Git repository host provider"
  validation {
    condition     = contains(["github", "gitlab", "bitbucket", "azuredevop"], var.repo_provider)
    error_message = "Valid values for var: provider are (github, gitlab, bitbucket, azuredevop)."
  } 
}

variable "repo_name" {
  description = "Repository name"
  default     = "argocd-mothership"
}

variable "repo_path" {
  description = "Path where the bootstrap directory will be created in the repository"
  default     = ""
}

variable "kubeconfig" {
  description = "Cluster kubeconfig file local path"
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Context to use from the kubeconfig file"
  default     = "default"
}