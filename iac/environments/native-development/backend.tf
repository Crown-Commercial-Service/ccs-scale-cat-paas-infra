#########################################################
# Config: remote backend
#
# (Aligned with pre-migration conventions)
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
    key     = "ccs-scale-cat-native-infra-dev"
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

# Note we do not use "default" AWS profile here, unlike other envs. This is to allow IAC developers
# to use profiles to manage their various projects.
provider "aws" {
  region = "eu-west-2"
}
