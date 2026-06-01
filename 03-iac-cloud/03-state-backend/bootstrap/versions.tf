terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "life-tf-state-dren-sokoli"
    key            = "03-iac-cloud/03-state-backend/bootstrap/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "life-tf-locks-dren-sokoli"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
