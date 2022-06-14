<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codepipeline_security_group"></a> [codepipeline\_security\_group](#module\_codepipeline\_security\_group) | terraform-aws-modules/security-group/aws | 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.agent_build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.agent_deploy_binary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.controller_build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.uhs_seed_generator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codebuild_attach_eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_by_codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_by_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codebuild_attach_eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_container_base_image"></a> [app\_container\_base\_image](#input\_app\_container\_base\_image) | An optional custom container base image for the test controller and releated services | `string` | n/a | yes |
| <a name="input_binaries_s3_bucket"></a> [binaries\_s3\_bucket](#input\_binaries\_s3\_bucket) | The S3 bucket where agent binaries should be published by the pipeline | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The ECS cluster name | `string` | n/a | yes |
| <a name="input_github_access_token"></a> [github\_access\_token](#input\_github\_access\_token) | Name of oauth token for github private repo | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | The Github repo base name | `string` | n/a | yes |
| <a name="input_github_repo_branch"></a> [github\_repo\_branch](#input\_github\_repo\_branch) | The Github repo owner | `string` | n/a | yes |
| <a name="input_github_repo_owner"></a> [github\_repo\_owner](#input\_github\_repo\_owner) | The Github repo owner | `string` | n/a | yes |
| <a name="input_golang_container_build_image"></a> [golang\_container\_build\_image](#input\_golang\_container\_build\_image) | An optional custom container build image for Golang depencies | `string` | n/a | yes |
| <a name="input_node_container_build_image"></a> [node\_container\_build\_image](#input\_node\_container\_build\_image) | An optional custom container build image for Nodejs depencies | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_s3_interface_endpoint"></a> [s3\_interface\_endpoint](#input\_s3\_interface\_endpoint) | DNS record used to route s3 traffic through s3 vpc interface endpoint | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set for all resources | `map(string)` | `{}` | no |
| <a name="input_test_controller_ecr_repo"></a> [test\_controller\_ecr\_repo](#input\_test\_controller\_ecr\_repo) | The ECR repo for the test controller | `string` | n/a | yes |
| <a name="input_test_controller_ecs_service_name"></a> [test\_controller\_ecs\_service\_name](#input\_test\_controller\_ecs\_service\_name) | The ECS Service name for the test controller | `string` | n/a | yes |
| <a name="input_uhs_seed_generator_ecr_repo"></a> [uhs\_seed\_generator\_ecr\_repo](#input\_uhs\_seed\_generator\_ecr\_repo) | The ECR repo for the uhs seed generator | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `string` | `""` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
