terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.1.1"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}