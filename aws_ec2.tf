resource "aws_security_group" "bastion_group" {
  name        = "Bastion Group"
  description = "SSH for Admin"
  vpc_id      = aws_vpc.drupalvpc.id

  ingress {
    description = "Allow Admin access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.mypubip.ip}/32"]
  }

  egress {
    description      = "Allow SSH to admin"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description      = "Allow Web Browsing to admin"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description      = "Allow Web Browsing to admin"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "Bastion Group"
  }
}

resource "aws_key_pair" "drupalkey" {
  key_name   = var.drupalkey.name
  public_key = var.drupalkey.hash
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = var.amazonec2.type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.natsub[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_group.id]
  key_name                    = aws_key_pair.drupalkey.id

  user_data = <<-EOF
    #! /bin/bash
    sudo yum update -y
  EOF

  tags = {
    Name = "Bastion"
  }
}

resource "aws_security_group" "nat_group" {
  name        = "NAT Group"
  description = "NAT Group"
  vpc_id      = aws_vpc.drupalvpc.id

  ingress {
    description     = "Bastion access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_group.id]
  }

  ingress {
    description = "Drupal Subnets HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = toset([for v in aws_subnet.drupalsub[*] : v.cidr_block])
  }

  ingress {
    description = "Drupal Subnets HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = toset([for v in aws_subnet.drupalsub[*] : v.cidr_block])
  }

  egress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "NAT Group"
  }
}
resource "aws_instance" "nat_server" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = var.amazonec2.type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.natsub[0].id
  vpc_security_group_ids      = [aws_security_group.nat_group.id]
  key_name                    = aws_key_pair.drupalkey.id
  source_dest_check           = false

  user_data = file("install_iptables.sh")

  tags = {
    Name = "NAT Server"
  }
}

resource "aws_security_group" "drupallbsg" {
  name        = "Drupal Load Balancer Group"
  description = "Secure Load Balancer traffic"
  vpc_id      = aws_vpc.drupalvpc.id

  ingress {
    description      = "ingress HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ingress HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "HTTP and Health Checks to Drupal Servers"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = toset([for v in aws_subnet.drupalsub[*] : v.cidr_block])
  }

  tags = {
    Name = "Load Balancer Group"
  }
}

resource "aws_security_group" "drupalasg" {
  name        = "Drupal ASG Group"
  description = "Secure Drupal ASG"
  vpc_id      = aws_vpc.drupalvpc.id

  ingress {
    description = "ELB web traffic and health checks"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = toset([for v in aws_subnet.natsub[*] : v.cidr_block])
  }

  ingress {
    description     = "Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_group.id]
  }

  egress {
    description      = "Web Browsing"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Web Browsing"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ASG Group"
  }
}

resource "aws_launch_template" "drupal" {
  name        = "Drupal-ASG"
  description = "prod server for Drupal"

  image_id      = data.aws_ami.drupal.id
  instance_type = var.drupalec2.type
  key_name      = aws_key_pair.drupalkey.id

  vpc_security_group_ids = [aws_security_group.drupalasg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Drupal Site"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "Drupal Site"
    }
  }

  tags = {
    Name = "Drupal Site"
  }
}
