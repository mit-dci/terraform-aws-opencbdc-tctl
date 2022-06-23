locals {
  name = "test-controller-agent"
  tags = var.tags
}

# get the current aws region
data "aws_region" "current" {}

# used for accesing Account ID and ARN
data "aws_caller_identity" "current" {}

# Agent Instance sec group
module "agent_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "agent-instance-sg"
  vpc_id = var.vpc_id

  # Allow all incoming traffic from within peered VPCs
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "10.0.0.0/8"
    }
  ]
  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

# Agent ec2 cloud-init template
data "template_file" "cloud_init" {
    template = file("${path.module}/templates/init.tpl")

    vars = {
        REGION                = data.aws_region.current.name
        BINARIES_S3_BUCKET    = var.binaries_s3_bucket
        OUTPUTS_S3_BUCKET     = var.outputs_s3_bucket
        S3_BUCKET_PREFIX      = local.name
        S3_INTERFACE_ENDPOINT = var.s3_interface_endpoint
        S3_INTERFACE_REGION   = "us-east-1"
        COORDINATOR_HOST      = var.controller_endpoint
        COORDINATOR_PORT      = var.controller_port
    }
}

# Cloud-init config
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }
}

data "aws_ec2_instance_type" "agent" {
  for_each = toset(var.instance_types)
  instance_type = each.key
}

resource "aws_key_pair" "agent" {
  key_name   = local.name
  public_key = var.public_key

  tags = local.tags
}

data "aws_ami" "agent" {
  most_recent = true
  owners = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220528"]
  }

  filter {
        name = "virtualization-type"
        values = ["hvm"]
  }
}

# Agent EC2 Launch Template
resource "aws_launch_template" "agent" {
  for_each = toset(var.instance_types)
  name = "${local.name}-${each.key}"

  iam_instance_profile {
    name = module.instance_profile_role.iam_instance_profile_name
  }

  image_id                             = data.aws_ami.agent.id
  instance_type                        = each.key
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.agent.id
  user_data                            = data.template_cloudinit_config.config.rendered
  update_default_version               = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 100
    }
  }

  network_interfaces {
    subnet_id             = var.private_subnets[0]
    security_groups       = [module.agent_security_group.this_security_group_id]
    delete_on_termination = true
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = local.name
      },
      local.tags
    )
  }

  tags = merge(
    {
      Name = local.name,
      Interface_Description = "${each.key} (${data.aws_ec2_instance_type.agent[each.key].default_vcpus}vCPU / ${tonumber(data.aws_ec2_instance_type.agent[each.key].memory_size)/1024}GB RAM / Bandwidth: ${data.aws_ec2_instance_type.agent[each.key].network_performance} / ${data.aws_region.current.name})"
    },
    local.tags
  )
}

module "instance_profile_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5"

  role_name               = "agent-role-${data.aws_region.current.name}"
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services = ["ec2.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    module.agent_outputs_iam_policy.arn
  ]

  tags = local.tags
}

module "agent_outputs_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 3.0"

  name        = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-AgentOutputsS3WritePolicy"
  path        = "/"
  description = "Allow write to agent-outputs bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.outputs_s3_bucket_arn}",
        "${var.outputs_s3_bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_ssm_parameter" "cw_agent_config" {
  name  = "AmazonCloudWatch-Config.json"
  type  = "String"
  value = <<CONFIG
{
  "agent": {
    "region": "us-east-1"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/cbdc_agent*.log",
            "log_group_name": "${var.log_group}",
            "log_stream_name": "{instance_id}-${local.name}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${var.log_group}",
            "log_stream_name": "{instance_id}-${local.name}-cloud-init-output",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CONFIG

  tags = local.tags
}
