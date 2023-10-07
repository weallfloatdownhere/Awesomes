variable "kubeconfig" {
  description = "Kubeconfig file to use"
  default = "~/.kube/config"
}

variable "context" {
  description = "Context to use in the kubeconfig file"
  default = "default"
}

variable "reponame" {
  description = "Repository name"
}

variable "username" {
  description = "Username/Owner/Organization to use as credentials for log in the repository"
}

variable "token" {
  description = "Password/Token to use as credentials for log in the repository"
}

variable "bootstrap_path" {
  description = "Path to boostrap in the repository relative to the root directory"
}