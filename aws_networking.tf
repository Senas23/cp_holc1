resource "aws_vpc" "drupalvpc" {
  cidr_block           = var.drupalvpc.cidr_prim
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.drupalvpc.tag
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.drupalvpc.id
  cidr_block = var.drupalvpc.cidr_sec
}

resource "aws_subnet" "drupalsub" {
  count                = length(var.drupalsub)
  vpc_id               = aws_vpc.drupalvpc.id
  cidr_block           = var.drupalsub[count.index].cidr
  availability_zone_id = var.drupalsub[count.index].az_id

  tags = {
    Name = var.drupalsub[count.index].tag
  }
}

resource "aws_subnet" "natsub" {
  count                = length(var.natsub)
  vpc_id               = aws_vpc.drupalvpc.id
  cidr_block           = var.natsub[count.index].cidr
  availability_zone_id = var.natsub[count.index].az_id

  tags = {
    Name = var.natsub[count.index].tag
  }
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
}

resource "aws_internet_gateway" "drupaligw" {
  vpc_id = aws_vpc.drupalvpc.id

  tags = {
    Name = var.drupaligw.tag
  }
}

resource "aws_route" "drupalvpcdefaultroute" {
  route_table_id         = aws_vpc.drupalvpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.drupaligw.id
}

resource "aws_route_table" "natrt" {
  vpc_id = aws_vpc.drupalvpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat_server.id
  }

  tags = {
    Name = "NATrt"
  }
}

resource "aws_route_table_association" "drupalsub" {
  count          = length(aws_subnet.drupalsub)
  subnet_id      = aws_subnet.drupalsub[count.index].id
  route_table_id = aws_route_table.natrt.id
}
