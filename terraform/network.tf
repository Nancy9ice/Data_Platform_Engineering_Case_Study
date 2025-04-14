# AWS VPC module 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-${var.env_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Name        = "${var.project}-${var.env_prefix}-vpc"
    Project     = var.project
    Terraform   = "true"
    Environment = var.env_prefix
  }
}

# standard security grou configs 
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-${var.env_prefix}-sg"
  description = "Allow HTTP/HTTPS and SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.env_prefix}-sg"
    Project     = var.project
    Terraform   = "true"
    Environment = var.env_prefix
  }
}