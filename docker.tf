
resource "null_resource" "docker_config" {
  for_each = oci_core_instance._

  provisioner "file" {
    source      = "./resources/install_docker.sh"
    destination = "/home/${var.user}/install_docker.sh"

    connection {
      type = "ssh"
      user = var.user
      host = each.value.public_ip
      private_key = tls_private_key.ssh.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/${var.user}/install_docker.sh",
    ]

    connection {
      type = "ssh"
      user = var.user
      host = each.value.public_ip
      private_key = tls_private_key.ssh.private_key_pem
    }
  }
}
