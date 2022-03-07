output "agent_endpoint" {
  value       = aws_route53_record.nlb.fqdn
  description = "The test controller endpoint where agents create TCP connections"
}

output "agent_port" {
  value       = local.agent_port
  description = "The test controller port where agents create TCP connections"
}

output "certs_efs_id" {
  value       = aws_efs_file_system.certs.id
  description = "The EFS ID for the certs volume."
}

output "testruns_efs_id" {
  value       = aws_efs_file_system.testruns.id
  description = "The EFS ID for the testruns volume."
}

output "binaries_efs_id" {
  value       = aws_efs_file_system.binaries.id
  description = "The EFS ID for the binaries volume."
}

output "certs_efs_ap_arn" {
  value       = aws_efs_access_point.certs.arn
  description = "The EFS ARN for the certs access point."
}

output "testruns_efs_ap_arn" {
  value       = aws_efs_access_point.testruns.arn
  description = "The EFS ARN for the testruns access point."
}

output "binaries_efs_ap_arn" {
  value       = aws_efs_access_point.binaries.arn
  description = "The EFS ARN for the binaries access point."
}

output "ecr_repo" {
  value       = aws_ecr_repository.app.repository_url
  description = "The ECR repo for the test controller"
}

output "ecs_service_name" {
  value       = aws_ecs_service.service.name
  description = "The ECS service name for the test controller"
}
