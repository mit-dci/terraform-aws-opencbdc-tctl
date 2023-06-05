terraform {
  required_version = "= 1.4.6"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.4"
    }
  }
}
