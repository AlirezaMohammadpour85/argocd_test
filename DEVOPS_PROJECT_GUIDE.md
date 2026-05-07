# DevOps Project Guide

## Project purpose

This repository is a lightweight GitOps lab for learning and practicing Argo CD, Kubernetes manifests, and Terraform-based Argo CD automation.

The current application is a simple NGINX workload. It is useful for testing the full DevOps flow:

1. Define Kubernetes resources in Git.
2. Let Argo CD watch the repository.
3. Sync changes from Git into the Kubernetes cluster.
4. Optionally manage the Argo CD `Application` object with Terraform.

## Current structure

```text
argocd_test/
├── app1/
│   ├── nginx.yml
│   ├── nginx_svc.yml
│   └── argo_app.yml
├── terraform_argocd/
│   ├── provider.tf
│   └── .terraform.lock.hcl
├── README.md
├── .gitignore
└── argocd-gitops-structure-notes.md
```

## Components

### Kubernetes application

The application manifests live in `app1/`.

- `nginx.yml` creates an NGINX `Deployment`.
- `nginx_svc.yml` exposes the deployment with a `ClusterIP` service.
- `argo_app.yml` defines an Argo CD `Application` that points Argo CD to this repository path.

### Argo CD

Argo CD is responsible for continuously syncing the desired state from Git into Kubernetes.

The current Argo CD application points to:

```text
repo: https://github.com/AlirezaMohammadpour85/argocd_test.git
path: app1
target revision: main
destination namespace: default
```

### Terraform

The `terraform_argocd/` directory contains Terraform configuration for creating an Argo CD application through the Argo CD provider.

This allows the Argo CD application itself to be managed as infrastructure as code.

## Typical workflow

1. Update Kubernetes manifests in `app1/`.
2. Commit and push changes to GitHub.
3. Argo CD detects the Git change.
4. Argo CD syncs the change into Kubernetes.
5. Verify the result with `kubectl` and the Argo CD UI.

Useful commands:

```bash
kubectl get pods
kubectl get svc
kubectl get applications -n argocd
```

For Terraform:

```bash
cd terraform_argocd
terraform init
terraform plan
terraform apply
```

## Fast-growing DevOps improvements

As this project grows, use this roadmap to keep it clean and scalable.

### 1. Separate applications from Argo CD definitions

Recommended future layout:

```text
argocd_test/
├── apps/
│   └── app1/
│       ├── deployment.yaml
│       └── service.yaml
├── argocd/
│   └── app1-application.yaml
└── terraform_argocd/
```

This keeps real Kubernetes workloads separate from Argo CD control-plane objects.

### 2. Remove hardcoded secrets

Do not store passwords, tokens, kubeconfigs, or private keys in Git.

Move sensitive Terraform values to:

- environment variables
- `terraform.tfvars` ignored by Git
- a secret manager
- CI/CD protected variables

### 3. Add environments

For real projects, create clear environment boundaries:

```text
environments/
├── dev/
├── staging/
└── prod/
```

Each environment should have its own namespace, sync policy, and configuration values.

### 4. Add CI validation

Before changes reach Argo CD, validate them in CI.

Good early checks:

- YAML syntax validation
- Kubernetes manifest validation
- Terraform formatting
- Terraform validation
- secret scanning

Example commands:

```bash
terraform fmt -check
terraform validate
kubectl apply --dry-run=client -f app1/
```

### 5. Add release discipline

Use pull requests for changes and require review before merging into `main`.

Recommended branch flow:

```text
feature branch -> pull request -> review -> merge to main -> Argo CD sync
```

### 6. Improve observability

For each application, track:

- deployment status
- pod health
- service availability
- Argo CD sync status
- Argo CD health status

Useful commands:

```bash
kubectl describe deployment nginx-deployment
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Security notes

- Never commit Terraform state files.
- Never commit kubeconfig files.
- Never commit Argo CD admin passwords.
- Rotate any password that was previously committed.
- Prefer short-lived credentials in CI/CD.

## Goal

The goal of this project is to build strong DevOps habits with a simple application first, then grow toward a clean GitOps structure that supports multiple apps, multiple environments, review-based delivery, and automated validation.
