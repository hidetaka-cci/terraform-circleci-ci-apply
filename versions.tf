terraform {
  required_version = ">= 1.10"

  required_providers {
    circleci = {
      source  = "CircleCI-Public/circleci"
      version = "~> 0.5.6"
    }
  }

  backend "s3" {
    bucket       = "hidetaka-terraform-ci-apply-tfstate"
    key          = "terraform-circleci-ci-apply/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "circleci" {}
