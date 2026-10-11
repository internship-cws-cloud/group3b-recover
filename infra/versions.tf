terraform {
  required_version = "~> 1.16"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket       = "group3b-tfstate-221032951827"
    key          = "infra/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
#default_tags {
#tags = {
#Group     = var.group_name
#Programme = "cloud-internship"
#ManagedBy = "terraform"
#}
#}
#}