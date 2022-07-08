locals {
  name        = "hamilton"
  required_tags = {
    Owner       = "terraform"
    Environment = var.environment
  }
  tags = merge(var.resource_tags, local.required_tags)

  # ids
  vpc_id_use1 = var.create_networking ? module.vpc[0].vpc_id : var.vpc_id_use1
  vpc_id_use2 = var.create_networking ? module.vpc_use2[0].vpc_id : var.vpc_id_use2
  vpc_id_usw2 = var.create_networking ? module.vpc_usw2[0].vpc_id : var.vpc_id_usw2

  # public subnets
  public_subnets_use1 = var.create_networking ? module.vpc[0].public_subnets : var.public_subnets_use1
  public_subnets_use2 = var.create_networking ? module.vpc_use2[0].public_subnets : var.public_subnets_use2
  public_subnets_usw2 = var.create_networking ? module.vpc_usw2[0].public_subnets : var.public_subnets_usw2

  # private subnets
  private_subnets_use1 = var.create_networking ? module.vpc[0].private_subnets : var.private_subnets_use1
  private_subnets_use2 = var.create_networking ? module.vpc_use2[0].private_subnets : var.private_subnets_use2
  private_subnets_usw2 = var.create_networking ? module.vpc_usw2[0].private_subnets : var.private_subnets_usw2

  # route tables
  route_tables_use1 = var.create_networking ? concat(module.vpc[0].public_route_table_ids, module.vpc[0].private_route_table_ids) : var.route_tables_use1
  route_tables_use2 = var.create_networking ? concat(module.vpc_use2[0].public_route_table_ids, module.vpc_use2[0].private_route_table_ids) : var.route_tables_use2
  route_tables_usw2 = var.create_networking ? concat(module.vpc_usw2[0].public_route_table_ids, module.vpc_usw2[0].private_route_table_ids) : var.route_tables_usw2

  # azs
  vpc_azs_use1 = var.create_networking ? module.vpc[0].azs : var.vpc_azs_use1
  vpc_azs_use2 = var.create_networking ? module.vpc_use2[0].azs : var.vpc_azs_use2
  vpc_azs_usw2 = var.create_networking ? module.vpc_usw2[0].azs : var.vpc_azs_usw2

  # VPC endpoints
  s3_interface_endpoint_use1 = var.create_networking ? module.vpc_endpoints_use1[0].s3_interface_endpoint : var.s3_interface_endpoint_use1
  s3_interface_endpoint_use2 = var.create_networking ? module.vpc_endpoints_use2[0].s3_interface_endpoint : var.s3_interface_endpoint_use2
  s3_interface_endpoint_usw2 = var.create_networking ? module.vpc_endpoints_usw2[0].s3_interface_endpoint : var.s3_interface_endpoint_usw2

  # Route53
  hosted_zone_id = var.create_networking ? module.route53_dns[0].hosted_zone_id : var.hosted_zone_id
}

# get the current aws region
data "aws_region" "current" {}

# used for accesing Account ID and ARN
data "aws_caller_identity" "current" {}

################################
#### VPCs ######################
################################

# Region: us-east-1
data "aws_availability_zones" "use1" {
  count = var.create_networking ? 1 : 0

  state           = "available"
  exclude_names = [ "us-east-1a", "us-east-1b", "us-east-1f" ]
}

