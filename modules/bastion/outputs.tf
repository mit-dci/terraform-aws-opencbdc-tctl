output "bastion_enpoint" {
    description = "The bastion endpoint where users can access via an ssh connection"
    value = aws_route53_record.bastion.fqdn
}
