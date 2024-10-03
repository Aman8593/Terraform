terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Add the provider block to declare we will use the AWS provider and set the region
provider "aws" {
  region     = "ap-south-1"
  access_key = ""
  secret_key = ""
}

# Create an IAM role named “example-role” using the aws_iam_role resource
resource "aws_iam_role" "example_role" {
  name = "examplerole"
    # assume_role_policy attribute specifies the trust policy, allowing EC2 instances to assume this role
    # "Service": "*" to allow all services for sts
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach an AWS-managed policy, “AmazonS3ReadOnlyAccess,” to the role using the aws_iam_role_policy_attachment resource
resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = "arn:aws:iam::aws:policy/"
}

resource "s3BucketName" "example_bucket_policy" {
  bucket = "cloud-magdalene"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::767397699760:user/terraform-user:role/${aws_iam_role.example_role.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::cloud-magdalene/*",
          "arn:aws:s3:::cloud-magdalene"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}