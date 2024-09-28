provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "server" {
  ami           = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"

 
  subnet_id = data.aws_subnet.public.id
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              EOF


  tags = {
    Name = "server"
  }
  
}