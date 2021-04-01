terraform {
  backend "s3" {
    bucket  = "ulm0-tf-backend"
    key     = "runner/gitlab-arm"
    encrypt = true
    region  = "us-east-1"
  }
}

provider "aws" {}

module "arm" {
  source          = "git::https://gitlab.com/innersea/tf-modules/gitlab-runner.git"
  gitlab_token    = var.gitlab_token
  run_as_platform = "arm"
}

variable "gitlab_token" {}
