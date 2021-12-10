[all:vars]
sites=${sites}

[servers]
%{ for index, server in servers }
${server.name} ansible_host=${server.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3
%{ endfor }