data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_alb.dns_name
    zone_id                = aws_lb.ecs_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.ecs_alb.dns_name
    zone_id                = aws_lb.ecs_alb.zone_id
    evaluate_target_health = true
  }
}

# 2. Create Route 53 record set for each Elastic IP
resource "aws_route53_record" "eips" {
  for_each = toset([for idx in range(length(aws_eip.this)) : var.domain_name])

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.key
  type    = "A"
  ttl     = 300
  records = [aws_eip.this[each.index].public_ip] # Associate each EIP with the respective domain

  depends_on = [aws_eip.this]
}