locals {
  name            = "test-controller"
  agent_port      = "8081"
  ui_port         = "443"
  ui_port_wo_cert = "8443"
  tags            = var.tags
}

# get the current aws region
data "aws_region" "current" {}

# Frontend/UI Loadbalancer
module "ui_nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.13.0"

  name = "${local.name}-ui-nlb"

  load_balancer_type = "network"

  vpc_id  = var.vpc_id
  subnets = var.public_subnets

  target_groups = [
    {
      name_prefix          = "ui-"
      backend_protocol     = "TCP"
      backend_port         = tonumber(local.ui_port)
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 10
        port                = tonumber(local.ui_port_wo_cert)
        protocol            = "HTTPS"
        path                = "/health"
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    },
    {
      name_prefix          = "auth-"
      backend_protocol     = "TCP"
      backend_port         = tonumber(local.ui_port_wo_cert)
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 10
        port                = tonumber(local.ui_port_wo_cert)
        protocol            = "HTTPS"
        path                = "/health"
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = tonumber(local.ui_port)
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = tonumber(local.ui_port_wo_cert)
      protocol           = "TCP"
      target_group_index = 1
    }
  ]

  tags = local.tags
}

# Backend/Agent Loadbalancer
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.13.0"

  name = "${local.name}-agent-nlb"

  load_balancer_type = "network"

  vpc_id  = var.vpc_id
  subnets = var.private_subnets
  internal = true

  target_groups = [
    {
      name_prefix      = "agent-"
      backend_protocol = "TCP"
      backend_port     = tonumber(local.agent_port)
      target_type      = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 10
        port                = tonumber(local.ui_port_wo_cert)
        protocol            = "HTTPS"
        path                = "/health"
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = tonumber(local.agent_port)
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = local.tags
}


# Create CNAMES for load balancers
resource "aws_route53_record" "ui_nlb" {
  zone_id = var.hosted_zone_id
  name    = "${local.name}.${var.dns_base_domain}"
  type    = "CNAME"
  ttl     = "5"
  records = [ module.ui_nlb.this_lb_dns_name ]
}

# Create CNAMES for load balancers
resource "aws_route53_record" "nlb" {
  zone_id = var.hosted_zone_id
  name    = "${local.name}-agents.${var.dns_base_domain}"
  type    = "CNAME"
  ttl     = "5"
  records = [ module.nlb.this_lb_dns_name ]
}


## ECS Service

# ECR Repo for app container
resource "aws_ecr_repository" "app" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "service" {
  name             = local.name
  cluster          = var.cluster_id
  platform_version = var.launch_type == "FARGATE" ? "1.4.0" : null
  desired_count    = 1
  launch_type      = var.launch_type

  # Destroy old instance before new instance runs
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  # Ingore LB health checks for grace period
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    security_groups = [module.task_security_group.this_security_group_id]
    subnets         = var.private_subnets
  }

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.task.family}:${max(aws_ecs_task_definition.task.revision, data.aws_ecs_task_definition.task.revision)}"

  load_balancer {
    container_name   = local.name
    container_port   = tonumber(local.ui_port)
    target_group_arn = module.ui_nlb.target_group_arns[0]
  }

  load_balancer {
    container_name   = local.name
    container_port   = tonumber(local.ui_port_wo_cert)
    target_group_arn = module.ui_nlb.target_group_arns[1]
  }

  load_balancer {
    container_name   = local.name
    container_port   = tonumber(local.agent_port)
    target_group_arn = module.nlb.target_group_arns[0]
  }

  tags = local.tags
}

# ECS sec group
module "task_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "ecs-task-sg"
  vpc_id = var.vpc_id

  # Allow all incoming traffic from within VPC
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "10.0.0.0/16"
    }
  ]
  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

# Parameter Store

resource "aws_ssm_parameter" "transaction_processor_github_access_token" {
  count = var.transaction_processor_github_access_token != "" ? 1 : 0

  name  = "/global/github/test-controller/transaction-repo-access-token"
  type  = "SecureString"
  value = var.transaction_processor_github_access_token
}

# ECS Fargate Task Definition

data "aws_ecs_task_definition" "task" {
  depends_on = [aws_ecs_task_definition.task]
  task_definition = aws_ecs_task_definition.task.family
}

