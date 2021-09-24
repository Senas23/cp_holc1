output "bastion_ip_addr" {
  value = aws_instance.bastion.public_ip
}

output "bastion_dns" {
  value = aws_instance.bastion.public_dns
}

output "natserver_ssh" {
  value = "ssh natserver"
}

output "drupal_ami" {
  value = data.aws_ami.drupal.id
}

output "amazon_ami" {
  value = data.aws_ami.amazon.image_id
}

output "my_pub_ip" {
  value = local.mypubip.ip
}

