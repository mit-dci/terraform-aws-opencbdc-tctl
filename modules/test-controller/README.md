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
| <a name="module_certbot_lambda"></a> [certbot\_lambda](#module\_certbot\_lambda) | terraform-aws-modules/lambda/aws | 1.48.0 |
| <a name="module_certbot_security_group"></a> [certbot\_security\_group](#module\_certbot\_security\_group) | terraform-aws-modules/security-group/aws | 3.1.0 |
| <a name="module_efs_security_group"></a> [efs\_security\_group](#module\_efs\_security\_group) | terraform-aws-modules/security-group/aws | 3.1.0 |
| <a name="module_nlb"></a> [nlb](#module\_nlb) | terraform-aws-modules/alb/aws | 5.13.0 |
| <a name="module_task_security_group"></a> [task\_security\_group](#module\_task\_security\_group) | terraform-aws-modules/security-group/aws | 3.1.0 |
| <a name="module_ui_nlb"></a> [ui\_nlb](#module\_ui\_nlb) | terraform-aws-modules/alb/aws | 5.13.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.certbot_timer_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.certbot_timer_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_repository.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.binaries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_access_point.certs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_access_point.testruns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.binaries_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_backup_policy.certs_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_backup_policy.testruns_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.binaries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system.certs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system.testruns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.binaries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_mount_target.certs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_mount_target.testruns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_role_batch_submit_jobs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_role_s3_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_s3_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ui_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.transaction_processor_github_access_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_execution_role_policy_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_role_policy_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_role_policy_batch_submit_jobs_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_role_policy_s3_write_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones inside the VPC | `list(string)` | `[]` | no |
| <a name="input_binaries_s3_bucket"></a> [binaries\_s3\_bucket](#input\_binaries\_s3\_bucket) | The S3 bukcet where binaries is stored. | `string` | n/a | yes |
| <a name="input_binaries_s3_bucket_arn"></a> [binaries\_s3\_bucket\_arn](#input\_binaries\_s3\_bucket\_arn) | The S3 bucket arn where binaries are stored. | `string` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ECS cluster ID | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The ECS task CPU | `string` | n/a | yes |
| <a name="input_create_certbot_lambda"></a> [create\_certbot\_lambda](#input\_create\_certbot\_lambda) | Boolean to create the certbot lambda to update the letsencrypt cert for the test controller. | `bool` | n/a | yes |
| <a name="input_dns_base_domain"></a> [dns\_base\_domain](#input\_dns\_base\_domain) | DNS Zone name to be used in load balancer CNAME creation. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | AWS tag to indicate environment name of each infrastructure object. | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | The Github repo base name | `string` | `"cbdc-test-controller"` | no |
| <a name="input_github_repo_branch"></a> [github\_repo\_branch](#input\_github\_repo\_branch) | The Github repo owner | `string` | `"master"` | no |
| <a name="input_github_repo_owner"></a> [github\_repo\_owner](#input\_github\_repo\_owner) | The Github repo owner | `string` | `"mit-dci"` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | The ECS service health check grace period in seconds | `number` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Route53 hosted zone id of the base domain | `string` | n/a | yes |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | The ECS task launch type | `string` | n/a | yes |
| <a name="input_lets_encrypt_email"></a> [lets\_encrypt\_email](#input\_lets\_encrypt\_email) | Email to associate with let's encrypt certificate | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The ECS task memory | `string` | n/a | yes |
| <a name="input_outputs_s3_bucket"></a> [outputs\_s3\_bucket](#input\_outputs\_s3\_bucket) | The S3 bucket where test result outputs are stored. | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_s3_interface_endpoint"></a> [s3\_interface\_endpoint](#input\_s3\_interface\_endpoint) | DNS record used to route s3 traffic through s3 vpc interface endpoint | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set for all resources | `map(string)` | `{}` | no |
| <a name="input_transaction_processor_github_access_token"></a> [transaction\_processor\_github\_access\_token](#input\_transaction\_processor\_github\_access\_token) | Access token for the transaction repo if permissions are required | `string` | `""` | no |
| <a name="input_transaction_processor_main_branch"></a> [transaction\_processor\_main\_branch](#input\_transaction\_processor\_main\_branch) | Main branch of transaction repo | `string` | n/a | yes |
| <a name="input_transaction_processor_repo_url"></a> [transaction\_processor\_repo\_url](#input\_transaction\_processor\_repo\_url) | Transaction repo cloned by the test controller for load generation logic | `string` | n/a | yes |
| <a name="input_uhs_seed_generator_job_definiton_arn"></a> [uhs\_seed\_generator\_job\_definiton\_arn](#input\_uhs\_seed\_generator\_job\_definiton\_arn) | Arn of uhs seed generator job definition | `string` | n/a | yes |
| <a name="input_uhs_seed_generator_job_name"></a> [uhs\_seed\_generator\_job\_name](#input\_uhs\_seed\_generator\_job\_name) | Name of batch job used for uhs seed generation | `string` | n/a | yes |
| <a name="input_uhs_seed_generator_job_queue_arn"></a> [uhs\_seed\_generator\_job\_queue\_arn](#input\_uhs\_seed\_generator\_job\_queue\_arn) | Arn of uhs seed generator job queue | `string` | n/a | yes |
| <a name="input_vpc_cidr_blocks"></a> [vpc\_cidr\_blocks](#input\_vpc\_cidr\_blocks) | A list of VPC cidr blocks to add to the interface enpoint security group | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_endpoint"></a> [agent\_endpoint](#output\_agent\_endpoint) | The test controller endpoint where agents create TCP connections |
| <a name="output_agent_port"></a> [agent\_port](#output\_agent\_port) | The test controller port where agents create TCP connections |
| <a name="output_binaries_efs_ap_arn"></a> [binaries\_efs\_ap\_arn](#output\_binaries\_efs\_ap\_arn) | The EFS ARN for the binaries access point. |
| <a name="output_binaries_efs_id"></a> [binaries\_efs\_id](#output\_binaries\_efs\_id) | The EFS ID for the binaries volume. |
| <a name="output_certs_efs_ap_arn"></a> [certs\_efs\_ap\_arn](#output\_certs\_efs\_ap\_arn) | The EFS ARN for the certs access point. |
| <a name="output_certs_efs_id"></a> [certs\_efs\_id](#output\_certs\_efs\_id) | The EFS ID for the certs volume. |
| <a name="output_ecr_repo"></a> [ecr\_repo](#output\_ecr\_repo) | The ECR repo for the test controller |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | The ECS service name for the test controller |
| <a name="output_testruns_efs_ap_arn"></a> [testruns\_efs\_ap\_arn](#output\_testruns\_efs\_ap\_arn) | The EFS ARN for the testruns access point. |
| <a name="output_testruns_efs_id"></a> [testruns\_efs\_id](#output\_testruns\_efs\_id) | The EFS ID for the testruns volume. |
| <a name="output_ui_endpoint"></a> [ui\_endpoint](#output\_ui\_endpoint) | The test controller endpoint where users can connect to the UI |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
