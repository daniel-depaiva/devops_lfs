variable "container_name" {
  default = "meu_nginx"
}

variable "image_name" {
  default = "nginx:latest"
}

variable "host_port" {
  default = 7080
}

variable "container_port" {
  default = 80
}