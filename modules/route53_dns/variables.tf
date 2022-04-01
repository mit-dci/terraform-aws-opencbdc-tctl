variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used for ACM cert creation."
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
