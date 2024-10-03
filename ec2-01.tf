terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
    access_key = ""
    secret_key = ""
}

# Takes input for key pair name
variable "key_name" {}
  
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generating public key pair
resource "aws_key_pair" "terraformKP" {
    key_name = var.key_name
    public_key = tls_private_key.rsa-4096.public_key_openssh
}

# Generating private key pair
resource "local_file" "private_key" {
    content = tls_private_key.rsa-4096.private_key_pem
    filename = var.key_name 
}

resource "aws_instance" "public" {
  ami           = "ami-013e83f579886baeb"
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraformKP.key_name

  tags = {
    # Name of Instance
    Name = "Public_Instance"
  }
}