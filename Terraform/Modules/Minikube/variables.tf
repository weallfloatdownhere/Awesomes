variable "name" {
  type     = string
  default  = "minikube"
  nullable = false
}

variable "cpus" {
  type    = number
  default = 2
  nullable = false
}

variable "memory" {
  type    = number
  default = 3096
  nullable = false
}
