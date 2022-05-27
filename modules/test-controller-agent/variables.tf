variable "name" {
  type = string
  description = "Name suffix associated with resources"
}

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

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}

variable "public_key" {
  type        = string
  description = "The SSH public key from the shared SSH key pair used in launch templates."
}

variable "binaries_s3_bucket" {
  type        = string
  description = "The S3 bukcet where binaries is stored."
}

variable "outputs_s3_bucket" {
  type        = string
  description = "The S3 bucket where outputs are saved."
}

variable "outputs_s3_bucket_arn" {
  type        = string
  description = "The S3 bucket arn where outputs are saved."
}

variable "s3_interface_endpoint" {
  type        = string
  description = "DNS record used to route s3 traffic through s3 vpc interface endpoint"
  default     = ""
}

variable "controller_endpoint" {
  type        = string
  description = "The test controller endpoint where agents phone home."
}

variable "controller_port" {
  type        = string
  description = "The test controller endpoint port where agents phone home."
}

variable "log_group" {
  type        = string
  description = "The Cloudwatch log group to use in the cloudwatch agent config."
}

variable "instance_types" {
  type        = list(string)
  description = "The instance types used in agent launch templates."
}
