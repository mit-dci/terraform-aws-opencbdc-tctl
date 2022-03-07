output "s3_interface_endpoint" {
  value = "https://bucket${trimprefix(module.vpc_endpoints.endpoints["s3"]["dns_entry"][0]["dns_name"], "*")}"
  description = "DNS must be specified in order to route traffic through to the s3 interface endpoint"
}
