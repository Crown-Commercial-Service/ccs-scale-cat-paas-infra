terraform {
  backend "s3" {
    key     = "ccs-scale-cat-native-infra-production"
    region  = "eu-west-2"
    encrypt = true
  }
}
