output "ssh-with-docker-user" {
  value = join(
    "\n",
    concat(
      [format(
        "\nAdd following line to ~/.ssh/config file:\nInclude %s\nThen...",
        local_file.ssh_config_file.filename,
      )],
      [for i in oci_core_instance._ :
        format(
          "ssh %s\n(OR ssh -l %s -p 22 -i id_rsa.pub %s)",
          i.display_name,
          var.user,
          i.public_ip
        )
      ]
    )
  )
}
