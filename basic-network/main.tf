provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "otofu-tf-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "otofu-tf-vpc"
  }
}

resource "aws_subnet" "otofu-public-web" {
  vpc_id                  = "${aws_vpc.otofu-tf-vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags {
    Name = "otofu-tf-public-web"
  }
}

resource "aws_internet_gateway" "otofu-gw" {
  vpc_id = "${aws_vpc.otofu-tf-vpc.id}"
  tags {
    Name = "otofu-tf-gw"
  }
}

resource "aws_route_table" "otofu-public-rtb" {
  vpc_id = "${aws_vpc.otofu-tf-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.otofu-gw.id}"
  }
  tags {
    Name = "otofu-tf-rtb"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.otofu-public-web.id}"
  route_table_id = "${aws_route_table.otofu-public-rtb.id}"
}

resource "aws_security_group" "app" {
  name        = "otofu-tf-web"
  description = "It is a security group on http of otofu-tf-vpc"
  vpc_id      = "${aws_vpc.otofu-tf-vpc.id}"
  tags {
    Name = "tf_web"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_instance" "otofu-tf-instance" {
  ami                         = "ami-374db956"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.app.id}"]
  subnet_id                   = "${aws_subnet.otofu-public-web.id}"
  associate_public_ip_address = "true"
  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }
  ebs_block_device = {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }
}
