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

variable "hosted_zone_id" {
  type = string
  description = "Route53 hosted zone id of the base domain"
}

variable "azs" {
  description = "A list of availability zones inside the VPC"
  type        = list(string)
  default     = []
}

variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "launch_type" {
  description = "The ECS task launch type"
  type        = string
}

variable "cpu" {
  description = "The ECS task CPU"
  type        = string
}

variable "memory" {
  description = "The ECS task memory"
  type        = string
}

variable "health_check_grace_period_seconds" {
  description = "The ECS service health check grace period in seconds"
  type        = number
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}

variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used in load balancer CNAME creation."
}

variable "binaries_s3_bucket" {
  type        = string
  description = "The S3 bukcet where binaries is stored."
}

variable "binaries_s3_bucket_arn" {
  type        = string
  description = "The S3 bucket arn where binaries are stored."
}

variable "outputs_s3_bucket" {
  type        = string
  description = "The S3 bucket where test result outputs are stored."
}

variable "s3_interface_endpoint" {
  type        = string
  description = "DNS record used to route s3 traffic through s3 vpc interface endpoint"
  default     = ""
}

variable "github_repo" {
  description = "The Github repo base name"
  type        = string
  default     = "cbdc-test-controller"
}

variable "github_repo_owner" {
  description = "The Github repo owner"
  type        = string
  default     = "mit-dci"
}

variable "github_repo_branch" {
  description = "The Github repo owner"
  type        = string
  default     = "master"
}

variable "create_certbot_lambda" {
  type        = bool
  description = "Boolean to create the certbot lambda to update the letsencrypt cert for the test controller."
}

variable "transaction_processor_repo_url" {
  type = string
  description = "Transaction repo cloned by the test controller for load generation logic"
}

variable "transaction_processor_main_branch" {
  type = string
  description = "Main branch of transaction repo"
}

variable "uhs_seed_generator_job_name" {
  type = string
  description = "Name of batch job used for uhs seed generation"
}
  
variable "uhs_seed_generator_job_definiton_arn" {
  type = string
  description = "Arn of uhs seed generator job definition"
}
  
variable "uhs_seed_generator_job_queue_arn" {
  type = string
  description = "Arn of uhs seed generator job queue"
}

variable "lets_encrypt_email" {
  type = string
  description = "Email to associate with let's encrypt certificate"
}
