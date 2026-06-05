# ArgoCD-multi-repo-pipeline
# GitOps Automation: Multi-Repo Pipeline

## 1. Pre-Tasks (Environment Bootstrap)
*Before applying Terraform, ensure the environment is initialized:*

1. **Namespace:** `oc create namespace argocd`
2. **Terraform Backend:** Initialize `backend.tf` with your S3 configuration.
3. **Secrets Management:** Create the credentials required for the controller:
   - **GitHub PAT:** `kubectl create secret generic github-creds -n argocd --from-literal=username=sprakriy --from-literal=password=$GITHUB_TOKEN --from-literal=type=git --from-literal=url=https://github.com/sprakriy`
   - **Labeling:** (Crucial!) `kubectl label secret github-creds -n argocd argocd.argoproj.io/secret-type=repo-creds`
   - **AWS Creds:** `kubectl create secret generic aws-creds -n argocd --from-literal=AWS_ACCESS_KEY_ID=... --from-literal=AWS_SECRET_ACCESS_KEY=...`

## 2. Big Picture Architecture


- **Management Plane:** Terraform manages the `ApplicationSet` controller via `kubernetes_manifest`.
- **Inventory Plane:** The `repos/` folder contains JSON files acting as the "Source of Truth" for what needs to be deployed.
- **Execution Plane:** Argo CD continuously monitors the inventory and reconciles cluster state.

## 3. Daily Operations (The "3-Step" Workflow)
*To onboard a new application, perform these three actions:*

1. **Generate:** Create `repos/<project-name>.json` with the repository URL.
2. **Commit:** `git add repos/ && git commit -m "feat: add <project-name>" && git push`
3. **Deploy:** Argo CD automatically detects the file, creates the `Application`, and initiates synchronization.

## 4. Lifecycle Maintenance
- **Destroy Operation:** To remove an application, delete the corresponding JSON file from `repos/` and `git push`. The controller will automatically prune the application from the cluster.
- **Troubleshooting:**
  - If an app is `Missing`: Verify the target repo has a valid `deployment.yaml` or `kustomization.yaml` at the root.
  - If a secret fails: Verify the label `argocd.argoproj.io/secret-type: repo-creds` exists using `oc get secret -n argocd --show-labels`.
  To resolve the problem of ArgoCD communicating with GitHub and gets a 404 error.

Here's what we need to do.

1. Update PAT PermissionsWhile you noted your PAT has "metadata READ" and "contents READ," ArgoCD requires more expansive permissions depending on how it interacts with the repository.Classic PAT: You must check the entire repo scope. This encompasses repo:status, repo_deployment, public_repo, and repo:invite.Fine-grained 
PAT: If using fine-grained tokens, explicitly ensure you have selected:Repository Permissions: Contents set to Read and write (or Read-only) 
AND Metadata set to Read-only.Repository Permissions: Pull requests set to Read-only (ArgoCD often needs to check pull request metadata/status).