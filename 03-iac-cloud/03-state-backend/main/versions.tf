terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend block CANNOT use variables. After running bootstrap/, edit this
  # file and replace the placeholder values with your actual bucket/table names.
  backend "s3" {
    bucket         = "life-tf-state-CHANGE-ME"
    key            = "demo/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "life-tf-locks-CHANGE-ME"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
