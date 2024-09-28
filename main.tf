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

  security_groups = [aws_security_group.allow_ssh.id]
  subnet_id = data.aws_subnet.public.id
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              EOF


  tags = {
    Name = "server"
  }
  
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Security group to allow SSH access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
    ingress {
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_security_group"
  }
}