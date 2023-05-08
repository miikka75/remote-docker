%{ for node in nodes ~}
Host ${node.display_name}
    Hostname ${node.public_ip}
    User ${user}
    IdentityFile ${path_cwd}/id_rsa
    StrictHostKeyChecking no
%{ endfor ~}
