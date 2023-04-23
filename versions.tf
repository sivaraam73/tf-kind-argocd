# versions.tf

terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.0.17"
    }

    kubectl = {
        source = "gavinbunney/kubectl"
        version = ">= 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = ">= 1.4.0"
}