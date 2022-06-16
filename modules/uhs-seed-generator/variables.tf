
variable "vpc_id" {
  description = "The VPC id"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "max_vcpus" {
  description = "Max vcpus allocatable to the seed generator environment"
  type        = string
}

variable "job_vcpu" {
    description = "Vcpus required for a seed generator batch job"
    type        = string
}

variable "job_memory" {
    description = "Memory required for a seed generator batch job"
    type        = string
}

variable "binaries_s3_bucket" {
  type        = string
  description = "The S3 bukcet where binaries is stored."
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
