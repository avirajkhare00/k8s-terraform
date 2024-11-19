variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to deploy resources in."
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "my-gke-cluster"
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster."
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}

variable "gke_version" {
  description = "GKE Kubernetes version."
  type        = string
  default     = "latest"
}

variable "ingress_namespace" {
  description = "Namespace for the Ingress Controller."
  type        = string
  default     = "ingress-nginx"
}

variable "hello_namespace" {
  description = "Namespace for the Hello World application."
  type        = string
  default     = "default"
}
