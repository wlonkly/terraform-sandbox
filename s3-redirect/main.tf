provider aws {
  region = "us-east-1"
}

locals {
  redirect = "redirect.rlafferty.pd-development.com"
}
resource "aws_s3_bucket" "redirect" {
  bucket = "${local.redirect}"
  acl    = "private"

  website {
    #        redirect_all_requests_to = "https://developer.pagerduty.com"
    index_document = "fnord"

    routing_rules = <<JSON
[{
    "Redirect": {
        "HostName": "developer.pagerduty.com",
        "Protocol": "https",
        "ReplaceKeyWith": ""
    }
}]
JSON
  }

  tags = {
    terraform = "true"
    owner     = "rlafferty"
  }
}

resource "aws_acm_certificate" "redirect" {
  domain_name       = "${local.redirect}"
  validation_method = "DNS"

  tags = {
    terraform = "true"
    owner     = "rlafferty"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name         = "rlafferty.pd-development.com."
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.redirect.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.redirect.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.redirect.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "redirect" {
  certificate_arn         = "${aws_acm_certificate.redirect.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_route53_record" "redirect" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${local.redirect}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect.hosted_zone_id}"
    evaluate_target_health = "false"
  }
}

# resource "aws_cloudfront_origin_access_identity" "default" {}

# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.redirect.arn}/*"]

#     principals {
#       type        = "CanonicalUser"
#       identifiers = ["${aws_cloudfront_origin_access_identity.default.s3_canonical_user_id}"]
#     }
#   }

#   statement {
#     actions   = ["s3:ListBucket"]
#     resources = ["${aws_s3_bucket.redirect.arn}"]

#     principals {
#       type        = "CanonicalUser"
#       identifiers = ["${aws_cloudfront_origin_access_identity.default.s3_canonical_user_id}"]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "cloudfront_access" {
#   bucket = "${aws_s3_bucket.redirect.id}"
#   policy = "${data.aws_iam_policy_document.s3_policy.json}"
# }

resource "aws_cloudfront_distribution" "redirect" {
  enabled = "true"

  aliases = ["${local.redirect}"]

  origin {
    domain_name = "${aws_s3_bucket.redirect.website_endpoint}"
    origin_id   = "${aws_s3_bucket.redirect.id}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }


  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${aws_s3_bucket.redirect.id}"
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      headers = ["*"]
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.redirect.arn}"
    ssl_support_method  = "sni-only"
  }
}

output "s3_website_endpoint" {
  value = "${aws_s3_bucket.redirect.website_endpoint}"
}

output "s3_website_domain" {
  value = "${aws_s3_bucket.redirect.website_domain}"
}

output "cf_domain" {
  value = "${aws_cloudfront_distribution.redirect.domain_name}"
}
