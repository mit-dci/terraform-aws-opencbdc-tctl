output "cert_arn" {
  value       = aws_acm_certificate.domain_cert.id
  description = "The ACM cert ARN"
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.base_domain.id
  description = "Route53 hosted zone id of the base domain"
}

output "name_servers" {
  value = data.aws_route53_zone.base_domain.name_servers
  description = "Name servers associated with Route53 base domain"
}
