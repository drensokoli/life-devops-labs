# ─────────────────────────────────────────────────────────────────
# Look up the VPC + security groups created in 04-vpc-networking
# (We find them by tag, no remote state needed.)
# ─────────────────────────────────────────────────────────────────

data "aws_vpc" "main" {
  tags = {
    Owner = var.student_name
    Lab   = "04-vpc-networking"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_security_group" "web" {
  vpc_id = data.aws_vpc.main.id
  name   = "life-web-sg-${var.student_name}"
}

data "aws_security_group" "db" {
  vpc_id = data.aws_vpc.main.id
  name   = "life-db-sg-${var.student_name}"
}

# Latest Amazon Linux 2023 AMI for our region
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  common_tags = {
    Owner   = var.student_name
    Course  = "LIFE-DevOps"
    Lecture = "03-iac-cloud"
    Lab     = "05-compute-storage"
    Managed = "terraform"
  }
}

# ─────────────────────────────────────────────────────────────────
# ECR — container registry for backend + frontend
# ─────────────────────────────────────────────────────────────────

resource "aws_ecr_repository" "backend" {
  name                 = "life-backend-${var.student_name}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # allows terraform destroy even if images exist

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

resource "aws_ecr_repository" "frontend" {
  name                 = "life-frontend-${var.student_name}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────────
# S3 — application logs / backups bucket
# ─────────────────────────────────────────────────────────────────

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "app" {
  bucket = "life-app-${var.student_name}-${random_id.bucket_suffix.hex}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────────────────────────
# IAM — role for EC2 to read from ECR and read/write S3
# ─────────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "life-ec2-role-${var.student_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.common_tags
}

# Read from ECR (pull images)
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Read/write the app bucket only (least privilege)
data "aws_iam_policy_document" "s3_app" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_app" {
  name   = "life-ec2-s3-${var.student_name}"
  policy = data.aws_iam_policy_document.s3_app.json
}

resource "aws_iam_role_policy_attachment" "s3_app" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_app.arn
}

# Allow SSM Session Manager — log in without SSH keys (extra safety)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "life-ec2-profile-${var.student_name}"
  role = aws_iam_role.ec2.name
}

# ─────────────────────────────────────────────────────────────────
# SSH key pair — generated locally so students don't need to
# manage anything in the AWS console
# ─────────────────────────────────────────────────────────────────

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "life-key-${var.student_name}"
  public_key = tls_private_key.ec2.public_key_openssh
  tags       = local.common_tags
}

resource "local_sensitive_file" "ssh_key" {
  filename        = "${path.module}/life-key.pem"
  content         = tls_private_key.ec2.private_key_pem
  file_permission = "0600"
}

# ─────────────────────────────────────────────────────────────────
# RDS — PostgreSQL (free-tier db.t3.micro)
# ─────────────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name       = "life-db-subnets-${var.student_name}"
  subnet_ids = data.aws_subnets.public.ids
  tags       = local.common_tags
}

resource "aws_db_instance" "postgres" {
  identifier = "life-db-${var.student_name}"

  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.micro" # free tier
  allocated_storage     = 20      # 20 GB free tier
  max_allocated_storage = 20      # cap auto-scaling

  db_name  = "lifedb"
  username = "life"
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [data.aws_security_group.db.id]
  publicly_accessible    = true # for class demo only — false in real life
  multi_az               = false # single AZ to stay in free tier

  backup_retention_period = 0     # no backups (free tier safe)
  skip_final_snapshot     = true  # CRITICAL: lets us terraform destroy fast
  deletion_protection     = false # CRITICAL: same reason

  performance_insights_enabled = false

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────────
# EC2 — runs Docker, pulls our image from ECR, runs the app
# ─────────────────────────────────────────────────────────────────

# cloud-init script: install Docker on first boot
locals {
  user_data = <<-EOT
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user

    # Helper script for ECR login (run by student after SSH)
    cat > /home/ec2-user/ecr-login.sh <<'BASH'
    #!/bin/bash
    aws ecr get-login-password --region ${var.aws_region} | \
      docker login --username AWS --password-stdin \
      $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${var.aws_region}.amazonaws.com
    BASH
    chmod +x /home/ec2-user/ecr-login.sh
    chown ec2-user:ec2-user /home/ec2-user/ecr-login.sh
  EOT
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [data.aws_security_group.web.id]
  key_name               = aws_key_pair.ec2.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data                   = local.user_data
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8 # 8 GB — well within 30 GB free tier
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "life-web-${var.student_name}"
  })
}
