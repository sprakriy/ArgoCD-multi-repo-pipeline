# 1. Create the secret in Kubernetes
resource "kubernetes_secret_v1" "github_creds" {
  metadata {
    name      = "github-creds"
    namespace = "argocd"
    labels    = { "argocd.argoproj.io/secret-type" = "repository" }
  }
  data = {
    type     = "git"
    url      = "https://github.com/sprakriy"
    username = "sprakriy"
    password = var.github_token # Pass this as a sensitive variable
  }
}
