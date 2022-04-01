
module "opencbdc_tctl" {
  source = "../../"
  
  base_domain                                       = var.base_domain
  environment                                       = var.environment
  public_key                                        = var.public_key
  test_controller_launch_type                       = "EC2"
  test_controller_cpu                               = "10240"
  test_controller_memory                            = "65536"
  test_controller_health_check_grace_period_seconds = 600
  test_controller_github_access_token               = var.test_controller_github_access_token
  lets_encrypt_email                                = var.lets_encrypt_email
}