module "vpc" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"

  name = local.name
  cidr = var.use1_main_network_block
  azs  = data.aws_availability_zones.use1[0].names

  private_subnets = [
    # this loop will create a one-line list as ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", ...]
    # with a length depending on how many Zones are available
    for zone_id in data.aws_availability_zones.use1[0].zone_ids :
    cidrsubnet(var.use1_main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  ]

  public_subnets = [
    # this loop will create a one-line list as ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", ...]
    # with a length depending on how many Zones are available
    # there is a zone Offset variable, to make sure no collisions are present with private subnet blocks
    for zone_id in data.aws_availability_zones.use1[0].zone_ids :
    cidrsubnet(var.use1_main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  tags = local.tags
}

# Region: us-east-2
data "aws_availability_zones" "use2" {
  count = var.create_networking ? 1 : 0

  provider = aws.use2
  state    = "available"
}

module "vpc_use2" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"

  providers = {
    aws = aws.use2
  }

  name = local.name
  cidr = var.use2_main_network_block
  azs  = data.aws_availability_zones.use2[0].names

  private_subnets = [
    # this loop will create a one-line list as ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", ...]
    # with a length depending on how many Zones are available
    for zone_id in data.aws_availability_zones.use2[0].zone_ids :
    cidrsubnet(var.use2_main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  ]

  public_subnets = [
    # this loop will create a one-line list as ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", ...]
    # with a length depending on how many Zones are available
    # there is a zone Offset variable, to make sure no collisions are present with private subnet blocks
    for zone_id in data.aws_availability_zones.use2[0].zone_ids :
    cidrsubnet(var.use2_main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  tags = local.tags
}

# Region: us-west-2
data "aws_availability_zones" "usw2" {
  count = var.create_networking ? 1 : 0

  provider      = aws.usw2
  state         = "available"
  exclude_names = [ "us-west-2a" ]
}

module "vpc_usw2" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"

  providers = {
    aws = aws.usw2
  }

  name = local.name
  cidr = var.usw2_main_network_block
  azs  = data.aws_availability_zones.usw2[0].names

  private_subnets = [
    # this loop will create a one-line list as ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", ...]
    # with a length depending on how many Zones are available
    for zone_id in data.aws_availability_zones.usw2[0].zone_ids :
    cidrsubnet(var.usw2_main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  ]

  public_subnets = [
    # this loop will create a one-line list as ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", ...]
    # with a length depending on how many Zones are available
    # there is a zone Offset variable, to make sure no collisions are present with private subnet blocks
    for zone_id in data.aws_availability_zones.usw2[0].zone_ids :
    cidrsubnet(var.usw2_main_network_block, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  tags = local.tags
}

################################
#### VPC Peering Connections ###
################################

# us-east-1 <-> us-east-2
module "vpc_peering_connection_use1_use2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-peering-connection"

  providers = {
    aws.requester = aws.use1
    aws.accepter  = aws.use2
  }

  requester_vpc_id       = local.vpc_id_use1
  accepter_vpc_id        = local.vpc_id_use2
  requester_route_tables = local.route_tables_use1
  accepter_route_tables  = local.route_tables_use2
}

# us-east-2 <-> us-west-2
module "vpc_peering_connection_use1_usw2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-peering-connection"

  providers = {
    aws.requester = aws.use1
    aws.accepter  = aws.usw2
  }

  requester_vpc_id       = local.vpc_id_use1
  accepter_vpc_id        = local.vpc_id_usw2
  requester_route_tables = local.route_tables_use1
  accepter_route_tables  = local.route_tables_usw2
}

# us-east-2 <-> us-west-2
module "vpc_peering_connection_use2_usw2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-peering-connection"

  providers = {
    aws.requester = aws.use2
    aws.accepter  = aws.usw2
  }

  requester_vpc_id       = local.vpc_id_use2
  accepter_vpc_id        = local.vpc_id_usw2
  requester_route_tables = local.route_tables_use2
  accepter_route_tables  = local.route_tables_usw2
}

#####################
### VPC Endpoints ###
#####################
module "vpc_endpoints_use1" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-endpoints"

  providers = {
    aws = aws.use1
  }

  vpc_id          = local.vpc_id_use1
  public_subnets  = local.public_subnets_use1
  private_subnets = local.private_subnets_use1
  vpc_cidr_blocks = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]

  tags = local.tags
}

module "vpc_endpoints_use2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-endpoints"

  providers = {
    aws = aws.use2
  }

  vpc_id          = local.vpc_id_use2
  public_subnets  = local.public_subnets_use2
  private_subnets = local.private_subnets_use2
  vpc_cidr_blocks = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]

  tags = local.tags
}

module "vpc_endpoints_usw2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-endpoints"

  providers = {
    aws = aws.usw2
  }

  vpc_id          = local.vpc_id_usw2
  public_subnets  = local.public_subnets_usw2
  private_subnets =local.public_subnets_usw2
  vpc_cidr_blocks = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]

  tags = local.tags
}

################################
#### ECS Clusters ##############
################################

resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

# us-east-1
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.0.0"

  name               = var.environment
  container_insights = true
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]

  tags = local.tags

  depends_on = [ aws_iam_service_linked_role.ecs ]
}

################################
## ECS EC2 ASG for us-east-1 ###
################################

module "ec2_profile" {
  count = var.test_controller_launch_type == "EC2" ? 1 : 0

  source  = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  version = "3.0.0"

  name = "ecs-asg"

  tags = local.tags
}

# Lookup the ECS Optimized AMI for use in the ECS Cluster
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# ECS sec group
module "ecs_cluster_security_group" {
  count = var.test_controller_launch_type == "EC2" ? 1 : 0

  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "ecs-cluster-sg"
  vpc_id = local.vpc_id_use1

  # Allow all incoming traffic from within VPC
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = join(",",[
        var.use1_main_network_block,
        var.use2_main_network_block,
        var.usw2_main_network_block
      ])
    }
  ]
  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

# Create the autoscale group
module "ecs_cluster_asg" {
  count = var.test_controller_launch_type == "EC2" ? 1 : 0

  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.9.0"

