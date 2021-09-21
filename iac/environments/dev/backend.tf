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
    key     = "ccs-scale-cat-paas-infra-dev"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

