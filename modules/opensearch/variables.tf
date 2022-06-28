variable "environment" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}
variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used in opensearch custom endpoint options."
}
variable "hosted_zone_id" {
  type = string
  description = "Route53 hosted zone id of the base domain."
}
variable "custom_endpoint_certificate_arn" {
  type        = string
  description = "The ACM cert arn to use with the custom endpoint."
}
variable "master_user_name" {
  type = string
  description = "Master username of opensearch user"
}
variable "master_user_password" {
  type = string
  description = "Master password of opensearch user"
  sensitive = true
}
variable "route53_record_ttl" {
  type = string
  description = "TTL for CNAME record of opensearch domain"
}
variable "opensearch_engine_version" {
  type = string
  description = "The engine version to use for the OpenSearch domain"
}
variable "opensearch_instance_type" {
  type = string
  description = "Instance type used for OpenSearch cluster"
}
variable "opensearch_instance_count" {
  type = string
  description = "Number of instances to include in OpenSearch domain"
}
variable "opensearch_ebs_volume_type" {
  type = string
  description = "Type of EBS volume to back OpenSearch domain"
}
variable "opensearch_ebs_volume_size" {
  type = string
  description = "Size of EBS volume to back OpenSearch domain"
}
variable "fire_hose_buffering_interval" {
  type = number
  description = "Interval time between sending Fire Hose buffer data to OpenSearch"
}
variable "fire_hose_index_rotation_period" {
  type = string
  description = "The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data."
}
variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
