variable "environment" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}

variable "opensearch_instance_type" {
  type = string
  description = "Instance type used for Open Search cluster"
  default = "t3.small.search"
}

variable "opensearch_instance_count" {
  type = string
  description = "Number of instances to include in OpenSearch domain"
  default = 1
}

variable "opensearch_ebs_volume_type" {
  type = string
  description = "Type of EBS volume to back Open Search domain"
  default = "gp2"
}

variable "opensearch_ebs_volume_size" {
  type = string
  description = "Size of EBS volume to back Open Search domain"
  default = "10"
}

variable "fire_hose_buffering_interval" {
  type = number
  description = "Interval time between sending Fire Hoe buffer data to Open Search"
  default = 60
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
