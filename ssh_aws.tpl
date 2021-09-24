%{ for host in bastion ~}
Host ${host}
  Hostname ${host}
  User ec2-user
  Port 22
  IdentityFile ~/.ssh/id_rsa
%{ endfor ~}

%{ for host in bastion ~}
Match host natserver exec "nc -z -w 1 ${host} 22"
  ProxyJump ${host}
%{ endfor ~}

%{ for ip in natserver ~}
Host natserver
  Hostname ${ip}
  User ec2-user
%{ endfor ~}
