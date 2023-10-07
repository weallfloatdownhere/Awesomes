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

resource "null_resource" "minikube" {
  triggers = {
      name = var.name
  }
  provisioner "local-exec" {
    interpreter   = ["bash", "-c"]
    environment   = { KUBECONFIG = "${path.cwd}/${self.triggers.name}.kubeconfig" }
    command = <<-EOT
      minikube delete -p ${self.triggers.name}
    EOT
    on_failure    = continue
    when          = destroy
  }
}

resource "terraform_data" "provision" {
  provisioner "local-exec" {
    interpreter   = ["bash", "-c"]
    environment   = { KUBECONFIG = "${path.cwd}/${self.triggers.name}.kubeconfig" }
    command = <<-EOT
      minikube start -p ${var.name} --cpus ${var.cpus} --memory ${var.memory} --network bridge
      kubectl config view --context ${var.name} --flatten --minify > $KUBECONFIG.tmp
      mv $KUBECONFIG.tmp $KUBECONFIG
    EOT
  }
}