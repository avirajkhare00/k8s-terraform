output "ingress_ip" {
  description = "The external IP address of the Ingress Controller."
  value       = helm_release.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
}

output "hello_world_url" {
  description = "The URL to access the Hello World application."
  value       = "http://${helm_release.ingress_nginx.status[0].load_balancer[0].ingress[0].ip}/"
}
