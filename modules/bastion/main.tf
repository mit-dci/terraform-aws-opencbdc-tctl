locals {
  name                   = "bastion"
  certs_mount_path       = "/opt/efs-mounts/certs"
  testruns_mount_path    = "/opt/efs-mounts/testruns"
  binaries_mount_path    = "/opt/efs-mounts/binaries"
  tags = {
    Owner       = "terraform"
    Environment = var.environment
  }
}

# get the current aws region
data "aws_region" "current" {}

# Create the instance sec group
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name   = "${local.name}-sg"
  vpc_id = var.vpc_id

  # Allow all incoming traffic
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  # Allow all outgoing traffic
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

# EC2 Instance Profile
module "instance_profile_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5"

  role_name               = "${local.name}-role-${data.aws_region.current.name}"
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services = ["ec2.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

  ]

  tags = local.tags
}

# Use shared public/private keypair
resource "aws_key_pair" "bastion" {
  key_name   = local.name
  public_key = var.public_key

  tags = local.tags
}

# Lookup ubuntu AMI ID
data "aws_ami" "bastion" {
  owners = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210129"]
  }
}

# Elastic IP to assign to bastion host
resource "aws_eip" "bastion" {
  vpc = true

  tags = merge(
    {
      Name = local.name
    },
    local.tags
  )
}

# Cloud-init config template file
data "template_file" "script" {
  template = file("${path.module}/templates/init.tpl")

  vars = {
    CERTS_MOUNT_PATH       = local.certs_mount_path
    TESTRUNS_MOUNT_PATH    = local.testruns_mount_path
    BINARIES_MOUNT_PATH    = local.binaries_mount_path
    CERTS_EFS_ID           = var.certs_efs_id
    TESTRUNS_EFS_ID        = var.testruns_efs_id
    BINARIES_EFS_ID        = var.binaries_efs_id
    REGION                 = data.aws_region.current.name
    EIP_ASSOCIATION_ID     = aws_eip.bastion.id
  }
}

# Cloud-init config
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}

# Create the autoscale group
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.9.0"

  name = "${local.name}_asg"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "${local.name}_lc"

  image_id                     = data.aws_ami.bastion.id
  instance_type                = "t3.micro"
  security_groups              = [module.security_group.this_security_group_id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  iam_instance_profile         = module.instance_profile_role.iam_instance_profile_name
  key_name                     = aws_key_pair.bastion.id

  user_data = data.template_cloudinit_config.config.rendered

  # Auto scaling group
  vpc_zone_identifier       = var.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "terraform"
      propagate_at_launch = true
    }
  ]
}

# Create A record for the EIP
resource "aws_route53_record" "bastion" {
  zone_id = var.hosted_zone_id
  name    = "${local.name}.${var.dns_base_domain}"
  type    = "A"
  ttl     = "5"
  records = [ aws_eip.bastion.public_ip ]
}
