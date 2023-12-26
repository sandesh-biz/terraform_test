terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_iam_role" "redb_role" {
  name = "redb_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "Service": [
                    "redshift-serverless.amazonaws.com",
                    "redshift.amazonaws.com",
                    "s3.amazonaws.com"  
                ]
        }
      },
    ]
  })

  tags = {
    tag-key = "redshift-s3-test-role"
  }
}


resource "aws_iam_role_policy_attachment" "attach-s3-access" {
  role       = aws_iam_role.redb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_iam_role_policy_attachment" "attach-redshift-access" {
  role       = aws_iam_role.redb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"
}

resource "aws_s3_bucket" "redb_bucket_res" {
  bucket = "redb-bucket"

  tags = {
    Name        = "ReDB Bucket"
    Environment = "Dev"
  }
}

resource "aws_redshiftserverless_namespace" "redb_namespace_res" {
  namespace_name = "redb-namespace"
  admin_username = "admin"
  admin_user_password = "DummyDummy123"
  db_name = "dev"
  iam_roles = [ "${aws_iam_role.redb_role.arn}" ]
  default_iam_role_arn = "${aws_iam_role.redb_role.arn}"
}

