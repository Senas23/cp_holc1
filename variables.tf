variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "drupalvpc" {
  type = object({
    cidr_prim = string
    cidr_sec  = string
    tag       = string
  })
  default = {
    cidr_prim = "192.168.1.0/24"
    cidr_sec  = "192.168.0.0/24"
    tag       = "DrupalVPC"
  }
}

variable "drupalsub" {
  type = list(object({
    cidr  = string
    az_id = string
    tag   = string
  }))
  default = [{
    az_id = "use1-az1"
    cidr  = "192.168.1.64/26"
    tag   = "Drupalsub1a"
    }, {
    az_id = "use1-az2"
    cidr  = "192.168.1.128/26"
    tag   = "Drupalsub1b"
    }
  ]
}

variable "natsub" {
  type = list(object({
    cidr  = string
    az_id = string
    tag   = string
  }))
  default = [{
    az_id = "use1-az1"
    cidr  = "192.168.0.64/26"
    tag   = "NATsub1a"
    }, {
    az_id = "use1-az2"
    cidr  = "192.168.0.128/26"
    tag   = "NATsub1b"
  }]
}

variable "drupaligw" {
  type = object({
    tag = string
  })
  default = {
    tag = "DrupalIGW"
  }
}

variable "amazonec2" {
  type = object({
    type = string
  })
  default = {
    type = "t2.micro"
  }
}

variable "drupalec2" {
  type = object({
    type = string
  })
  default = {
    type = "t2.micro"
  }
}

variable "drupalkey" {
  type = object({
    name = string
    hash = string
  })
  default = {
    name = "drupalkey"
    hash = "<SSH KEY>"
  }
}

locals {
  mypubip = jsondecode(data.http.mypubip.body)
}
