# argocd_test

This repository is a small GitOps lab for testing Argo CD, Kubernetes manifests, and Terraform-managed Argo CD applications.

## Structure

```text
apps/app1/          Kubernetes manifests for the NGINX app
argocd/             Argo CD Application manifests
terraform_argocd/   Terraform config for managing Argo CD
```

Start with [DEVOPS_PROJECT_GUIDE.md](DEVOPS_PROJECT_GUIDE.md) for the workflow, security notes, and growth roadmap.
