variable "kubeconfig" {
  description = "Kubeconfig file to use"
  default = "~/.kube/config"
}

variable "context" {
  description = "Context to use in the kubeconfig file"
  default = "default"
}

variable "repository" {
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

provider "github" {
  owner = var.username
  token = var.token
}

provider "flux" {
  kubernetes = {
    config_path = var.kubeconfig
    config_context = var.context
  }
  git = {
    url = "https://github.com/${var.username}/${var.repository}.git"
    http = {
      github_org = var.username
      github_token = var.token
      password = var.token
      username = var.username
    }
  }
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = var.repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "this" {
  path = var.bootstrap_path
}