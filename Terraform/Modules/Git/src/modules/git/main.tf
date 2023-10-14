variable "repo_url" {
  description = "Git cloning url"
}

variable "private_key" {
  description = "SSH Private key"
}

# Import the private key locally
# resource "terraform_data" "bootstrap_private_keyfile" {
#   provisioner "local-exec" {
#     command = "printf '${tls_private_key.bootstrap_tls.private_key_openssh}' > ${path.cwd}/private.pem"
#   }
# }
# # Import the public cert locally
# resource "terraform_data" "bootstrap_public_keyfile" {
#   provisioner "local-exec" {
#     command = "printf '${tls_private_key.bootstrap_tls.public_key_openssh}' > ${path.cwd}/public.crt"
#   }
# }