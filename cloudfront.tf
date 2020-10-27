locals {
  allowed_methods = [
    "DELETE",
    "GET",
    "HEAD",
    "OPTIONS",
    "PATCH",
    "POST",
    "PUT"
  ]

  cached_methods = [
    "GET",
    "HEAD",
    "OPTIONS"
  ]
}

locals {
  origin_id_podcast       = "podcast-backend"
  origin_id_notifications = "notifications-backend"
  origin_id_api_docs      = "api-docs"
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  price_class     = "PriceClass_100"
  is_ipv6_enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    domain_name = "sa-podcast.herokuapp.com"
    origin_id   = local.origin_id_podcast
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  origin {
    domain_name = "vegvesen-notifications.herokuapp.com"
    origin_id   = local.origin_id_notifications
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  origin {
    domain_name = "petstore.swagger.io"
    origin_id   = local.origin_id_api_docs
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  ordered_cache_behavior {
    allowed_methods        = local.allowed_methods
    cached_methods         = local.cached_methods
    path_pattern           = "/docs/*"
    target_origin_id       = local.origin_id_api_docs
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    forwarded_values {
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.api-docs.qualified_arn
    }
  }

  ordered_cache_behavior {
    allowed_methods        = local.allowed_methods
    cached_methods         = local.cached_methods
    path_pattern           = "/podcasts*"
    target_origin_id       = local.origin_id_podcast
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    forwarded_values {
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.waf.qualified_arn
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.routing.qualified_arn
    }
  }

  ordered_cache_behavior {
    allowed_methods        = local.allowed_methods
    cached_methods         = local.cached_methods
    path_pattern           = "/notifications*"
    target_origin_id       = local.origin_id_notifications
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    forwarded_values {
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.waf.qualified_arn
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.routing.qualified_arn
    }
  }

  default_cache_behavior {
    allowed_methods        = local.allowed_methods
    cached_methods         = local.cached_methods
    target_origin_id       = local.origin_id_podcast
    viewer_protocol_policy = "redirect-to-https"
    compress               = false

    forwarded_values {
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.waf.qualified_arn
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.routing.qualified_arn
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
