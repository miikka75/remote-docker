resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "id_rsa"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "id_rsa.pub"
  file_permission = "0600"
}

resource "local_file" "ssh_config_file" {
    content = templatefile("${path.module}/ssh_config.tpl", {
        path_cwd = path.cwd,
        user = var.user,
        nodes = oci_core_instance._
      })
    filename = join(
      "/",
      [
        path.cwd,
        local.ssh_config_file
      ]
    )
}

locals {
  compartment_id = oci_identity_compartment._.id
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
  ssh_config_file = "ssh_${var.name}"
}
