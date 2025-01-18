data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# 2. Create Route 53 record set for each Elastic IP
resource "aws_route53_record" "eip_records" {
  zone_id = data.aws_route53_zone.this.zone_id # Replace with your Route 53 hosted zone ID
  name    = var.domain_name                    # Replace with your domain or subdomain
  type    = "A"                                # For IPv4 address
  ttl     = 300

  # Combine all Elastic IPs into a single list of records
  records = [for eip in aws_eip.this : eip.public_ip]
}