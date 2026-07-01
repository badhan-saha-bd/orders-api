provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "api" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "m5.4xlarge"

  root_block_device {
    volume_type = "gp2"
    volume_size = 500
  }
}

resource "aws_security_group" "api_sg" {
  name = "api-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "orders_db" {
  engine              = "postgres"
  instance_class      = "db.m5.2xlarge"
  allocated_storage   = 100
  username            = "admin"
  password            = "MyDbPassword123"
  multi_az            = true
  skip_final_snapshot = true
}
