data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# 2. Create Route 53 record set for each Elastic IP
resource "aws_route53_record" "eip_records" {
  zone_id        = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name           = var.domain_name                    # Replace with your domain or subdomain
  type           = "A"                                # For IPv4 address
  ttl            = 60
  set_identifier = "Primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
  # Combine all Elastic IPs into a single list of records
  records         = [for eip in aws_eip.this : eip.public_ip]
  health_check_id = aws_route53_health_check.this.id # Attach the health check to the DNS record
}

resource "aws_route53_health_check" "this" {
  fqdn              = var.domain_name # The domain name to check
  type              = "HTTPS"         # You can use HTTP, HTTPS, TCP, etc.
  resource_path     = "/health"       # The path for the health check (if applicable)
  port              = 443             # Port to check
  failure_threshold = 3               # Number of consecutive failures before marking the endpoint as unhealthy
  request_interval  = 30              # Interval between health checks (seconds)
  measure_latency   = true            # Optional: Measure the latency of the check
}
