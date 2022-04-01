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

variable "vpc_cidr_blocks" {
  description = "A list of VPC cidr blocks to add to the interface enpoint security group"
  type        = list(string)
  default     = [] 
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
