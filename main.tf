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

resource "aws_subnet" "public_web" {
  vpc_id                  = "${aws_vpc.otofu-tf-vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags {
    Name = "otofu-tf-public-web"
  }
}

resource "aws_instance" "otofu-tf-instance" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
