###################
### Open Search ###
###################
resource "aws_opensearch_domain" "this" {
  domain_name    = "${var.environment}-testresults"
  engine_version = var.opensearch_engine_version

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
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

  tags = local.tags
}