  name = "ecs-cluster-asg"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "ecs-cluster-lc"

  image_id                     = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type                = var.cluster_instance_type
  security_groups              = [module.ecs_cluster_security_group[0].this_security_group_id]
  associate_public_ip_address  = false
  recreate_asg_when_lc_changes = false
  iam_instance_profile         = module.ec2_profile[0].iam_instance_profile_id

  user_data = templatefile("${path.module}/templates/user-data.sh", { cluster_name = module.ecs.ecs_cluster_id })


  # Auto scaling group
  vpc_zone_identifier       = local.private_subnets_use1
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "terraform"
      propagate_at_launch = true
    }
  ]
}


################################
#### Binary Storage ############
################################

# Binaries S3 Bucket
resource "aws_s3_bucket" "binaries" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-binaries"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = local.tags

  versioning {
    enabled = true
  }
}

################################
#### Test Results Storage ######
################################

# Test outputs S3 Bucket
resource "aws_s3_bucket" "agent_outputs" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-agent-outputs"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = local.tags
}

################################
#### Test Controller ###########
################################

module "test_controller_service" {
  source = "./modules/test-controller"

  vpc_id                                    = local.vpc_id_use1
  vpc_cidr_blocks                               = [
        var.use1_main_network_block,
        var.use2_main_network_block,
        var.usw2_main_network_block
  ]
  public_subnets                            = local.public_subnets_use1
  private_subnets                           = local.private_subnets_use1
  hosted_zone_id                            = local.hosted_zone_id
  azs                                       = local.vpc_azs_use1
  cluster_id                                = module.ecs.ecs_cluster_id
  dns_base_domain                           = var.base_domain
  binaries_s3_bucket                        = aws_s3_bucket.binaries.id
  binaries_s3_bucket_arn                    = aws_s3_bucket.binaries.arn
  outputs_s3_bucket                         = aws_s3_bucket.agent_outputs.id
  create_certbot_lambda                     = var.create_certbot_lambda
  lets_encrypt_email                        = var.lets_encrypt_email
  s3_interface_endpoint                     = local.s3_interface_endpoint_use1
  launch_type                               = var.test_controller_launch_type
  cpu                                       = var.test_controller_cpu
  memory                                    = var.test_controller_memory
  health_check_grace_period_seconds         = var.test_controller_health_check_grace_period_seconds
  transaction_processor_repo_url            = var.transaction_processor_repo_url
  transaction_processor_main_branch         = var.transaction_processor_main_branch
  transaction_processor_github_access_token = var.transaction_processor_github_access_token
  uhs_seed_generator_job_name               = module.uhs_seed_generator[0].job_name
  uhs_seed_generator_job_definiton_arn      = module.uhs_seed_generator[0].job_definiton_arn
  uhs_seed_generator_job_queue_arn          = module.uhs_seed_generator[0].job_queue_arn

  # Tags
  tags = local.tags
}

module "uhs_seed_generator" {
  source = "./modules/uhs-seed-generator"

  count = var.create_uhs_seed_generator ? 1 : 0

  vpc_id                 = local.vpc_id_use1
  private_subnets        = local.private_subnets_use1
  max_vcpus              = var.uhs_seed_generator_max_vcpus
  job_vcpu               = var.uhs_seed_generator_job_vcpu
  job_memory             = var.uhs_seed_generator_job_memory
  binaries_s3_bucket     = aws_s3_bucket.binaries.id

  # Tags
  tags                   = local.tags
}

module "opensearch" {
  source = "./modules/opensearch"

  count = var.create_opensearch ? 1 : 0

  environment                  = var.environment
  opensearch_instance_type     = var.opensearch_instance_type
  opensearch_instance_count    = var.opensearch_instance_count
  opensearch_ebs_volume_type   = var.opensearch_ebs_volume_type
  opensearch_ebs_volume_size   = var.opensearch_ebs_volume_size
  fire_hose_buffering_interval = var.fire_hose_buffering_interval

  # Tags
  tags                       = local.tags
}

################################
#### Test Controller Agents ####
################################

# Region: us-east-1
resource "aws_cloudwatch_log_group" "agents_use1" {
  name              = "/test-controller-agents-us-east-1"
  retention_in_days = 1
}

module "test_controller_agent_use1" {
  source = "./modules/test-controller-agent"

  providers = {
    aws = aws.use1
  }

