variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used for ACM cert creation."
}

variable "create_hosted_zone" {
  type = bool
  description = "Flag to create hosted zone in route53"
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
