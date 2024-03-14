terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.36.0"
    }
  }
}

provider "huaweicloud" {
  access_key = var.ak
  secret_key = var.sk
  region     = var.region
}

resource "huaweicloud_vpc" "vpc" {
  name = "SAP_VPC"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet" {
  name              = "SAP_Subnet_Windows"
  cidr              = "192.168.0.0/24"
  gateway_ip        = "192.168.0.1"
  vpc_id            = huaweicloud_vpc.vpc.id
  availability_zone = "la-south-2a"
}

resource "huaweicloud_networking_secgroup" "secgroup" {
  name = "SAP_Secgroup"
}

resource "huaweicloud_networking_secgroup_rule" "rules" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5985
  port_range_max    = 8986
  remote_ip_prefix  = "0.0.0.0/0"
}

variable "WINIMGNAME" {}
variable "ak" {}
variable "sk" {}
variable "region" {}

data "huaweicloud_images_image" "myimage" {
  name       = var.WINIMGNAME
  visibility = "private"
}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = "la-south-2a"
  performance_type  = "normal"
  cpu_core_count    = 8
  memory_size       = 16
}


resource "huaweicloud_compute_instance" "basic" {
  name               = "SAP_Windows"
  image_id           = data.huaweicloud_images_image.myimage.id
  flavor_id          = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup.id]
  availability_zone  = "la-south-2a"

  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
}