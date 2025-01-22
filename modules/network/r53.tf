locals {
  cloudfront_domain_name    = data.aws_ssm_parameter.cloudfront_domain_name.value
  cloudfront_hosted_zone_id = data.aws_ssm_parameter.cloudfront_hosted_zone_id.value
  public_ips                = tolist(aws_eip.this[*].public_ip)
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# 2. Create Route 53 record set for each Elastic IP
resource "aws_route53_record" "eip_records" {
  count                            = length(local.public_ips)
  zone_id                          = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name                             = "app.${var.domain_name}"           # Replace with your domain or subdomain
  type                             = "A"                                # For IPv4 address
  ttl                              = 60
  set_identifier                   = "Primary-${count.index}"
  multivalue_answer_routing_policy = true

  # Combine all Elastic IPs into a single list of records
  records         = [local.public_ips[count.index]]
  health_check_id = aws_route53_health_check.health_checks[count.index].id # Attach the health check to the DNS record
}

resource "aws_route53_record" "eip_records_alias" {
  zone_id        = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name           = var.domain_name                    # Replace with your domain or subdomain
  type           = "A"                                # For IPv4 address
  set_identifier = "Primary-Alias"
  failover_routing_policy {
    type = "PRIMARY"
  }
  alias {
    name                   = aws_route53_record.eip_records[0].name
    zone_id                = data.aws_route53_zone.this.zone_id
    evaluate_target_health = true
  }
  # Combine all Elastic IPs into a single list of records
}


resource "aws_route53_record" "eip_records_www" {
  count                            = length(local.public_ips)
  zone_id                          = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name                             = "www.app.${var.domain_name}"       # Replace with your domain or subdomain
  type                             = "A"                                # For IPv4 address
  ttl                              = 60
  set_identifier                   = "PrimaryWWW-${count.index}"
  multivalue_answer_routing_policy = true

  # Combine all Elastic IPs into a single list of records
  records         = [local.public_ips[count.index]]
  health_check_id = aws_route53_health_check.health_checks[count.index].id # Attach the health check to the DNS record
}

resource "aws_route53_record" "eip_records_www_alias" {
  zone_id        = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name           = "www.${var.domain_name}"           # Replace with your domain or subdomain
  type           = "A"                                # For IPv4 address
  set_identifier = "PrimaryWWW-Alias"
  failover_routing_policy {
    type = "PRIMARY"
  }
  alias {
    name                   = aws_route53_record.eip_records_www[0].name
    zone_id                = data.aws_route53_zone.this.zone_id
    evaluate_target_health = true
  }
  # Combine all Elastic IPs into a single list of records
}

resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name    = var.domain_name
  type    = "A"
  # ttl            = 60
  set_identifier = "Secondary"

  # S3 Website Endpoint
  alias {
    name                   = local.cloudfront_domain_name
    zone_id                = local.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}

resource "aws_route53_record" "secondary_www" {
  zone_id = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name    = "www.${var.domain_name}"
  type    = "A"
  # ttl            = 60
  set_identifier = "SecondaryWWW"

  # S3 Website Endpoint
  alias {
    name                   = local.cloudfront_domain_name
    zone_id                = local.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}

resource "aws_route53_health_check" "health_checks" {
  count             = length(local.public_ips)
  ip_address        = local.public_ips[count.index] # Monitor each EIP
  type              = "HTTPS"
  resource_path     = "/health" # The path for the health check
  port              = 443
  failure_threshold = 3    # Number of consecutive failures before marking the endpoint as unhealthy
  request_interval  = 30   # Interval between health checks (seconds)
  measure_latency   = true # Optional: Measure the latency of the check
  regions           = ["us-east-1", "us-west-1", "us-west-2", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2", "eu-west-1", "sa-east-1"]
  tags = {
    "healthCheckId" = count.index
  }
}