  vpc_id                    = local.vpc_id_use1
  public_subnets            = local.public_subnets_use1
  private_subnets           = local.private_subnets_use1
  public_key                = var.ec2_public_key
  binaries_s3_bucket        = aws_s3_bucket.binaries.id
  outputs_s3_bucket         = aws_s3_bucket.agent_outputs.id
  outputs_s3_bucket_arn     = aws_s3_bucket.agent_outputs.arn
  s3_interface_endpoint     = local.s3_interface_endpoint_use1
  controller_endpoint       = module.test_controller_service.agent_endpoint
  controller_port           = module.test_controller_service.agent_port
  log_group                 = aws_cloudwatch_log_group.agents_use1.name
  instance_types            = var.agent_instance_types

  # Tags
  tags = local.tags
}

# Region: us-east-2
resource "aws_cloudwatch_log_group" "agents_use2" {
  name              = "/test-controller-agents-us-east-2"
  retention_in_days = 1
}

module "test_controller_agent_use2" {
  source = "./modules/test-controller-agent"

  providers = {
    aws = aws.use2
  }

  vpc_id                    = local.vpc_id_use2
  public_subnets            = local.public_subnets_use2
  private_subnets           = local.private_subnets_use2
  public_key                = var.ec2_public_key
  binaries_s3_bucket        = aws_s3_bucket.binaries.id
  outputs_s3_bucket         = aws_s3_bucket.agent_outputs.id
  outputs_s3_bucket_arn     = aws_s3_bucket.agent_outputs.arn
  s3_interface_endpoint     = local.s3_interface_endpoint_use1
  controller_endpoint       = module.test_controller_service.agent_endpoint
  controller_port           = module.test_controller_service.agent_port
  log_group                 = aws_cloudwatch_log_group.agents_use2.name
  instance_types            = var.agent_instance_types

  # Tags
  tags = local.tags
}

# Region: us-west-2
resource "aws_cloudwatch_log_group" "agents_usw2" {
  name              = "/test-controller-agents-us-west-2"
  retention_in_days = 1
}

module "test_controller_agent_usw2" {
  source = "./modules/test-controller-agent"

  providers = {
    aws = aws.usw2
  }

  vpc_id                    = local.vpc_id_usw2
  public_subnets            = local.public_subnets_usw2
  private_subnets           = local.public_subnets_usw2
  public_key                = var.ec2_public_key
  binaries_s3_bucket        = aws_s3_bucket.binaries.id
  outputs_s3_bucket         = aws_s3_bucket.agent_outputs.id
  outputs_s3_bucket_arn     = aws_s3_bucket.agent_outputs.arn
  s3_interface_endpoint     = local.s3_interface_endpoint_use1
  controller_endpoint       = module.test_controller_service.agent_endpoint
  controller_port           = module.test_controller_service.agent_port
  log_group                 = aws_cloudwatch_log_group.agents_usw2.name
  instance_types            = var.agent_instance_types

  # Tags
  tags = local.tags
}

################################
#### Test Controller Deploy ####
################################

module "test_controller_deploy" {
  source = "./modules/test-controller-deploy"

  vpc_id                           = local.vpc_id_use1
  private_subnets                  = local.private_subnets_use1
  binaries_s3_bucket               = aws_s3_bucket.binaries.id
  cluster_name                     = module.ecs.ecs_cluster_name
  test_controller_ecr_repo         = module.test_controller_service.ecr_repo
  test_controller_ecs_service_name = module.test_controller_service.ecs_service_name
  uhs_seed_generator_ecr_repo      = module.uhs_seed_generator[0].ecr_repo
  github_repo                      = var.test_controller_github_repo
  github_repo_owner                = var.test_controller_github_repo_owner
  github_repo_branch               = var.test_controller_github_repo_branch
  github_access_token              = var.test_controller_github_access_token
  s3_interface_endpoint            = local.s3_interface_endpoint_use1
  node_container_build_image       = var.test_controller_node_container_build_image
  golang_container_build_image     = var.test_controller_golang_container_build_image
  app_container_base_image         = var.test_controller_app_container_base_image

  # Tags
  tags = local.tags
}

################################
#### Route 53 DNS ##############
################################

module "route53_dns" {
  count = var.create_networking ? 1 : 0

  source = "./modules/route53_dns"

  dns_base_domain = var.base_domain

  # Tags
  tags = local.tags
}

################################
#### Bastion Host ##############
################################

module "bastion" {
  source = "./modules/bastion"

  vpc_id          = local.vpc_id_use1
  public_subnets  = local.public_subnets_use1
  public_key      = var.ec2_public_key
  hosted_zone_id  = local.hosted_zone_id
  certs_efs_id    = module.test_controller_service.certs_efs_id
  testruns_efs_id = module.test_controller_service.testruns_efs_id
  binaries_efs_id = module.test_controller_service.binaries_efs_id
  dns_base_domain = var.base_domain

  # Tags
  environment = var.environment
}
