#########################################################
# Config: remote backend
#
# Need to supply the sensitive values during `terraform init`
# 
# terraform init \
#    -backend-config="access_key=ACCESS_KEY_ID" \
#    -backend-config="secret_key=SECRET_ACCESS_KEY" \
#    -backend-config="bucket=S3_STATE_BUCKET_NAME" \
#    -backend-config="dynamodb_table=DDB_LOCK_TABLE_NAME"
#########################################################
terraform {
  backend "s3" {
    key     = "ccs-scale-cat-paas-infra-int"
    region  = "eu-west-2"
    encrypt = true
  }

  # Can be removed when bug is resolved: https://github.com/hashicorp/terraform-provider-aws/issues/23110
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }  
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

