terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
  }
  # Recommended for lifecycle management (state persistence)
  backend "s3" {
    bucket = "sp-01102026-aws-kub"
    key    = "argocd/dynamic-terraform-runner.tfstate"
    region = "us-east-1"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # Or use EKS/AKS auth
  config_context = "k3d-platform-test"
}
