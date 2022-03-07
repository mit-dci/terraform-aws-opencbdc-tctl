# VPC
# us-east-1
output "vpc_id_use1" {
    description = "Id of VPC in us-east-1 region"
    value = module.opencbdc_tctl.vpc_id_use1
}
output "public_subnets_use1" {
    description = "Public subnet Ids associated with VPC in us-east-1 region"
    value = module.opencbdc_tctl.public_subnets_use1
}
output "private_subnets_use1" {
    description = "Private subnet Ids associated with VPC in us-east-1 region"
    value = module.opencbdc_tctl.private_subnets_use1
}
output "azs_use1" {
    description = "Availability zones used by VPC located in us-east-1 region"
    value = module.opencbdc_tctl.azs_use1
}
output "s3_vpc_interface_endpoint_use1" {
    description = "S3 service interface endpoint asscoiated with VPC in us-east-1 region"
    value = module.opencbdc_tctl.s3_vpc_interface_endpoint_use1
}
# us-east-2
output "vpc_id_use2" {
    description = "Id of VPC in us-east-2 region"
    value = module.opencbdc_tctl.vpc_id_use2
}
output "public_subnets_use2" {
    description = "Public subnet Ids associated with VPC in us-east-2 region"
    value = module.opencbdc_tctl.public_subnets_use2
}
output "private_subnets_use2" {
    description = "Private subnet Ids associated with VPC in us-east-2 region"
    value = module.opencbdc_tctl.private_subnets_use2
}
output "azs_use2" {
    description = "Availability zones used by VPC located in us-east-2 region"
    value = module.opencbdc_tctl.azs_use2
}
output "s3_vpc_interface_endpoint_use2" {
    description = "S3 service interface endpoint asscoiated with VPC in us-east-2 region"
    value = module.opencbdc_tctl.s3_vpc_interface_endpoint_use2
}
# us-west-2
output "vpc_id_usw2" {
    description = "Id of VPC in us-west-2 region"
    value = module.opencbdc_tctl.vpc_id_usw2
}
output "public_subnets_usw2" {
    description = "Public subnet Ids associated with VPC in us-west-2 region"
    value = module.opencbdc_tctl.public_subnets_usw2
}
output "private_subnets_usw2" {
    description = "Private subnet Ids associated with VPC in us-west-2 region"
    value = module.opencbdc_tctl.private_subnets_usw2
}
output "azs_usw2" {
    description = "Availability zones used by VPC located in us-west-2 region"
    value = module.opencbdc_tctl.azs_usw2
}
output "s3_vpc_interface_endpoint_usw2" {
    description = "S3 service interface endpoint asscoiated with VPC in us-west-2 region"
    value = module.opencbdc_tctl.s3_vpc_interface_endpoint_usw2
}

# ECS
# us-east-1
output "ecs_cluster_id" {
    description = "ECS cluster id"
    value = module.opencbdc_tctl.ecs_cluster_id
}
output "ecs_cluster_name" {
    description = "ECS cluster name"
    value = module.opencbdc_tctl.ecs_cluster_name
}

# Route53
output "route53_name_servers" {
    description = "Name servers asscoiated with Route53 hosted zone"
    value = module.opencbdc_tctl.route53_name_servers
}
