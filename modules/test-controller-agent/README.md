<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agent_outputs_iam_policy"></a> [agent\_outputs\_iam\_policy](#module\_agent\_outputs\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | ~> 3.0 |
| <a name="module_agent_security_group"></a> [agent\_security\_group](#module\_agent\_security\_group) | terraform-aws-modules/security-group/aws | 3.1.0 |
| <a name="module_instance_profile_role"></a> [instance\_profile\_role](#module\_instance\_profile\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | ~> 5 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.cw_agent_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_instance_type.agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_binaries_s3_bucket"></a> [binaries\_s3\_bucket](#input\_binaries\_s3\_bucket) | The S3 bukcet where binaries is stored. | `string` | n/a | yes |
| <a name="input_controller_endpoint"></a> [controller\_endpoint](#input\_controller\_endpoint) | The test controller endpoint where agents phone home. | `string` | n/a | yes |
| <a name="input_controller_port"></a> [controller\_port](#input\_controller\_port) | The test controller endpoint port where agents phone home. | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | The instance types used in agent launch templates. | `list(string)` | n/a | yes |
| <a name="input_log_group"></a> [log\_group](#input\_log\_group) | The Cloudwatch log group to use in the cloudwatch agent config. | `string` | n/a | yes |
| <a name="input_outputs_s3_bucket"></a> [outputs\_s3\_bucket](#input\_outputs\_s3\_bucket) | The S3 bucket where outputs are saved. | `string` | n/a | yes |
| <a name="input_outputs_s3_bucket_arn"></a> [outputs\_s3\_bucket\_arn](#input\_outputs\_s3\_bucket\_arn) | The S3 bucket arn where outputs are saved. | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key from the shared SSH key pair used in launch templates. | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_s3_interface_endpoint"></a> [s3\_interface\_endpoint](#input\_s3\_interface\_endpoint) | DNS record used to route s3 traffic through s3 vpc interface endpoint | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set for all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `string` | `""` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
