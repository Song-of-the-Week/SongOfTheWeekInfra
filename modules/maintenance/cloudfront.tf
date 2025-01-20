resource "aws_cloudfront_distribution" "this" {
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  aliases = [var.domain_name, "www.${var.domain_name}"]

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https" # Redirects all HTTP traffic to HTTPS

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    default_ttl = 3600
    max_ttl     = 86400
    min_ttl     = 0
  }

  default_root_object = "index.html"

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.amazon_issued.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

data "aws_acm_certificate" "amazon_issued" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "S3OAC"
  description                       = "OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
