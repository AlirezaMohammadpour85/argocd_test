terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.15.3"
    }
  }
}

provider "argocd" {
  server_addr = var.argocd_server_addr
  username    = var.argocd_username
  password    = var.argocd_password
  insecure    = var.argocd_insecure
}

resource "argocd_application" "app1_tf" {
  metadata {
    name      = "app1-terraform"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/AlirezaMohammadpour85/argocd_test.git"
      target_revision = "main"
      path            = "apps/app1"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "terraform-app1"
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
      sync_options = ["CreateNamespace=true"]
    }
  }
}
