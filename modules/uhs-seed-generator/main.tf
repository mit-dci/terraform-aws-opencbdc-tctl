locals {
    name = "uhs_seed_generator"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "binaries_s3_bucket" {
  bucket = var.binaries_s3_bucket
}

###########
### ECR ###
###########
resource "aws_ecr_repository" "this" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"

  tags = var.tags
}


#############################
#### Compute Environment ####
#############################
resource "aws_batch_compute_environment" "this" {
  compute_environment_name = local.name

  compute_resources {
    max_vcpus = var.max_vcpus

    security_group_ids = [
      module.batch_security_group.this_security_group_id
    ]

    subnets = var.private_subnets

    type = "FARGATE"
  }

  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service_role]
}


# Agent Instance sec group
module "batch_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "batch-compute"
  vpc_id = var.vpc_id

  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}


##################
### Job Queues ###
##################
resource "aws_batch_job_queue" "this" {
  name                 = local.name
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.this.arn]
}


##############################
### Create Repoort Job Def ###
##############################
resource "aws_batch_job_definition" "this" {
  name = local.name
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]

  timeout {
    attempt_duration_seconds = var.batch_job_timeout
  }

  container_properties = jsonencode({
      "image": "${aws_ecr_repository.this.repository_url}:latest",
      "fargatePlatformConfiguration": {
          "platformVersion": "LATEST"
      },
      "resourceRequirements": [
          {"type": "VCPU", "value": var.job_vcpu},
          {"type": "MEMORY", "value": var.job_memory}
      ],
      "environment": [
          {"name": "BINARIES_S3_BUCKET", "value": var.binaries_s3_bucket}
      ],
      "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
              "awslogs-group" : "/aws/batch/${local.name}",
              "awslogs-region" : data.aws_region.current.name
          },
          "secretOptions" : []
      },
      "executionRoleArn": aws_iam_role.task_execution_role.arn,
      "jobRoleArn" : aws_iam_role.batch_job_role.arn
  })
}


############
### Logs ###
############
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/batch/${local.name}"
  retention_in_days = 30

  tags = var.tags
}


###########
### IAM ###
###########
# ECS Service Role
resource "aws_iam_role" "batch_service_role" {
  name                 = "batch-service"
  assume_role_policy   = data.aws_iam_policy_document.batch_service_role_policy.json

  tags = var.tags
}

data "aws_iam_policy_document" "batch_service_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "batch_service_role" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# ECS task execution role
resource "aws_iam_role" "task_execution_role" {
  name               = "batch_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

resource "aws_iam_role" "batch_job_role" {
  name                 = "transaction_batch_job_role"
  assume_role_policy   = data.aws_iam_policy_document.batch_job_role_policy.json
  tags = var.tags
}

data "aws_iam_policy_document" "batch_job_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "preseed_bucket_access" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = aws_iam_policy.preseed_bucket_access.arn
}

resource "aws_iam_policy" "preseed_bucket_access" {
  name   = "preseed_bucket_access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:ListObjects",
          "s3:CopyObject"
        ],
        "Resource": [data.aws_s3_bucket.binaries_s3_bucket.arn]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "${data.aws_s3_bucket.binaries_s3_bucket.arn}/shard-preseeds/*",
          "${data.aws_s3_bucket.binaries_s3_bucket.arn}/binaries/*"
        ]
      }
    ]
  })
}
