locals {
  name = "test-results"
  tags = var.tags
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###################
### Open Search ###
###################
resource "aws_opensearch_domain" "this" {
  domain_name    = "${var.environment}-${local.name}"
  engine_version = var.opensearch_engine_version

  encrypt_at_rest {
    enabled = true
  }

  advanced_security_options {
    enabled = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    custom_endpoint_certificate_arn = var.custom_endpoint_certificate_arn
    custom_endpoint_enabled         = true
    custom_endpoint                 = "${local.name}.${var.dns_base_domain}"
    enforce_https                   = true
    tls_security_policy             = "Policy-Min-TLS-1-2-2019-07"
  }

  cluster_config {
    instance_type  = var.opensearch_instance_type
    instance_count = var.opensearch_instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_type = var.opensearch_ebs_volume_type
    volume_size = var.opensearch_ebs_volume_size
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "AUDIT_LOGS"
  }

  tags = local.tags

  depends_on = [aws_iam_service_linked_role.this]
}

# OpenSearch service-linked role
resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

# Access policy
resource "aws_opensearch_domain_policy" "this" {
  domain_name = aws_opensearch_domain.this.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "es:*"
        Principal = "*"
        Resource  = "${aws_opensearch_domain.this.arn}/*"
      }
    ]
  })
}

# Logs
resource "aws_cloudwatch_log_group" "opensearch" {
  name = "/aws/OpenSearchService/domains/${local.name}"
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_name = "OpenSearchService-${local.name}"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

# CNAME for custom OpenSearch endpoint
resource "aws_route53_record" "this" {
  zone_id = var.hosted_zone_id
  name    = "${local.name}.${var.dns_base_domain}"
  type    = "CNAME"
  ttl     = var.route53_record_ttl
  records = [ aws_opensearch_domain.this.endpoint ]
}


################
### Firehose ###
################
resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = "${var.environment}-${local.name}"
  destination = "elasticsearch"

  elasticsearch_configuration {
    domain_arn            = aws_opensearch_domain.this.arn
    role_arn              = aws_iam_role.firehose.arn
    index_name            = local.name
    buffering_interval    = var.fire_hose_buffering_interval
    index_rotation_period = var.fire_hose_index_rotation_period


    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = local.name
    }

    s3_configuration {
      role_arn   = aws_iam_role.firehose.arn
      bucket_arn = aws_s3_bucket.this.arn
    }
  }

  depends_on = [aws_iam_policy_attachment.firehose]
}


# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "firehose" {
  name = "/aws/kinesisfirehose/"
}

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = local.name
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

# IAM role
resource "aws_iam_role" "firehose" {
  name = "firehose-${var.environment}-${local.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "FireHoseAccess"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy_attachment" "firehose" {
  name       = "firehose-policy-attachment"
  roles      = [aws_iam_role.firehose.name]
  policy_arn = aws_iam_policy.firehose.arn
}

resource "aws_iam_policy" "firehose" {
  name        = "KinesisFirehoseServiceRole-${local.name}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  path        = "/"
  description = "Access for Kinesis Firehose to Opensearch"
  policy      = data.aws_iam_policy_document.firehose.json
}

data "aws_iam_policy_document" "firehose" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources =  [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "es:DescribeDomain",
      "es:DescribeDomains",
      "es:DescribeDomainConfig",
      "es:ESHttpPost",
      "es:ESHttpPut"
    ]
    resources = [
      "${aws_opensearch_domain.this.arn}",
      "${aws_opensearch_domain.this.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "es:ESHttpGet"
    ]
    resources = [
       "${aws_opensearch_domain.this.arn}/_all/_settings",
       "${aws_opensearch_domain.this.arn}/_cluster/stats",
       "${aws_opensearch_domain.this.arn}/${local.name}*/_mapping/*",
       "${aws_opensearch_domain.this.arn}/_nodes",
       "${aws_opensearch_domain.this.arn}/_nodes/stats",
       "${aws_opensearch_domain.this.arn}/_nodes/*/stats",
       "${aws_opensearch_domain.this.arn}/_stats",
       "${aws_opensearch_domain.this.arn}/${local.name}*/_stats"
    ]
  }
}

##########
### S3 ###
##########
resource "aws_s3_bucket" "this" {
  bucket        = "${data.aws_caller_identity.current.account_id}-firehose-backup"
  force_destroy = true
  tags = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
