provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ENVIRONMENT  = var.environment_name
      ORGANISATION = "CCS"
      PROJECT      = "CAS"
    }
  }

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/cicd_infrastructure"
    session_name = "cas_cicd_infrastructure"
  }
}

provider "aws" {
  region = var.aws_region == "eu-west-2" ? "eu-west-1" : "eu-west-2"
  alias  = "secondary_region"

  default_tags {
    tags = {
      ENVIRONMENT  = var.environment_name
      ORGANISATION = "CCS"
      PROJECT      = "CAS"
    }
  }

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/cicd_infrastructure"
    session_name = "cas_cicd_infrastructure"
  }
}
