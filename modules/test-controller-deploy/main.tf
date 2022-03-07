locals {
  name = "test-controller"
  tags = var.tags
}

################################
#### DEPLOY ####################
################################

# get the current aws region
data "aws_region" "current" {}

# used for accesing Account ID and ARN
data "aws_caller_identity" "current" {}

# Region: us-east-1
resource "aws_s3_bucket" "pipeline" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${local.name}-codepipeline"
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

data "aws_iam_policy_document" "assume_by_pipeline" {
  statement {
    sid     = "AllowAssumeByPipeline"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${local.name}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_pipeline.json

  tags = local.tags
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowCodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECS"
    effect = "Allow"

    actions = ["ecs:*"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    resources = ["*"]

    actions = ["iam:PassRole"]

    condition {
      test     = "StringLike"
      values   = ["ecs-tasks.amazonaws.com"]
      variable = "iam:PassedToService"
    }
  }

  statement {
    sid    = "AllowLambdaInvoke"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  role   = aws_iam_role.pipeline.name
  policy = data.aws_iam_policy_document.pipeline.json
}

data "aws_iam_policy_document" "assume_by_codebuild" {
  statement {
    sid     = "AllowAssumeByCodebuild"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${local.name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_codebuild.json

  tags = local.tags
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRAuth"
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRUpload"
    effect = "Allow"

    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowECSDescribeTaskDefinition"
    effect    = "Allow"
    actions   = ["ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowSSM"
    effect = "Allow"

    actions = [
      "ssm:GetParameters*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild_attach_eni" {
  statement {
      effect = "Allow"
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ]
      resources =  ["*"]
    }

    statement {
      effect = "Allow"
      actions = [
        "ec2:CreateNetworkInterfacePermission"
      ]
      resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"]
  }
}

resource "aws_iam_role_policy" "codebuild_attach_eni" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild_attach_eni.json
}


# Codepipeline Security Group
module "codepipeline_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "${local.name}-pipeline-sg"
  vpc_id = var.vpc_id

  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}

resource "aws_codebuild_project" "controller_build" {
  name         = "${local.name}-controller-build"
  description  = "Codebuild"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.private_subnets
    security_group_ids = [module.codepipeline_security_group.this_security_group_id]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.test_controller_ecr_repo
    }
    environment_variable {
      name  = "SERVICE_NAME"
      value = var.test_controller_ecs_service_name
    }
    environment_variable {
      name  = "NODE_BUILD_IMAGE"
      value = var.node_container_build_image
    }
    environment_variable {
      name  = "GOLANG_BUILD_IMAGE"
      value = var.golang_container_build_image
    }
    environment_variable {
      name  = "APP_BASE_IMAGE"
      value = var.app_container_base_image
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - |
        docker build \
          --build-arg GIT_DATE=`date "+%Y%m%d"` \
          --build-arg GIT_COMMIT=$CODEBUILD_RESOLVED_SOURCE_VERSION \
          --build-arg NODE_BUILD_IMAGE=$NODE_BUILD_IMAGE \
          --build-arg GOLANG_BUILD_IMAGE=$GOLANG_BUILD_IMAGE \
          --build-arg APP_BASE_IMAGE=$APP_BASE_IMAGE \
          -f Dockerfile.coordinator \
          -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - echo Writing image definitions file...
      - printf '[{"name":"%s","imageUri":"%s"}]' $SERVICE_NAME $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
BUILDSPEC
  }

  tags = local.tags
}

resource "aws_codebuild_project" "agent_build" {
  name         = "${local.name}-agent-build"
  description  = "Codebuild"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.private_subnets
    security_group_ids = [module.codepipeline_security_group.this_security_group_id]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "GOLANG_BUILD_IMAGE"
      value = var.golang_container_build_image
    }
    environment_variable {
      name  = "APP_BASE_IMAGE"
      value = var.app_container_base_image
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - |
        docker build \
          --build-arg GIT_DATE=`date "+%Y%m%d"` \
          --build-arg GIT_COMMIT=$CODEBUILD_RESOLVED_SOURCE_VERSION \
          --build-arg GOLANG_BUILD_IMAGE=$GOLANG_BUILD_IMAGE \
          --build-arg APP_BASE_IMAGE=$APP_BASE_IMAGE \
          -f Dockerfile.agent \
          -t agent:latest .
      - docker tag agent:latest agent:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - docker container create --name temp agent:latest
      - docker container cp temp:/app/agent ./agent-latest
artifacts:
  files:
    - agent-latest
BUILDSPEC
  }

  tags = local.tags
}

resource "aws_codebuild_project" "uhs_seed_generator" {
  name         = "${local.name}-uhs-seed-generator"
  description  = "Codebuild"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.private_subnets
    security_group_ids = [module.codepipeline_security_group.this_security_group_id]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.uhs_seed_generator_ecr_repo
    }
    environment_variable {
      name  = "APP_BASE_IMAGE"
      value = var.app_container_base_image
  }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - |
        docker build \
          -f Dockerfile.seeder \
          --build-arg APP_BASE_IMAGE=$APP_BASE_IMAGE \
          -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - echo Writing image definitions file...
      - printf '[{"name":"%s","imageUri":"%s"}]' $SERVICE_NAME $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
BUILDSPEC
  }

  tags = local.tags
}


resource "aws_codebuild_project" "agent_deploy_binary" {
  name         = "${local.name}-agent-deploy-binary"
  description  = "Codebuild"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.private_subnets
    security_group_ids = [module.codepipeline_security_group.this_security_group_id]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "S3_BUCKET"
      value = var.binaries_s3_bucket
    }

    environment_variable {
      name  = "S3_INTERFACE_ENDPOINT"
      value = var.s3_interface_endpoint
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  build:
    commands:
      - echo Uploading binary to S3...
      - aws --endpoint-url $S3_INTERFACE_ENDPOINT s3 cp ./agent-latest s3://$S3_BUCKET/test-controller-agent/

BUILDSPEC
  }

  tags = local.tags
}

resource "aws_codepipeline" "this" {
  name     = "${local.name}-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        OAuthToken = var.github_access_token
        Owner      = var.github_repo_owner
        Repo       = var.github_repo
        Branch     = var.github_repo_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Controller"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["controller_build"]
      run_order        = 1

      configuration = {
        ProjectName = aws_codebuild_project.controller_build.name
      }
    }

    action {
      name             = "Agent"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["agent_build"]
      run_order        = 1

      configuration = {
        ProjectName = aws_codebuild_project.agent_build.name
      }
    }

    action {
      name             = "UHS_Seed_Generator"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["uhs_seeder_generator"]
      run_order        = 1

      configuration = {
        ProjectName = aws_codebuild_project.uhs_seed_generator.name
      }
    }

  }

  stage {
    name = "Deploy"

    action {
      name            = "Controller"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["controller_build"]
      run_order       = 1

      configuration = {
        ClusterName = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
        ServiceName = var.test_controller_ecs_service_name
      }
    }

    action {
      name             = "Agent_Binary_to_S3"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["agent_build"]
      run_order        = 1

      configuration = {
        ProjectName = aws_codebuild_project.agent_deploy_binary.name
      }
    }
  }

  tags = local.tags
}
