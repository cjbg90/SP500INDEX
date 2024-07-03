provider "aws" {
  region = "us-west-2"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "sp500-analysis-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "sp500-analysis-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "sp500-analysis-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sp500-analysis-igw"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "sp500-analysis-nat-gw"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "sp500-analysis-nat-eip"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "sp500-analysis-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "sp500-analysis-private-rt"
  }
}

# EC2 Instance for Airflow
resource "aws_instance" "airflow" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private[0].id
  key_name      = "your-key-pair-name"

  vpc_security_group_ids = [aws_security_group.airflow.id]

  tags = {
    Name = "sp500-analysis-airflow"
  }
}

# Security Group for Airflow
resource "aws_security_group" "airflow" {
  name        = "sp500-analysis-airflow-sg"
  description = "Security group for Airflow instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["Your.IP.Address.Here/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "airflow_metadata" {
  identifier           = "sp500-analysis-airflow-metadata"
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  username             = "airflow"
  password             = "your-secure-password"
  db_subnet_group_name = aws_db_subnet_group.airflow.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot  = true

  tags = {
    Name = "sp500-analysis-airflow-metadata"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "airflow" {
  name       = "sp500-analysis-airflow-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "SP500 Analysis Airflow DB subnet group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "sp500-analysis-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.airflow.id]
  }
}

# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket = "sp500-analysis-data"

  tags = {
    Name = "sp500-analysis-data"
  }
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "data_acl" {
  bucket = aws_s3_bucket.data.id
  acl    = "private"
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data_encryption" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "sp500-analysis-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_role.name
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "sp500-analysis-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach Instance Profile to EC2
resource "aws_instance" "airflow" {
  # ... other configurations ...
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}