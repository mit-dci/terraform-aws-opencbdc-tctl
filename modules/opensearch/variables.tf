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

variable "opensearch_engine_version" {
  type = string
  description = "Engine version of Open Search domain"
  default = "OpenSearch_1.2"
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
