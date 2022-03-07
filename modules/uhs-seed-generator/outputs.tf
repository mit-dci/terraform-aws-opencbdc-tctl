output "job_name" {
    value = local.name
    description = "Name of uhs seed generator job"
}

output "job_definiton_arn" {
    value = "arn:aws:batch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job-definition/${local.name}"
    description = "Arn of the uhs_seed_generator job definition"
}

output "job_queue_arn" {
    value = aws_batch_job_queue.this.arn
    description = "Arn of the uhs_seed_generator job queue"
}

output "ecr_repo" {
  value       = aws_ecr_repository.this.repository_url
  description = "The ECR repo for the uhs seed generator"
}
