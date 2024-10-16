terraform {
  backend "s3" {
    key     = "ccs-scale-cat-native-infra-sandbox"
    region  = "eu-west-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
  }
}
