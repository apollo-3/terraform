variable access_key {}
variable secret_key {}
variable region {}

variable "vpc_cidr" {}
variable "subnet_cidr" {}
variable "sg_cidr" {}
variable "sg_port_1" {}
variable "sg_port_2" {}
variable "instance_ami" {}
variable "instance_type" {}
variable "instance_keypair" {}
variable "tag_AssetProtectionLevel" {}
variable "tag_Brand" {}
variable "tag_CostCenter" {}
variable "tag_Team" {}
variable "tag_Creator" {}
variable "ssh_user" {}
variable "chef-server-script" {}
variable "chef-server-script-dest" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "test-vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test-subnet" {
  vpc_id     = "${aws_vpc.test-vpc.id}"
  cidr_block = "${var.subnet_cidr}"
  tags {
    Name = "test-subnet"
  }
  depends_on = ["aws_vpc.test-vpc"]
}

resource "aws_internet_gateway" "test-gw" {
  vpc_id = "${aws_vpc.test-vpc.id}"
  tags {
    Name = "test-gw"
  }
  depends_on = ["aws_vpc.test-vpc"]
}

resource "aws_route_table" "test-route-table" {
  vpc_id          = "${aws_vpc.test-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-gw.id}"
  }
  tags {
    Name = "test-route-table"
  }
  depends_on = ["aws_vpc.test-vpc", "aws_internet_gateway.test-gw"]
}

resource "aws_route_table_association" "associate_route_table" {
  subnet_id      = "${aws_subnet.test-subnet.id}"
  route_table_id = "${aws_route_table.test-route-table.id}"
}

resource "aws_security_group" "test-sg" {
  name        = "test-sg"
  vpc_id      = "${aws_vpc.test-vpc.id}"
  ingress {
    from_port   = "${var.sg_port_1}"
    to_port     = "${var.sg_port_1}"
    protocol    = "TCP"
    cidr_blocks = ["${var.sg_cidr}"]
  }
  ingress {
    from_port   = "${var.sg_port_2}"
    to_port     = "${var.sg_port_2}"
    protocol    = "TCP"
    cidr_blocks = ["${var.sg_cidr}"]
  }
  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = ["aws_vpc.test-vpc"]
}

resource "aws_instance" "test-chef-server" {
  ami                         = "${var.instance_ami}"
  count                       = 1
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.instance_keypair}"
  subnet_id                   = "${aws_subnet.test-subnet.id}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.test-sg.id}"]
  tags {
    Name                 = "test-chef-server"
    Application          = "chef-server"
    AssetProtectionLevel = "${var.tag_AssetProtectionLevel}"
    Brand                = "${var.tag_Brand}"
    CostCenter           = "${var.tag_CostCenter}"
    Team                 = "${var.tag_Team}"
    Creator              = "${var.tag_Creator}"
  }
  depends_on = ["aws_security_group.test-sg"]

  connection {
    type        = "ssh"
    host        = "${aws_instance.test-chef-server.public_ip}"
    user        = "${var.ssh_user}"
    private_key = "${file("${var.instance_keypair}.pem")}"
  }
  provisioner "file" {
    source      = "${var.chef-server-script}"
    destination = "${var.chef-server-script-dest}"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 755 ${var.chef-server-script-dest}",
      "sudo ${var.chef-server-script-dest}"
    ]
  }
}

resource "aws_instance" "test-db" {
  ami                         = "${var.instance_ami}"
  count                       = 1
  instance_type               = "t2.micro"
  key_name                    = "${var.instance_keypair}"
  subnet_id                   = "${aws_subnet.test-subnet.id}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.test-sg.id}"]
  tags {
    Name                 = "test-db"
    Application          = "chef-client"
    AssetProtectionLevel = "${var.tag_AssetProtectionLevel}"
    Brand                = "${var.tag_Brand}"
    CostCenter           = "${var.tag_CostCenter}"
    Team                 = "${var.tag_Team}"
    Creator              = "${var.tag_Creator}"
  }
  depends_on = ["aws_security_group.test-sg"]
}

output "chef-server-ip" {
  value = "${aws_instance.test-chef-server.public_ip}"
}
output "chef-server-private-dns" {
  value = "${aws_instance.test-chef-server.private_dns}"
}
output "test-db-ip" {
  value = "${aws_instance.test-db.public_ip}"
}
output "test-db-private-dns" {
  value = "${aws_instance.test-db.private_dns}"
}