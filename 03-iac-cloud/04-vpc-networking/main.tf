data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs            = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  common_tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lecture = "03-iac-cloud"
    Lab     = "04-vpc-networking"
    Managed = "terraform"
  }
}

# Using the official AWS VPC module — saves ~30 hand-written resources
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"

  name = "life-vpc-${var.student_name}"
  cidr = var.vpc_cidr

  azs            = local.azs
  public_subnets = local.public_subnets

  # NO NAT Gateway — costs $32/month even idle. Public subnets only for free tier.
  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

# Security group for web traffic (frontend + backend)
resource "aws_security_group" "web" {
  name        = "life-web-sg-${var.student_name}"
  description = "Allow HTTP/HTTPS/8080/3000 from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (for live demo only — restrict to your IP in real life)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Security group for the database — only accessible from web SG
resource "aws_security_group" "db" {
  name        = "life-db-sg-${var.student_name}"
  description = "PostgreSQL accessible only from web SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from web SG only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
