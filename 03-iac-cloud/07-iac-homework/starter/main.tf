data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lab     = "07-iac-homework"
    Managed = "terraform"
  }
}

# ─────────────────────────────────────────────────────────────────
# TASK 1 — VPC + 2 public subnets + IGW + route table
# Use the official terraform-aws-modules/vpc/aws module.
# ─────────────────────────────────────────────────────────────────

# TODO: declare module "vpc" with:
#   - source: "terraform-aws-modules/vpc/aws"
#   - version: pin to ~> 5.5
#   - name: "life-hw-vpc-${var.student_name}"
#   - cidr: var.vpc_cidr
#   - azs: local.azs
#   - public_subnets: ["10.10.1.0/24", "10.10.2.0/24"]
#   - enable_nat_gateway: false   ← MUST be false ($$)
#   - tags: local.common_tags


# ─────────────────────────────────────────────────────────────────
# TASK 2 — Security groups (web + db)
# ─────────────────────────────────────────────────────────────────

# TODO: aws_security_group "web"
#   - name: "life-hw-web-sg-${var.student_name}"
#   - vpc_id: module.vpc.vpc_id (after you create the module)
#   - ingress: 80, 443, 8080, 3000, 22 from 0.0.0.0/0
#   - egress: all

# TODO: aws_security_group "db"
#   - name: "life-hw-db-sg-${var.student_name}"
#   - vpc_id: module.vpc.vpc_id
#   - ingress: 5432 from web SG ONLY (not from 0.0.0.0/0)
#   - egress: all


# ─────────────────────────────────────────────────────────────────
# TASK 3 — S3 bucket for app data
# ─────────────────────────────────────────────────────────────────

resource "random_id" "suffix" {
  byte_length = 4
}

# TODO: aws_s3_bucket "app"
#   - bucket: "life-hw-${var.student_name}-${random_id.suffix.hex}"
#   - tags: local.common_tags

# TODO: aws_s3_bucket_public_access_block "app" — block all public access


# ─────────────────────────────────────────────────────────────────
# TASK 4 — IAM role for EC2 (ECR read + S3 read/write + SSM)
# ─────────────────────────────────────────────────────────────────

# TODO: aws_iam_role "ec2"
#   - name: "life-hw-ec2-role-${var.student_name}"
#   - assume role policy: ec2.amazonaws.com

# TODO: attach AmazonEC2ContainerRegistryReadOnly
# TODO: attach AmazonSSMManagedInstanceCore
# TODO: aws_iam_instance_profile "ec2"


# ─────────────────────────────────────────────────────────────────
# TASK 5 — RDS db.t3.micro PostgreSQL
# ─────────────────────────────────────────────────────────────────

# TODO: aws_db_subnet_group using module.vpc.public_subnets
# TODO: aws_db_instance "postgres"
#   - identifier: "life-hw-db-${var.student_name}"
#   - engine: postgres, engine_version: "16.3"
#   - instance_class: db.t3.micro    ← MUST be t3.micro for free tier
#   - allocated_storage: 20
#   - db_name: lifedb, username: life, password: var.db_password
#   - skip_final_snapshot: true       ← so terraform destroy works
#   - deletion_protection: false      ← same reason
#   - publicly_accessible: true       ← demo only
#   - vpc_security_group_ids: [aws_security_group.db.id]


# ─────────────────────────────────────────────────────────────────
# TASK 6 — EC2 instance with Docker installed
# ─────────────────────────────────────────────────────────────────

# TODO: data "aws_ami" "al2023" — most recent al2023-ami-*-x86_64

# TODO: aws_instance "web"
#   - ami: data.aws_ami.al2023.id
#   - instance_type: var.instance_type
#   - subnet_id: module.vpc.public_subnets[0]
#   - vpc_security_group_ids: [aws_security_group.web.id]
#   - iam_instance_profile: aws_iam_instance_profile.ec2.name
#   - associate_public_ip_address: true
#   - root_block_device: 8 GB gp3 encrypted
#   - user_data: install Docker via cloud-init
#   - tags including Name = "life-hw-web-${var.student_name}"
