resource "kubernetes_manifest" "dynamic_terraform_runner" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata   = { name = "dynamic-terraform-runner", namespace = "argocd" }
    spec = {
      goTemplate = true
      generators = [
        {
          git = {
            repoURL  = "https://github.com/sprakriy/ArgoCD-multi-repo-pipeline.git"
            revision = "main"
            files    = [{ path = "repos/*.json" }]
          }
        }
      ]
template = {
        metadata = {
          # Argo CD will render this at runtime. 
          # We avoid complex logic here to keep Terraform happy.
          name = "terraform-{{.path.filename}}"
        }
        spec = {
          project = "default"
          source = {
            repoURL        = "{{.url}}"
            targetRevision = "main"
            path           = "."
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "default"
          }
        }
      } 
    }
  }
}