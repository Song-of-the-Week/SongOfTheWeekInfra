resource "aws_apigatewayv2_api" "api" {
  name          = "sotw-app-${var.env}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id = aws_apigatewayv2_api.api.id
  #   connection_id          = aws_apigatewayv2_vpc_link.vpc_link.id
  #   connection_type        = "VPC_LINK"
  integration_method     = "ANY"
  integration_type       = "HTTP_PROXY"
  integration_uri        = "http://sotw-prod.sotw-prod:80"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_domain_name" "gateway_domain" {
  domain_name = var.domain_name

  domain_name_configuration {
    endpoint_type   = "REGIONAL"
    certificate_arn = data.aws_acm_certificate.certificate.arn
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "gateway_mapping" {
  api_id      = aws_apigatewayv2_api.api.id
  domain_name = aws_apigatewayv2_domain_name.gateway_domain.domain_name
  stage       = aws_apigatewayv2_stage.default.name
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.this.id
  name    = "dev.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.gateway_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.gateway_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}