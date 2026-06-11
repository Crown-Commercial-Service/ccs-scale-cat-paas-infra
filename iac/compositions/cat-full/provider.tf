terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
      configuration_aliases = [
        aws,
        aws.secondary_region,
      ]
    }
  }
}