# https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
resource "aws_ecs_task_definition" "task" {
  family                   = local.name
  requires_compatibilities = [var.launch_type]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "${aws_ecr_repository.app.repository_url}:latest",
    "name": "${local.name}",
    "environment": [
      {
        "name": "BINARIES_S3_BUCKET",
        "value": "${var.binaries_s3_bucket}"
      },
      {
        "name": "OUTPUTS_S3_BUCKET",
        "value": "${var.outputs_s3_bucket}"
      },
      {
        "name": "S3_INTERFACE_ENDPOINT",
        "value": "${var.s3_interface_endpoint}"
      },
      {
        "name": "S3_INTERFACE_REGION",
        "value": "us-east-1"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${data.aws_region.current.name}"
      },
      {
        "name": "HTTPS_PORT",
        "value": "${local.ui_port}"
      },
      {
        "name": "HTTPS_WITHOUT_CLIENT_CERT_PORT",
        "value": "${local.ui_port_wo_cert}"
      },
      {
        "name": "PORT",
        "value": "${local.agent_port}"
      },
      {
        "name": "TRANSACTION_PROCESSOR_REPO_URL",
        "value" : "${var.transaction_processor_repo_url}"
      },
      {
        "name": "TRANSACTION_PROCESSOR_MAIN_BRANCH",
        "value" : "${var.transaction_processor_main_branch}"
      },
      {   
        "name": "UHS_SEEDER_BATCH_JOB",
        "value": "${var.uhs_seed_generator_job_name}"
      }
    ],
    %{if var.transaction_processor_github_access_token != ""}
    "secrets": [
      {
          "name": "TRANSACTION_PROCESSOR_ACCESS_TOKEN",
          "valueFrom": "${aws_ssm_parameter.transaction_processor_github_access_token[0].arn}"
      }
    ],
    %{ else }%{ endif }
    "portMappings": [
      {
        "containerPort": ${tonumber(local.ui_port)}
      },
      {
        "containerPort": ${tonumber(local.ui_port_wo_cert)}
      },
      {
        "containerPort": ${tonumber(local.agent_port)}
      }
    ],
    "ulimits": [
        {
          "name": "nofile",
          "softLimit": 32768,
          "hardLimit": 32768
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.app.name}",
        "awslogs-stream-prefix": "${local.name}"
      }
    },
    "mountPoints": [
      {
        "containerPath": "/app/data/certs/",
        "sourceVolume": "certs"
      },
      {
        "containerPath": "/app/data/testruns/",
        "sourceVolume": "testruns"
      },
      {
        "containerPath": "/app/data/binaries/",
        "sourceVolume": "binaries"
      }
    ]
  }
]
DEFINITION

  volume {
    name = "certs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.certs.id
      transit_encryption = "ENABLED"
    }
  }

  volume {
    name = "testruns"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.testruns.id
      transit_encryption = "ENABLED"
    }
  }

  volume {
    name = "binaries"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.binaries.id
      transit_encryption = "ENABLED"
    }
  }

  tags = local.tags
}

## ECS Service and Fargate Task

# ECS Task Execution Role Policy Document
# https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task Execution Role Policy Actions Document
# https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "ecs_task_execution_role_policy_actions" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }

  dynamic "statement" {
    for_each = try(aws_ssm_parameter.transaction_processor_github_access_token, [])

    content {
      actions = [
        "ssm:GetParameters",
      ]

      resources = [
        statement.value.arn
      ]
    }
  }

}

# ECS Task Execution IAM Role
# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.name}_ecs_task_execution_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json

  tags = local.tags
}

# ECS Task Execution IAM Policy
# https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "${local.name}_ecs_task_execution_role_policy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_task_execution_role_policy_actions.json
}


## ECS Task Role

# ECS Task Role Policy Document
# https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task Role Policy Actions Document
# https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "ecs_task_role_policy_actions" {
  statement {
    actions = [
      "ec2:*",
      "servicequotas:Get*",
      "servicequotas:List*",
      "iam:PassRole"
    ]

    resources = [
      "*"
    ]
  }
}

# ECS Task Role S3 Write Policy Actions Document
# https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "ecs_task_role_policy_s3_write_actions" {
  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
      var.binaries_s3_bucket_arn,
      "${var.binaries_s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_role_policy_batch_submit_jobs_actions" {
  statement {
    actions = [
      "batch:SubmitJob"
    ]

    resources = [
      var.uhs_seed_generator_job_definiton_arn,
      var.uhs_seed_generator_job_queue_arn
    ]
  }

  statement {
    actions = [
      "batch:DescribeJobs"
    ]

    resources = ["*"]
  }
}

# ECS Task IAM Role
# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.name}_ecs_task_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json

  tags = local.tags
}

# ECS Task IAM Policy
# https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name   = "${local.name}_ecs_task_role_policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role_policy_actions.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_read_only" {
  role       = aws_iam_role.ecs_task_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy" "ecs_task_role_s3_write_policy" {
  name   = "${local.name}_ecs_task_role_s3_write_policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role_policy_s3_write_actions.json
}

resource "aws_iam_role_policy" "ecs_task_role_batch_submit_jobs_policy" {
  name   = "${local.name}_ecs_task_role_batch_submit_jobs_policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role_policy_batch_submit_jobs_actions.json
}

# Cloudwatch Logs Group for ECS Fargate Task logs
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${local.name}"
  retention_in_days = 1

  tags = local.tags
}

# EFS

# EFS sec group
module "efs_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "efs-sg"
  vpc_id = var.vpc_id

  # Allow NFS/EFS incoming traffic from within VPC
  ingress_with_cidr_blocks = [
    {
      rule        = "nfs-tcp"
      cidr_blocks = join(",", var.vpc_cidr_blocks)
    }
  ]

  tags = local.tags
}

