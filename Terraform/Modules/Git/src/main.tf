# ------------ REQUIREMENTS -------------
terraform {
  required_providers {
    argocd = {
      source = "oboukili/argocd"
      version = "6.0.3"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    # https://registry.terraform.io/providers/metio/git/latest/docs
    git = {
      source = "metio/git"
      version = "2023.10.13"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

# ------------- PROVIDERS --------------
# Kubernetes
provider "kubernetes" {
  config_path    = var.kubeconfig
  config_context = var.kubeconfig_context
}
# Github
provider "github" {
  owner = var.owner 
  token = var.token
}

# Bootstrapping ssh key
resource "tls_private_key" "bootstrap_tls" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# If the repo provider is Github
module "github_repo" {
  count = var.repo_provider == "github" ? 1 : 0
  source          = "./modules/github"
  owner           = var.owner
  token           = var.token
  name            = var.repo_name
  tls_public_key  = tls_private_key.bootstrap_tls.public_key_openssh
  tls_private_key = tls_private_key.bootstrap_tls.private_key_openssh
}


# Temporarly export to private key to a local file
resource "terraform_data" "tmp_private_keyfile" {
  depends_on = [ module.github_repo ]
  provisioner "local-exec" {
    command = "echo -n '${tls_private_key.bootstrap_tls.private_key_openssh}' > ${path.cwd}/private.tmp && chmod 400 ${path.cwd}/private.tmp"
  }
}


# TODO: Check if the repo already exists before doint the 2 steps below

# Temporarly clone the repository locally
resource "terraform_data" "tmp_clone_repo" {
  depends_on = [ module.github_repo ]
  provisioner "local-exec" {
    command = "ssh-agent bash -c 'ssh-add ${path.cwd}/private.tmp; git clone ${module.github_repo[0].ssh_clone_url} ${path.cwd}/argorepo'"
  }
}

# Import the initial argocd templates installation files
resource "template_dir" "config" {
  depends_on = [ terraform_data.tmp_clone_repo ]
  source_dir      = "${path.module}/templates/argocd"
  destination_dir = "${path.cwd}/argorepo/${var.repo_path}"
  # vars = {
  #   consul_addr = "${var.consul_addr}"
  # }
}

resource "git_add" "glob_pattern" {
  depends_on = [ template_dir.config ]
  directory = "${path.cwd}/argorepo"
  add_paths = [ dirname("${path.cwd}/argorepo/${var.repo_path}") ]
}

resource "git_commit" "commit" {
  depends_on = [ git_add.glob_pattern ]
  directory = "${path.cwd}/argorepo"
  message   = "Terraform bootstraping initial commit"
  author = {
    name  = "terraform"
    email = "terraform@argocd.com"
  }
}

# Pushing the rendered files to the remote repository source
resource "git_push" "remote" {
  depends_on = [ git_commit.commit ]
  directory = "${path.cwd}/argorepo"
  refspecs  = ["refs/heads/main:refs/heads/main"]

  auth = {
    ssh_key = {
      private_key_path  = "${path.cwd}/private.tmp"
    }
  }
}




# Create the initial `argocd` namespace
resource "kubernetes_namespace" "argocd" {
  depends_on = [ module.github_repo ]
  metadata {
    name = "argocd"
  }
}

# Create the initial repository credential secret
resource "kubernetes_secret" "bootstrap_repo_sshcreds" {
  depends_on = [ kubernetes_namespace.argocd ]
  metadata {
    name      = "argocd-bootstrap-repo-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }
  data = {
    url           = base64encode("${module.github_repo[0].ssh_clone_url}")
    sshPrivateKey = base64encode("${tls_private_key.bootstrap_tls.private_key_openssh}")
    name          = base64encode("bootstrap-repo")
    type          = base64encode("git")
  }
}




# --------------- OUTPUT ----------------
# Git ssh cloning url
output "git_repo" {
  value =  module.github_repo[0].ssh_clone_url
}