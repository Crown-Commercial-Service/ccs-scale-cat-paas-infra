#########################################################
# S3: Tenders (CaT)
#
# Provision Tenders S3 bucket resources.
#########################################################
data "cloudfoundry_service" "s3" {
  name = "aws-s3-bucket"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "cloudfoundry_space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

resource "cloudfoundry_service_instance" "s3" {
  name         = "${var.environment}-ccs-scale-cat-tenders-s3-documents"
  space        = data.cloudfoundry_space.cloudfoundry_space.id
  service_plan = data.cloudfoundry_service.s3.service_plans["default"]
}
