variable "vpc_cidr" {
  default = "192.168.0.0/24"
}
variable "subnet_cidr" {
  default = "192.168.0.1/25"
}
variable "sg_cidr" {
  default = "185.63.117.3/32"
}
variable "sg_protocol" {
  default = "TCP"
}
variable "sg_port_1" {
  default = 22
}
variable "sg_port_2" {
  default = 80
}
variable "instance_ami"{
  default = "ami-031b0f67"
}
variable "instance_type"{
  default = "t2.micro"
}
variable "instance_keypair"{
  default = "research"
}
