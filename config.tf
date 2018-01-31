variable "vpc_cidr" {
 default = "192.168.0.0/24"
}
variable "subnet_cidr" {
  default = "192.168.0.0/25"
}
variable "sg_cidr" {
  default = "185.63.117.0/29"
}
variable "sg_port_1" {
  default = 22
}
variable "sg_port_2" {
  default = 443
}
variable "instance_ami" {
  default = "ami-031b0f67"
}
variable "instance_type" {
  default = "t2.small"
}
variable "instance_keypair" {
  default = "research"
}

variable "tag_AssetProtectionLevel" {
  default = "99"
}
variable "tag_Brand" {
  default = "FCTS"
}
variable "tag_CostCenter" {
  default = "90326"
}
variable "tag_Team" {
  default = "FCTS Operations"
}
variable "tag_Creator" {
  default = "NA"
}

variable "ssh_user" {
  default = "centos"
}
variable "chef-server-script" {
  default = "scripts/chef-server.sh"
}
variable "chef-server-script-dest" {
  default = "/tmp/chef-server.sh"
}