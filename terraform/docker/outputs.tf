output "container_id" {
  value = docker_container.nginx.id
}

output "container_ip" {
  value = docker_container.nginx.network_data[0].ip_address
}

output "nginx_url" {
  value = "http://localhost:${var.host_port}"
}