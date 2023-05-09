locals {
  packages = [
    "apt-transport-https",
    "build-essential",
    "ca-certificates",
    "containerd.io",
    "curl",
    "ddclient",
    "docker-ce",
    "jq",
    "lsb-release",
    "make",
    "python3-pip",
    "software-properties-common",
    "tmux",
    "tree",
    "unzip",
  ]
}

data "cloudinit_config" "_" {
  for_each = local.nodes

  part {
    filename     = "cloud-config.cfg"
    content_type = "text/cloud-config"
    content      = <<-EOF
      hostname: ${each.value.node_name}
      package_update: true
      package_upgrade: false
      packages:
      ${yamlencode(local.packages)}
      apt:
        sources:
          docker.list:
            source: "deb https://download.docker.com/linux/ubuntu jammy stable"
            key: |
              ${indent(8, data.http.docker_repo_key.response_body)}
      users:
      - default
      - name: ${var.user}
        primary_group: ${var.user}
        groups: docker
        home: /home/${var.user}
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
        - ${tls_private_key.ssh.public_key_openssh}
        - ${join("\n", local.authorized_keys)}
      write_files:
      - path: /home/${var.user}/.ssh/id_rsa
        defer: true
        owner: "${var.user}:${var.user}"
        permissions: "0600"
        content: |
          ${indent(4, tls_private_key.ssh.private_key_pem)}
      - path: /home/${var.user}/.ssh/id_rsa.pub
        defer: true
        owner: "${var.user}:${var.user}"
        permissions: "0600"
        content: |
          ${indent(4, tls_private_key.ssh.public_key_openssh)}
      - path: /etc/ddclient.conf
        owner: "${var.user}:${var.user}"
        permissions: "0600"
        content: "${data.template_file.ddclient.rendered}"
      EOF
  }

  part {
    filename     = "allow-inbound-traffic.sh"
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/sh
      sed -i "s/-A INPUT -j REJECT --reject-with icmp-host-prohibited//" /etc/iptables/rules.v4
      netfilter-persistent start
      chown ${var.user}:${var.user} /home/${var.user}/.ssh/authorized_keys
    EOF
  }
}

data "template_file" "ddclient" {
    template = "${file("${path.module}/ddclient.conf.tpl")}"
    vars = {
      dyfi_username = var.dyfi_username
      dyfi_password = var.dyfi_password
      dyfi_hostname = var.dyfi_hostname
    }
}

data "http" "docker_repo_key" {
  url = "https://download.docker.com/linux/debian/gpg"
}
