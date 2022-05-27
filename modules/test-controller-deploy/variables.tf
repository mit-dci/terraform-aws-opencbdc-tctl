variable "name" {
  description = "Name suffix associated with resources"
  type        = string
}

variable "cluster_name" {
  description = "The ECS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "test_controller_ecr_repo" {
  description = "The ECR repo for the test controller"
  type        = string
}

variable "uhs_seed_generator_ecr_repo" {
  type = string
  description = "The ECR repo for the uhs seed generator"
}

variable "test_controller_ecs_service_name" {
  description = "The ECS Service name for the test controller"
  type        = string
}

variable "node_container_build_image" {
  type = string
  description = "An optional custom container build image for Nodejs depencies"
}

variable "golang_container_build_image" {
  type = string
  description = "An optional custom container build image for Golang depencies"
}

variable "app_container_base_image" {
  type = string
  description = "An optional custom container base image for the test controller and releated services"
}

variable "binaries_s3_bucket" {
  description = "The S3 bucket where agent binaries should be published by the pipeline"
  type        = string
}

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
  description = "Name of oauth token for github private repo"
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
