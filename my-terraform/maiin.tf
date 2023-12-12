provider "aws" {
  region = "eu-west-2"
}
terraform {
  backend "s3" {
    bucket = "webhost-myaws"
    key = "./tf/terraform.tfstate"
    region = "eu-west-2"
  }
}


# Creating an IAM role for EC2
resource "aws_iam_role" "cicd-iam" {
  name = "Unique-EC2-ECR-AUTH"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Creating an IAM instance profile
resource "aws_iam_instance_profile" "cicd-iam-profile" {
  name = "specail-cicd-iam-role"
  role = aws_iam_role.cicd-iam.name
}

# Creating my security group
resource "aws_security_group" "ec2-sg" {
  name        = "my-ec2-security-group"
  description = "Allow inbound traffic on ports 22 and 80"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating an EC2 instance
resource "aws_instance" "cicd-ec2" {
  ami                    = "ami-0505148b3591e4c07"
  instance_type          = "t2.micro"
  key_name               = "test2"
  iam_instance_profile   = aws_iam_instance_profile.cicd-iam-profile.name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = "ubuntu"
    timeout  = "4m"
  }

  tags = {
    Name = "ec2-cicd"
  }
}

output "instance_public_ip" {
  value = aws_instance.cicd-ec2.public_ip
  sensitive = true
}



