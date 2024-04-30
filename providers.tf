terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}