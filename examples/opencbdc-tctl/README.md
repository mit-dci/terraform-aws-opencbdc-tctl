# opencbdc-tctl Environment
Configuration in this directory can be used to provision an environment mirroring that used in the paper.

# Usage
1. Complete the [pre-provisioning steps](../../README.md#Pre-Provisioning).
Please be sure that you are authenticated with AWS.
2. Set appropriate values for [inputs](#Inputs).
These are mainly vars that will be specific to your environment.
Each is defaulted to an empty string. You can overwrite the values directly in `variables.tf` or in another way of your choosing.
3. Execute:
```console
$ terraform init
$ terraform plan
$ terraform apply
```
Note that this will create resources in your AWS account which will cost money.
Be sure to run terraform destroy when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_opencbdc_tctl"></a> [opencbdc\_tctl](#module\_opencbdc\_tctl) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | Base domain to use for ACM Cert and Route53 record management. | `string` | `""` | no |
| <a name="input_lets_encrypt_email"></a> [lets\_encrypt\_email](#input\_lets\_encrypt\_email) | Email to associate with let's encrypt certificate | `string` | `""` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | SSH public key to use in EC2 instances. | `string` | `""` | no |
| <a name="input_test_controller_github_access_token"></a> [test\_controller\_github\_access\_token](#input\_test\_controller\_github\_access\_token) | Access token for cloning test controller repo | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs_use1"></a> [azs\_use1](#output\_azs\_use1) | Availability zones used by VPC located in us-east-1 region |
| <a name="output_azs_use2"></a> [azs\_use2](#output\_azs\_use2) | Availability zones used by VPC located in us-east-2 region |
| <a name="output_azs_usw2"></a> [azs\_usw2](#output\_azs\_usw2) | Availability zones used by VPC located in us-west-2 region |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ECS cluster id |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name |
| <a name="output_private_subnets_use1"></a> [private\_subnets\_use1](#output\_private\_subnets\_use1) | Private subnet Ids associated with VPC in us-east-1 region |
| <a name="output_private_subnets_use2"></a> [private\_subnets\_use2](#output\_private\_subnets\_use2) | Private subnet Ids associated with VPC in us-east-2 region |
| <a name="output_private_subnets_usw2"></a> [private\_subnets\_usw2](#output\_private\_subnets\_usw2) | Private subnet Ids associated with VPC in us-west-2 region |
| <a name="output_public_subnets_use1"></a> [public\_subnets\_use1](#output\_public\_subnets\_use1) | Public subnet Ids associated with VPC in us-east-1 region |
| <a name="output_public_subnets_use2"></a> [public\_subnets\_use2](#output\_public\_subnets\_use2) | Public subnet Ids associated with VPC in us-east-2 region |
| <a name="output_public_subnets_usw2"></a> [public\_subnets\_usw2](#output\_public\_subnets\_usw2) | Public subnet Ids associated with VPC in us-west-2 region |
| <a name="output_route53_name_servers"></a> [route53\_name\_servers](#output\_route53\_name\_servers) | Name servers asscoiated with Route53 hosted zone |
| <a name="output_s3_vpc_interface_endpoint_use1"></a> [s3\_vpc\_interface\_endpoint\_use1](#output\_s3\_vpc\_interface\_endpoint\_use1) | S3 service interface endpoint asscoiated with VPC in us-east-1 region |
| <a name="output_s3_vpc_interface_endpoint_use2"></a> [s3\_vpc\_interface\_endpoint\_use2](#output\_s3\_vpc\_interface\_endpoint\_use2) | S3 service interface endpoint asscoiated with VPC in us-east-2 region |
| <a name="output_s3_vpc_interface_endpoint_usw2"></a> [s3\_vpc\_interface\_endpoint\_usw2](#output\_s3\_vpc\_interface\_endpoint\_usw2) | S3 service interface endpoint asscoiated with VPC in us-west-2 region |
| <a name="output_vpc_id_use1"></a> [vpc\_id\_use1](#output\_vpc\_id\_use1) | Id of VPC in us-east-1 region |
| <a name="output_vpc_id_use2"></a> [vpc\_id\_use2](#output\_vpc\_id\_use2) | Id of VPC in us-east-2 region |
| <a name="output_vpc_id_usw2"></a> [vpc\_id\_usw2](#output\_vpc\_id\_usw2) | Id of VPC in us-west-2 region |
<!-- END_TF_DOCS -->
