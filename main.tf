terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "1.48.0"
    }
  }
}

# Configure the HuaweiCloud Provider with AK/SK
# This will work with a single defined/default network, otherwise you need to specify network
# to fix errors about multiple networks found.
provider "huaweicloud" {
  region     = var.region
  access_key = var.ak
  secret_key = var.sk
  auth_url   = "https://iam.${var.region}.myhuaweicloud.com/v3"
}

# Variable declaration

resource "huaweicloud_networking_secgroup" "secgroup" {
  name = "packer_secgroup"
}

resource "huaweicloud_networking_secgroup_rule" "rules" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5985
  port_range_max    = 5986
  remote_ip_prefix  = "0.0.0.0/0"
}

output "secgroup_id" {
  value = huaweicloud_networking_secgroup.secgroup.id
}

variable "ak" {}
variable "sk" {}
variable "region" {}