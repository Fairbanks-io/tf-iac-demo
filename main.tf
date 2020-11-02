terraform {
  backend "remote" {
    organization = "Fairbanks-io"

    workspaces {
      name = "tf-iac-demo"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 1.22.2"
    }
    cloudflare = {
      # Source is required for providers in other namespaces, to avoid ambiguity.
      source  = "cloudflare/cloudflare"
      version = "~> 2.11.0"
    }
    kubernetes = {
      # Source is required for providers in other namespaces, to avoid ambiguity.
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
    helm = {
      # Source is required for providers in other namespaces, to avoid ambiguity.
      source  = "hashicorp/helm"
      version = "~> 1.3.0"
    }
  }
}