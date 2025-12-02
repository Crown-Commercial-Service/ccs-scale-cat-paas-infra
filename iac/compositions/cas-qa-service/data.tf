data "aws_ssm_parameter" "api_key" {
  name = "/cat/${var.environment}/question-and-answer-service-api-key"
}

data "aws_ssm_parameter" "base_url" {
  name = "/cat/${var.environment}/question-and-answer-service-base-url"
}