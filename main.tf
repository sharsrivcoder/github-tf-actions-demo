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
