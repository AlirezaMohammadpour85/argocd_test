# Argo CD GitOps Repository Structure Notes

## 1. Key idea

In Argo CD, there are two different things:

```yaml
metadata:
  namespace: argocd
```

This means the **Argo CD Application object** is stored in the `argocd` namespace.

```yaml
spec:
  destination:
    namespace: default
```

This means the **real Kubernetes application resources** are deployed into the `default` namespace.

So usually:

```text
Argo CD Application object lives in: argocd
Your real app resources live in: default, dev, staging, prod, etc.
```

---

## 2. Beginner-friendly structure

For learning and small projects, this structure is clean and standard:

```text
argocd_test/
├── apps/
│   ├── app1/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   │
│   ├── app2/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   │
│   └── app3/
│       ├── deployment.yaml
│       └── service.yaml
│
└── argocd/
    ├── app1-application.yaml
    ├── app2-application.yaml
    └── app3-application.yaml
```

Meaning:

```text
apps/     → real Kubernetes manifests
argocd/   → Argo CD Application definitions
```

You do **not** need an Argo CD subfolder inside every app folder.

---

## 3. Example Argo CD Application for `app1`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app1
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/AlirezaMohammadpour85/argocd_test.git
    targetRevision: main
    path: apps/app1
  destination:
    server: https://kubernetes.default.svc
    namespace: default
```

Important parts:

```yaml
metadata:
  namespace: argocd
```

This stores the Argo CD `Application` object in the `argocd` namespace.

```yaml
source:
  path: apps/app1
```

This tells Argo CD which folder in Git to sync.

```yaml
destination:
  namespace: default
```

This tells Argo CD where to deploy the real Kubernetes resources.

---

## 4. Applying Argo CD Application files

You can apply one application:

```bash
kubectl apply -f argocd/app1-application.yaml
```

Or apply all application definitions:

```bash
kubectl apply -f argocd/
```

Then Argo CD will watch the paths defined in the `Application` objects.

For example:

```yaml
source:
  path: apps/app1
```

means Argo CD watches only:

```text
apps/app1/
```

It does not automatically apply files from:

```text
argocd/
```

unless you create another Argo CD Application to watch that folder.

---

## 5. What to avoid as a beginner

Avoid putting the Argo CD `Application` YAML inside the same folder that Argo CD syncs.

Avoid this for now:

```text
apps/app1/
├── deployment.yaml
├── service.yaml
└── app1-application.yaml
```

If your Argo CD Application has:

```yaml
source:
  path: apps/app1
```

then Argo CD will also try to sync the `Application` object itself.

This can work, but it is more advanced and can be confusing at the beginning.

---

## 6. Production-style structure

For small and medium production setups, this is acceptable:

```text
repo/
├── apps/
│   ├── app1/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── app2/
│       ├── deployment.yaml
│       └── service.yaml
│
└── argocd/
    ├── app1-application.yaml
    └── app2-application.yaml
```

But larger production environments usually organize by environment.

Example:

```text
gitops-repo/
├── applications/
│   ├── dev/
│   │   ├── app1.yaml
│   │   └── app2.yaml
│   ├── staging/
│   │   ├── app1.yaml
│   │   └── app2.yaml
│   └── prod/
│       ├── app1.yaml
│       └── app2.yaml
│
└── manifests/
    ├── app1/
    │   ├── base/
    │   │   ├── deployment.yaml
    │   │   └── service.yaml
    │   └── overlays/
    │       ├── dev/
    │       ├── staging/
    │       └── prod/
    │
    └── app2/
        ├── base/
        └── overlays/
            ├── dev/
            ├── staging/
            └── prod/
```

Meaning:

```text
applications/   → Argo CD Application objects
manifests/      → Kubernetes manifests, Kustomize overlays, or Helm charts
```

---

## 7. Example production Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app1-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR_ORG/gitops-repo.git
    targetRevision: main
    path: manifests/app1/overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: app1-prod
```

Here:

```yaml
path: manifests/app1/overlays/prod
```

means Argo CD deploys the production version of `app1`.

```yaml
namespace: app1-prod
```

means the real Kubernetes app is deployed into the `app1-prod` namespace.

---

## 8. More advanced production concepts to learn next

After understanding the basic structure, learn these topics:

### 8.1 Kustomize base and overlays

Used to manage differences between dev, staging, and production.

Example:

```text
manifests/app1/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

### 8.2 App-of-apps pattern

One parent Argo CD Application manages many child Applications.

This is useful when you want Argo CD to automatically create and manage all app definitions from Git.

### 8.3 Argo CD Projects / AppProjects

Used to control which teams or apps can deploy to which clusters, namespaces, and repositories.

### 8.4 Auto-sync

Argo CD automatically applies changes from Git.

Example:

```yaml
syncPolicy:
  automated: {}
```

### 8.5 Prune

Argo CD deletes Kubernetes resources that were removed from Git.

Example:

```yaml
syncPolicy:
  automated:
    prune: true
```

### 8.6 Self-heal

Argo CD corrects manual changes made directly in the cluster.

Example:

```yaml
syncPolicy:
  automated:
    selfHeal: true
```

### 8.7 Secrets management

Common tools:

```text
Sealed Secrets
External Secrets Operator
SOPS
HashiCorp Vault
```

### 8.8 Image update strategy

How new container image versions are promoted to dev, staging, and production.

Common options:

```text
Manual Git commit with new image tag
Argo CD Image Updater
CI pipeline opens pull request
```

---

## 9. Recommended learning path

Start with this simple structure:

```text
argocd_test/
├── apps/
│   └── app1/
└── argocd/
    └── app1-application.yaml
```

Then move to:

```text
apps/app1/base
apps/app1/overlays/dev
apps/app1/overlays/prod
```

Then learn:

```text
App-of-apps
AppProjects
Auto-sync
Prune
Self-heal
Secrets
```

---

## 10. Final recommendation

For your current Kind lab, use this:

```text
argocd_test/
├── apps/
│   └── app1/
│       ├── deployment.yaml
│       └── service.yaml
│
└── argocd/
    └── app1-application.yaml
```

This is simple, clean, and close to real production GitOps structure.

Later, when you understand the basics, upgrade to environment-based folders and Kustomize overlays.
