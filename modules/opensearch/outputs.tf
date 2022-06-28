output "opensearch_endpoint" {
  value       = aws_route53_record.this.fqdn
  description = "The opensearch endpoint"
}