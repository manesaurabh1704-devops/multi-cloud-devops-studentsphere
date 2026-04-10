# ─────────────────────────────────────────
# Terraform Configuration
# ─────────────────────────────────────────
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ─────────────────────────────────────────
# AWS Provider
# ─────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────
# Data Sources
# ─────────────────────────────────────────
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
