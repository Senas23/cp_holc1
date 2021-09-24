resource "local_file" "ssh_config_aws" {
  content = templatefile("${path.module}/ssh_aws.tpl",
    {
      "bastion"   = "${aws_instance.bastion[*].public_dns}"
      "natserver" = "${aws_instance.nat_server[*].private_ip}"
  })
  filename        = pathexpand("~/.ssh/config_aws")
  file_permission = "0660"
}
