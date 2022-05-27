variable "environment" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
  default     = ""
}

variable "base_domain" {
  type = string
  description = "Base domain to use for ACM Cert and Route53 record management."
  default = ""
}

variable "ec2_public_key" {
  type = string
  description = "SSH public key to use in EC2 instances."
  default = ""
}

variable "test_controller_github_access_token" {
  description = "Access token for cloning test controller repo"
  type        = string
  default     = ""
}

variable "lets_encrypt_email" {
  description = "Email to associate with let's encrypt certificate"
  type = string
  default = ""
}
