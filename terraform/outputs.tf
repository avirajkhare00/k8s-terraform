data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.ingress_namespace
  }

  depends_on = [helm_release.ingress_nginx]
}

output "ingress_ip" {
  value = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
}

output "hello_world_url" {
  value = "http://${data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip}/"
}
