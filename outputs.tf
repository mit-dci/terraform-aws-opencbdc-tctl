# VPC
# us-east-1
output "vpc_id_use1" {
    description = "Id of VPC in us-east-1 region"
    value = module.vpc.vpc_id
}
output "public_subnets_use1" {
    description = "Public subnet Ids associated with VPC in us-east-1 region"
    value = module.vpc.public_subnets
}
output "private_subnets_use1" {
    description = "Private subnet Ids associated with VPC in us-east-1 region"
    value = module.vpc.private_subnets
}
output "azs_use1" {
    description = "Availability zones used by VPC located in us-east-1 region"
    value = module.vpc.azs
}
output "s3_vpc_interface_endpoint_use1" {
    description = "S3 service interface endpoint asscoiated with VPC in us-east-1 region"
    value = module.vpc_endpoints_use1.s3_interface_endpoint
}
# us-east-2
output "vpc_id_use2" {
    description = "Id of VPC in us-east-2 region"
    value = module.vpc_use2.vpc_id
}
output "public_subnets_use2" {
    description = "Public subnet Ids associated with VPC in us-east-2 region"
    value = module.vpc_use2.public_subnets
}
output "private_subnets_use2" {
    description = "Private subnet Ids associated with VPC in us-east-2 region"
    value = module.vpc_use2.private_subnets
}
output "azs_use2" {
    description = "Availability zones used by VPC located in us-east-2 region"
    value = module.vpc_use2.azs
}
output "s3_vpc_interface_endpoint_use2" {
    description = "S3 service interface endpoint asscoiated with VPC in us-east-2 region"
    value = module.vpc_endpoints_use2.s3_interface_endpoint
}
# us-west-2
output "vpc_id_usw2" {
    description = "Id of VPC in us-west-2 region"
    value = module.vpc_usw2.vpc_id
}
output "public_subnets_usw2" {
    description = "Public subnet Ids associated with VPC in us-west-2 region"
    value = module.vpc_usw2.public_subnets
}
output "private_subnets_usw2" {
    description = "Private subnet Ids associated with VPC in us-west-2 region"
    value = module.vpc_usw2.private_subnets
}
output "azs_usw2" {
    description = "Availability zones used by VPC located in us-west-2 region"
    value = module.vpc_usw2.azs
}
output "s3_vpc_interface_endpoint_usw2" {
    description = "S3 service interface endpoint asscoiated with VPC in us-west-2 region"
    value = module.vpc_endpoints_usw2.s3_interface_endpoint
}

# ECS
# us-east-1
output "ecs_cluster_id" {
    description = "ECS cluster id"
    value = module.ecs.ecs_cluster_id
}
output "ecs_cluster_name" {
    description = "ECS cluster name"
    value = module.ecs.ecs_cluster_name
}

# Route53
output "route53_name_servers" {
    description = "Name servers asscoiated with Route53 hosted zone"
    value = module.route53_dns.name_servers
}
