variable "github_repo" {
  description = "The Github repo base name"
  type        = string
}

variable "github_repo_owner" {
  description = "The Github repo owner"
  type        = string
}

variable "github_repo_branch" {
  description = "The Github repo owner"
  type        = string
}

variable "github_access_token" {
  description = "The name of the ssm parameter path for the Github oauth token"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}

variable "s3_interface_endpoint" {
  type        = string
  description = "DNS record used to route s3 traffic through s3 vpc interface endpoint"
  default     = ""
}
