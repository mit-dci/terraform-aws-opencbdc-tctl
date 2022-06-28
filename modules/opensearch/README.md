<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_cloudwatch_log_stream.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_policy.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_service_linked_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_kinesis_firehose_delivery_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_opensearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_opensearch_domain_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_policy) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_endpoint_certificate_arn"></a> [custom\_endpoint\_certificate\_arn](#input\_custom\_endpoint\_certificate\_arn) | The ACM cert arn to use with the custom endpoint. | `string` | n/a | yes |
| <a name="input_dns_base_domain"></a> [dns\_base\_domain](#input\_dns\_base\_domain) | DNS Zone name to be used in opensearch custom endpoint options. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | AWS tag to indicate environment name of each infrastructure object. | `string` | n/a | yes |
| <a name="input_fire_hose_buffering_interval"></a> [fire\_hose\_buffering\_interval](#input\_fire\_hose\_buffering\_interval) | Interval time between sending Fire Hose buffer data to OpenSearch | `number` | n/a | yes |
| <a name="input_fire_hose_index_rotation_period"></a> [fire\_hose\_index\_rotation\_period](#input\_fire\_hose\_index\_rotation\_period) | The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data. | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Route53 hosted zone id of the base domain. | `string` | n/a | yes |
| <a name="input_master_user_name"></a> [master\_user\_name](#input\_master\_user\_name) | Master username of opensearch user | `string` | n/a | yes |
| <a name="input_master_user_password"></a> [master\_user\_password](#input\_master\_user\_password) | Master password of opensearch user | `string` | n/a | yes |
| <a name="input_opensearch_ebs_volume_size"></a> [opensearch\_ebs\_volume\_size](#input\_opensearch\_ebs\_volume\_size) | Size of EBS volume to back OpenSearch domain | `string` | n/a | yes |
| <a name="input_opensearch_ebs_volume_type"></a> [opensearch\_ebs\_volume\_type](#input\_opensearch\_ebs\_volume\_type) | Type of EBS volume to back OpenSearch domain | `string` | n/a | yes |
| <a name="input_opensearch_engine_version"></a> [opensearch\_engine\_version](#input\_opensearch\_engine\_version) | The engine version to use for the OpenSearch domain | `string` | n/a | yes |
| <a name="input_opensearch_instance_count"></a> [opensearch\_instance\_count](#input\_opensearch\_instance\_count) | Number of instances to include in OpenSearch domain | `string` | n/a | yes |
| <a name="input_opensearch_instance_type"></a> [opensearch\_instance\_type](#input\_opensearch\_instance\_type) | Instance type used for OpenSearch cluster | `string` | n/a | yes |
| <a name="input_route53_record_ttl"></a> [route53\_record\_ttl](#input\_route53\_record\_ttl) | TTL for CNAME record of opensearch domain | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | The opensearch endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
