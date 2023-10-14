# REQ PROVIDERS
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}

# RESOURCES
resource "github_repository" "repo" {
  count = var.exists ? 1 : 0 # Conditional
  description = "Create the private Github repository"
  auto_init   = true
  archive_on_destroy = false
  name        = var.name
  visibility  = "private"
  is_template = false
}

resource "github_repository_deploy_key" "notexists" {
  count = var.exists ? 1 : 0 # Conditional
  title      = "argocd-key"
  depends_on = [github_repository.repo]
  repository = var.name
  key        = var.tls_public_key
  read_only  = "false"
}

resource "github_repository_deploy_key" "exists" {
  count = var.exists ? 0 : 1 # Conditional
  title      = "argocd-key"
  repository = var.name
  key        = var.tls_public_key
  read_only  = "false"
}

# DATA
data "github_repository" "repo" {
  full_name = "${var.owner}/${var.name}"
}


# OUTPUTS
output "http_clone_url" {
  value = data.github_repository.repo.http_clone_url
}

output "ssh_clone_url" {
  value = data.github_repository.repo.ssh_clone_url
}