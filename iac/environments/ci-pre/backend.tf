terraform {
  backend "s3" {
    key     = "ccs-scale-cat-native-infra-pre"
    region  = "eu-west-2"
    encrypt = true
  }
}
