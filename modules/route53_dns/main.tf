
data "aws_route53_zone" "base_domain" {
  name = var.dns_base_domain
}

# ACM
resource "aws_acm_certificate" "domain_cert" {
  domain_name               = var.dns_base_domain
  subject_alternative_names = ["*.${var.dns_base_domain}"]
  validation_method         = "DNS"

  tags = merge(
    {
      Name = var.dns_base_domain
    },
    var.tags
  )
}

resource "aws_route53_record" "domain_cert_validation_dns" {
  name    = tolist(aws_acm_certificate.domain_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.domain_cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.base_domain.id
  records = [tolist(aws_acm_certificate.domain_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [aws_route53_record.domain_cert_validation_dns.fqdn]
}
