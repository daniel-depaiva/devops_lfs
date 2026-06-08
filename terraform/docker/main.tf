terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Baixar a imagem nginx
resource "docker_image" "nginx" {
  name = var.image_name
}

# Criar o container
resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = var.container_port
    external = var.host_port
  }

}
