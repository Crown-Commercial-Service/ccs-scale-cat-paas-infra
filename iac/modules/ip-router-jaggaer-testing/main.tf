#########################################################
# Routing service for IP auth based on nginx
#########################################################
data "cloudfoundry_domain" "domain" {
  name = "london.cloudapps.digital"
}

data "cloudfoundry_org" "cat" {
  name = var.organisation
}

data "cloudfoundry_space" "space" {
  name = var.space
  org  = data.cloudfoundry_org.cat.id
}

data "archive_file" "nginx" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/.build/nginx.zip"
}

data "aws_ssm_parameter" "allowed_ip_ranges" {
  name = "/cat/default/allowed-ip-ranges"
}

# Must be present, may be ' '
data "aws_ssm_parameter" "env_allowed_ip_ranges" {
  name = "/cat/${var.environment}/allowed-ip-ranges"
}

resource "cloudfoundry_app" "nginx" {
  buildpack  = "nginx_buildpack"
  disk_quota = var.disk_quota
  environment = {
    ALLOWED_IPS : join("\n", [data.aws_ssm_parameter.allowed_ip_ranges.value, data.aws_ssm_parameter.env_allowed_ip_ranges.value])
    CLIENT_MAX_BODY_SIZE: var.nginx_client_max_body_size
    PUBLISH_ENDPOINT_THROW_404: "false"
    PUBLISH_ENDPOINT_THROW_502: "false"
    PUBLISH_ENDPOINT_THROW_503: "false"
    MESSAGES_ENDPOINT_THROW_404: "false"
    MESSAGES_ENDPOINT_THROW_502: "false"
    MESSAGES_ENDPOINT_THROW_503: "false"
    MESSAGES_READ_ENDPOINT_THROW_404: "false"
    MESSAGES_READ_ENDPOINT_THROW_502: "false"
    MESSAGES_READ_ENDPOINT_THROW_503: "false"
    EVALUATIONS_START_ENDPOINT_THROW_404: "false"
    EVALUATIONS_START_ENDPOINT_THROW_502: "false"
    EVALUATIONS_START_ENDPOINT_THROW_503: "false"
    EVALUATIONS_OPEN_ENVELOPE_ENDPOINT_THROW_404: "false"
    EVALUATIONS_OPEN_ENVELOPE_ENDPOINT_THROW_502: "false"
    EVALUATIONS_OPEN_ENVELOPE_ENDPOINT_THROW_503: "false"
    SCORES_ENDPOINT_THROW_404: "false"
    SCORES_ENDPOINT_THROW_502: "false"
    SCORES_ENDPOINT_THROW_503: "false"
    COMPLETE_TECHNICAL_ENDPOINT_THROW_404: "false"
    COMPLETE_TECHNICAL_ENDPOINT_THROW_502: "false"
    COMPLETE_TECHNICAL_ENDPOINT_THROW_503: "false"
    AWARD_RFX_ENDPOINT_THROW_404: "false"
    AWARD_RFX_ENDPOINT_THROW_502: "false"
    AWARD_RFX_ENDPOINT_THROW_503: "false"
    PREAWARD_RFX_ENDPOINT_THROW_404: "false"
    PREAWARD_RFX_ENDPOINT_THROW_502: "false"
    PREAWARD_RFX_ENDPOINT_THROW_503: "false"
    RFXS_ENDPOINT_THROW_404: "false"
    RFXS_ENDPOINT_THROW_502: "false"
    RFXS_ENDPOINT_THROW_503: "false"
  }
  health_check_timeout       = var.healthcheck_timeout
  health_check_type          = "http"
  health_check_http_endpoint = "/_route-service-health"
  instances                  = var.instances
  labels                     = {}
  memory                     = var.memory
  name                       = "${var.environment}-ccs-scale-cat-nginx-jaggaer-testing"
  path                       = data.archive_file.nginx.output_path
  source_code_hash           = data.archive_file.nginx.output_base64sha256
  space                      = data.cloudfoundry_space.space.id
  stopped                    = false
  timeout                    = 60
}

resource "cloudfoundry_route" "nginx" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = cloudfoundry_app.nginx.name

  target {
    app  = cloudfoundry_app.nginx.id
    port = 8080
  }
}

resource "cloudfoundry_user_provided_service" "ip_router" {
  name              = "${var.environment}-ccs-scale-cat-ip-router-jaggaer-testing"
  space             = data.cloudfoundry_space.space.id
  route_service_url = "https://${cloudfoundry_app.nginx.name}.${var.region_domain}"
}
