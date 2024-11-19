provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable necessary GCP APIs
resource "google_project_service" "kubernetes" {
  service = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

# Create GKE Cluster
resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.zone
  initial_node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  release_channel {
    channel = "STABLE"
  }

  remove_default_node_pool = true
  initial_node_count       = 0
}

# Create a Node Pool
resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = var.zone
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

# Output Cluster Information
output "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster."
  value       = google_container_cluster.primary.name
}

output "kubernetes_cluster_endpoint" {
  description = "The endpoint of the Kubernetes cluster."
  value       = google_container_cluster.primary.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  description = "The CA certificate for the Kubernetes cluster."
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

data "google_client_config" "default" {}

# Namespace for Ingress Controller
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = var.ingress_namespace
  }
}

# Deploy NGINX Ingress Controller using Helm
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.13"  # Specify the desired version

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.nodeSelector." + "cloud.google.com/gke-nodepool"
    value = "default-pool"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  timeout = 600
}

# Namespace for Hello World Application
resource "kubernetes_namespace" "hello_world" {
  metadata {
    name = var.hello_namespace
  }
}

# Deploy Hello World Application
resource "kubernetes_deployment" "hello_world" {
  metadata {
    name      = "hello-world"
    namespace = kubernetes_namespace.hello_world.metadata[0].name
    labels = {
      app = "hello-world"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "hello-world"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-world"
        }
      }

      spec {
        container {
          name  = "hello-world"
          image = "nginx:latest"

          ports {
            container_port = 80
          }
        }
      }
    }
  }
}

# Service for Hello World Application
resource "kubernetes_service" "hello_world" {
  metadata {
    name      = "hello-world-service"
    namespace = kubernetes_namespace.hello_world.metadata[0].name
    labels = {
      app = "hello-world"
    }
  }

  spec {
    selector = {
      app = "hello-world"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Ingress for Hello World Application
resource "kubernetes_ingress" "hello_world" {
  metadata {
    name      = "hello-world-ingress"
    namespace = kubernetes_namespace.hello_world.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.hello_world.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