resource "aws_efs_file_system" "certs" {
  creation_token = "certs"
  encrypted = true

  tags = merge(
    {
      Name = "${local.name}-certs"
    },
    local.tags
  )
}

resource "aws_efs_backup_policy" "certs_backup_policy" {
  file_system_id = aws_efs_file_system.certs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_file_system" "testruns" {
  creation_token = "testruns"
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = merge(
    {
      Name = "${local.name}-testruns"
    },
    local.tags
  )
}

resource "aws_efs_backup_policy" "testruns_backup_policy" {
  file_system_id = aws_efs_file_system.testruns.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_file_system" "binaries" {
  creation_token = "binaries"
  encrypted = true

  tags = merge(
    {
      Name = "${local.name}-binaries"
    },
    local.tags
  )
}

resource "aws_efs_backup_policy" "binaries_backup_policy" {
  file_system_id = aws_efs_file_system.binaries.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "certs" {
  count = length(var.private_subnets)

  file_system_id  = aws_efs_file_system.certs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [ module.efs_security_group.this_security_group_id ]
}

resource "aws_efs_mount_target" "testruns" {
  count = length(var.private_subnets)
  
  file_system_id  = aws_efs_file_system.testruns.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [ module.efs_security_group.this_security_group_id ]
}

resource "aws_efs_mount_target" "binaries" {
  count = length(var.private_subnets)

  file_system_id  = aws_efs_file_system.binaries.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [ module.efs_security_group.this_security_group_id ]
}

resource "aws_efs_access_point" "certs" {
  file_system_id = aws_efs_file_system.certs.id

  posix_user {
    gid = 0
    uid = 0
  }

  tags = local.tags
}

resource "aws_efs_access_point" "testruns" {
  file_system_id = aws_efs_file_system.testruns.id

  posix_user {
    gid = 0
    uid = 0
  }

  tags = local.tags
}

resource "aws_efs_access_point" "binaries" {
  file_system_id = aws_efs_file_system.binaries.id

  posix_user {
    gid = 0
    uid = 0
  }

  tags = local.tags
}

# Certbot Lambda

# Lambda sec group
module "certbot_security_group" {
  count = var.create_certbot_lambda ? 1 : 0

  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "certbot-sg"
  vpc_id = var.vpc_id

  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

# Inpired by: https://arkadiyt.com/2018/01/26/deploying-effs-certbot-in-aws-lambda/
module "certbot_lambda" {
  count = var.create_certbot_lambda ? 1 : 0

  source  = "terraform-aws-modules/lambda/aws"
  version = "1.48.0"

  function_name = "${local.name}-certbot-lambda"
  description   = "Certbot lambda"
  handler       = "main.handler"
  runtime       = "python3.8"
  timeout       = 120

  build_in_docker = true

  source_path = "${path.module}/lambda/certbot"

  vpc_subnet_ids         = var.private_subnets
  vpc_security_group_ids = [ module.certbot_security_group[0].this_security_group_id ]

  environment_variables = {
    LETSENCRYPT_DOMAINS  = "${local.name}.${var.dns_base_domain}"
    LETSENCRYPT_EMAIL    = var.lets_encrypt_email
    EFS_ACCESS_POINT_PATH = "/mnt/certs"
  }

  attach_network_policy  = true

  attach_policy = true
  policy        = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"

  attach_policy_statements = true
  policy_statements = {
    acm = {
      effect  = "Allow",
      actions = [
        "acm:AddTagsToCertificate",
        "acm:DescribeCertificate",
        "acm:ImportCertificate",
        "acm:ListCertificates"
      ],
      resources = ["*"]
    },
    route53 = {
      effect  = "Allow",
      actions = [
        "route53:ChangeResourceRecordSets",
        "route53:GetChange",
        "route53:ListHostedZones"
      ],
      resources = ["*"]
    }
  }

  file_system_arn              = aws_efs_access_point.certs.arn
  file_system_local_mount_path = "/mnt/certs"

  # Explicitly declare dependency on EFS mount target.
  # When creating or updating Lambda functions, mount target must be in 'available' lifecycle state.
  # Note: depends_on on modules became available in Terraform 0.13
  depends_on = [aws_efs_mount_target.certs]

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    event = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.certbot_timer_rule[0].arn
    }
  }

  tags = merge(
    {
      Name = "${local.name}-certbot-lambda"
    },
    local.tags
  )
}

# Create a timer that runs every 12 hours
resource "aws_cloudwatch_event_rule" "certbot_timer_rule" {
  count = var.create_certbot_lambda ? 1 : 0

  name                = "certbot_timer"
  schedule_expression = "cron(0 */12 * * ? *)"

  tags = merge(
    {
      Name = "${local.name}-certbot-lambda"
    },
    local.tags
  )
}

# Specify the lambda function to run
resource "aws_cloudwatch_event_target" "certbot_timer_target" {
  count = var.create_certbot_lambda ? 1 : 0

  rule = aws_cloudwatch_event_rule.certbot_timer_rule[0].name
  arn  = module.certbot_lambda[0].this_lambda_function_arn
}
