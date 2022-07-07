variable "base_domain" {
  type        = string
  description = "Base domain to use for ACM Cert and Route53 record management."
  default = ""
}
variable "hosted_zone_id" {
  type = string
  description = "Id of hosted zone in Route53"
  default = null
}

#EC2
variable "ec2_public_key" {
  type        = string
  description = "SSH public key to use in EC2 instances."
  default     = ""
}

# VPC Variables
variable "create_networking" {
  type = string
  description = "Flag to create VPCs and related resources"
  default = true
}
variable "vpc_id_use1" {
  type = string
  description = "ID of VPC in us-east-1 (required if create_networking==false)"
  default = null
}
variable "vpc_id_use2" {
  type = string
  description = "ID of VPC in us-east-2 (required if create_networking==false)"
  default = null
}
variable "vpc_id_usw2" {
  type = string
  description = "ID of VPC in us-west-2 (required if create_networking==false)"
  default = null
}
variable "public_subnets_use1" {
  type = list(string)
  description = "Public subnets in VPC us-east-1 (required if create_networking==false)"
  default = null
}
variable "public_subnets_use2" {
  type = list(string)
  description = "Public subnets in VPC us-east-2 (required if create_networking==false)"
  default = null
}
variable "public_subnets_usw2" {
  type = list(string)
  description = "Public subnets in VPC us-west-2 (required if create_networking==false)"
  default = null
}
variable "private_subnets_use1" {
  type = list(string)
  description = "Private subnets in VPC us-east-1 (required if create_networking==false)"
  default = null
}
variable "private_subnets_use2" {
  type = list(string)
  description = "Private subnets in VPC us-east-2 (required if create_networking==false)"
  default = null
}
variable "private_subnets_usw2" {
  type = list(string)
  description = "Private subnets in VPC us-west-2 (required if create_networking==false)"
  default = null
}
variable "route_tables_use1" {
  type = list(string)
  description = "Route tables in VPC us-east-1 (required if create_networking==false)"
  default = null
}
variable "route_tables_use2" {
  type = list(string)
  description = "Route tables in VPC us-east-2 (required if create_networking==false)"
  default = null
}
variable "route_tables_usw2" {
  type = list(string)
  description = "Route tables in VPC us-west-2 (required if create_networking==false)"
  default = null
}
variable "vpc_azs_use1" {
  type = list(string)
  description = "AZs of VPC in us-east-1 (required if create_networking==false)"
  default = null
}
variable "vpc_azs_use2" {
  type = list(string)
  description = "AZs of VPC in us-east-2 (required if create_networking==false)"
  default = null
}
variable "vpc_azs_usw2" {
  type = list(string)
  description = "AZs of VPC in us-east-2 (required if create_networking==false)"
  default = null
}
variable "s3_interface_endpoint_use1" {
  type = string
  description = "S3 endpoint for VPC in us-east-1 (required if create_networking==false)"
  default = null
}
variable "s3_interface_endpoint_use2" {
  type = string
  description = "S3 endpoint for VPC in us-east-2 (required if create_networking==false)"
  default = null
}
variable "s3_interface_endpoint_usw2" {
  type = string
  description = "S3 endpoint for VPC in us-west-2 (required if create_networking==false)"
  default = null
}
variable "use1_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in us-east-1."
  default     = "10.0.0.0/16"
}
variable "use2_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in us-east-2."
  default     = "10.10.0.0/16"
}
variable "usw2_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in us-west-2."
  default     = "10.20.0.0/16"
}
variable "subnet_prefix_extension" {
  type        = number
  description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
  default     = 4
}
variable "public_subnet_tags" {
  type = map(string)
  description = "Tags associated with public subnets"
  default = {}
}
variable "private_subnet_tags" {
  type = map(string)
  description = "Tags associated with private subnets"
  default = {}
}
variable "zone_offset" {
  type        = number
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
  default     = 8
}

