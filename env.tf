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
    protocol    = "${var.sg_protocol}"
    cidr_blocks = ["${var.sg_cidr}"]
  }
  ingress {
    from_port   = "${var.sg_port_2}"
    to_port     = "${var.sg_port_2}"
    protocol    = "${var.sg_protocol}"
    cidr_blocks = ["${var.sg_cidr}"]
  }
  depends_on = ["aws_vpc.test-vpc"]
}

resource "aws_instance" "test-instance" {
  ami                         = "${var.instance_ami}"
  count                       = 1
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.instance_keypair}"
  subnet_id                   = "${aws_subnet.test-subnet.id}"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.test-sg.id}"]

  tags {
    Name                 = "test-instance"
    Application          = "chef"
    AssetProtectionLevel = "99"
    Brand                = "FCTS"
    CostCenter           = "90326"
    Team                 = "FCTS Operations"
    Creator              = "NA"
  }

  depends_on = ["aws_security_group.test-sg"]
}