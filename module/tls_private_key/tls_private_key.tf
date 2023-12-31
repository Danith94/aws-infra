resource "tls_private_key" "ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

output "public_key_openssh" {
    value = tls_private_key.ssh.public_key_openssh
  
}

output "tls_private_key" {
    value = tls_private_key.ssh.private_key_pem
  
}

output "tls_public_key" {
    value = tls_private_key.ssh.public_key_pem
  
}