# Test Controller
variable "create_certbot_lambda" {
  type        = bool
  description = "Boolean to create the certbot lambda to update the letsencrypt cert for the test controller."
  default     = true
}
variable "lets_encrypt_email" {
  type = string
  description = "Email to associate with let's encrypt certificate"
}
variable "test_controller_github_repo" {
  description = "The Github repo base name"
  type        = string
  default     = "opencbdc-tctl"
}
variable "test_controller_github_repo_owner" {
  description = "The Github repo owner"
  type        = string
  default     = "mit-dci"
}
variable "test_controller_github_repo_branch" {
  description = "The repo branch to use for the Test Controller deployment pipeline."
  type        = string
  default     = "trunk"
}
variable "test_controller_github_access_token" {
  description = "Access token for cloning test controller repo"
  type        = string
}
variable "test_controller_node_container_build_image" {
  type = string
  description = "An optional custom container build image for test controller Nodejs depencies"
  default = "node:14"
}
variable "test_controller_golang_container_build_image" {
  type = string
  description = "An optional custom container build image for test controller Golang depencies"
  default = "golang:1.16"
}
variable "test_controller_app_container_base_image" {
  type = string
  description = "An optional custom container base image for the test controller and releated services"
  default = "ubuntu:20.04"
}
variable "test_controller_launch_type" {
  description = "The ECS task launch type to run the test controller."
  type        = string
  default     = "FARGATE"
}
variable "test_controller_cpu" {
  description = "The ECS task CPU"
  type        = string
  default     = "4096"
}
variable "test_controller_memory" {
  description = "The ECS task memory"
  type        = string
  default     = "30720"
}
variable "test_controller_health_check_grace_period_seconds" {
  description = "The ECS service health check grace period in seconds"
  type        = number
  default     = 300
}
variable "transaction_processor_repo_url" {
  description = "Transaction repo cloned by the test controller for load generation logic"
  type = string
  default = "https://github.com/mit-dci/opencbdc-tx.git"
}
variable "transaction_processor_main_branch" {
  type = string
  description = "Main branch of transaction repo"
  default = "trunk"
}
variable "transaction_processor_github_access_token" {
  type = string
  description = "Access token for the transaction repo if permissions are required"
  default = ""
}
variable "cluster_instance_type" {
  type        = string
  description = "If test controller launch type is EC2, the instance size to use."
  default     = "c5ad.12xlarge"
}

# Opensearch
variable "create_opensearch" {
  type = bool
  description = "Boolean to create Opensearch domain and related resources"
  default = true
}
variable "opensearch_instance_type" {
  type = string
  description = "Instance type used for Open Search cluster"
  default = "t3.small.search"
}
variable "opensearch_instance_count" {
  type = string
  description = "Number of instances to include in OpenSearch domain"
  default = 1
}
variable "opensearch_ebs_volume_type" {
  type = string
  description = "Type of EBS volume to back Open Search domain"
  default = "gp2"
}
variable "opensearch_ebs_volume_size" {
  type = string
  description = "Size of EBS volume to back Open Search domain"
  default = "10"
}


# Seed Generator
variable "create_uhs_seed_generator" {
  type = bool
  description = "Determines whether or not to create uhs seed generator resources"
  default = true
}
variable "uhs_seed_generator_max_vcpus" {
  description = "Max vcpus allocatable to the seed generator environment"
  type        = string
  default     = "50"
}
variable "uhs_seed_generator_job_vcpu" {
  description = "Vcpus required for a seed generator batch job"
  type        = string
  default     = "4"
}
variable "uhs_seed_generator_job_memory" {
  description = "Memory required for a seed generator batch job"
  type        = string
  default     = "8192"
}

# Test Controller Agents
variable "agent_instance_types" {
  type        = list(string)
  description = "The instance types used in agent launch templates."
  default     = [
    "c5n.large",
    "c5n.2xlarge",
    "c5n.9xlarge",
    "c5n.metal"
  ]
}


# Tags
variable "environment" {
  type        = string
  description = "AWS tag to indicate environment name of each infrastructure object."
}
variable "resource_tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
