provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "s306022024"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

  resource "aws_instance" "ec2linux" {
  ami           = var.ami
  instance_type = var.instance_type
  
  tags = {
    Name = "ec2linux"
  }
}

resource "aws_instance" "ec2window" {
  ami           = var.amiwindows
  instance_type = var.instance_type
  #key_name = "myprivatekey.pem"
  #security_groups       = [aws_security_group.rdp_sg.name]
  
  tags = {
    Name = "ec2window"
  }
}

resource "aws_vpc" "stage" {
  cidr_block       = "172.16.0.0/22"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "stage_vpc"
  }
}

resource "aws_internet_gateway" "stagegw" {
  vpc_id = aws_vpc.stage.id

  tags = {
    Name = "stagegw"
  }
}

resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.stage.id
  cidr_block = "172.16.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.stage.id
  cidr_block = "172.16.1.0/24"
  map_public_ip_on_launch = true
  

  tags = {
    Name = "public02"
  }
}

resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.stage.id
  cidr_block = "172.16.2.0/24"
 

  tags = {
    Name = "private01"
  }
}

resource "aws_subnet" "private02" {
  vpc_id     = aws_vpc.stage.id
  cidr_block = "172.16.3.0/24"
  

  tags = {
    Name = "private02"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "nat_gw"
  }
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  ##depends_on = [aws_internet_gateway.nat_gw]
#}


  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  lifecycle {
    create_before_destroy = true
  }
}
