data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.ingress_namespace
  }
}

output "ingress_ip" {
  description = "The external IP address of the Ingress Controller."
  value       = data.kubernetes_service.ingress_nginx.status.load_balancer.ingress[0].ip
}

output "hello_world_url" {
  description = "The URL to access the Hello World application."
  value       = "http://${data.kubernetes_service.ingress_nginx.status.load_balancer.ingress[0].ip}/"
}
