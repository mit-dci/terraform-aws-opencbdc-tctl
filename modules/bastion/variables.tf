variable "vpc_id" {
  description = "The VPC id"
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  type = string
  description = "Route53 hosted zone id of the base domain"
}

variable "public_key" {
  type        = string
  description = "The SSH public key from the shared SSH key pair used in launch templates."
}

variable "certs_efs_id" {
  type        = string
  description = "The EFS ID for the certs volume."
}

variable "testruns_efs_id" {
  type        = string
  description = "The EFS ID for the testruns volume."
}

variable "binaries_efs_id" {
  type        = string
  description = "The EFS ID for the binaries volume."
}

variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used in bastion EIP A record creation."
}

# Tags
variable "environment" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}
