locals {
  name = var.name
}

#################
### Endpoints ###
#################
data "aws_route_tables" "this" {
  vpc_id = var.vpc_id
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = var.vpc_id
  security_group_ids = [module.vpc_endpoint_security_group.this_security_group_id]

  endpoints = {
    s3 = {
      service             = "s3"
      tags                = merge({ Name = "s3-interface" }, var.tags)
      subnet_ids = var.private_subnets
    },
    # For ECS pulls from ECR
    s3_gateway = {
      service      = "s3"
      service_type    = "Gateway"
      route_table_ids = data.aws_route_tables.this.ids
      tags    = merge({ Name = "s3-gateway" }, var.tags)
    },
    cloudwatch_logs = {
      service = "logs"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = {Name = "cloudwatch-logs"}
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecr-dkr"}, var.tags)
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecr-api"}, var.tags)
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecs"}, var.tags)
    },
    ecs_telemetry = {
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecs-telemetry"}, var.tags)
    },
    ecs_agent = {
      service             = "ecs-agent"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecs-agent"}, var.tags)
    }
  }
}

######################
### Security Group ###
######################
module "vpc_endpoint_security_group" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "${local.name}-vpc-endpoint-sg"
  vpc_id = var.vpc_id

  # Allow all within the vpcs
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = join(",", var.vpc_cidr_blocks)
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = join(",", var.vpc_cidr_blocks)
    }
  ]

  tags = var.tags
}
