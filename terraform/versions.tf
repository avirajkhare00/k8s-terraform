terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4"
    }
  }

  backend "gcs" {
    bucket = "learn-k8s-avirajkhare00"
    prefix = "terraform/state"
  }
}
