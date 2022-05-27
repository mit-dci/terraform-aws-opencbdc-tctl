<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 3.9.0 |
| <a name="module_instance_profile_role"></a> [instance\_profile\_role](#module\_instance\_profile\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | ~> 5 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ami.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.script](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_binaries_efs_id"></a> [binaries\_efs\_id](#input\_binaries\_efs\_id) | The EFS ID for the binaries volume. | `string` | n/a | yes |
| <a name="input_certs_efs_id"></a> [certs\_efs\_id](#input\_certs\_efs\_id) | The EFS ID for the certs volume. | `string` | n/a | yes |
| <a name="input_dns_base_domain"></a> [dns\_base\_domain](#input\_dns\_base\_domain) | DNS Zone name to be used in bastion EIP A record creation. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | AWS tag to indicate environment name of each infrastructure object. | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Route53 hosted zone id of the base domain | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name suffix associated with resources | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key from the shared SSH key pair used in launch templates. | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_testruns_efs_id"></a> [testruns\_efs\_id](#input\_testruns\_efs\_id) | The EFS ID for the testruns volume. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_enpoint"></a> [bastion\_enpoint](#output\_bastion\_enpoint) | The bastion endpoint where users can access via an ssh connection |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
