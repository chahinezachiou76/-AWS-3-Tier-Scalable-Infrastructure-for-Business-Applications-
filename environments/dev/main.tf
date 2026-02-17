
# Network

module "network" {
  source = "../../modules/network"

  vpc_cidr                 = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}


# Security

module "security" {
  source = "../../modules/security"

  vpc_id             = module.network.vpc_id
  admin_cidr_blocks  = var.admin_cidr_blocks
}


# LoadBalancer

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  vpc_id                  = module.network.vpc_id
  public_subnet_ids       = module.network.public_subnet_ids
  private_app_subnet_ids  = module.network.private_app_subnet_ids

  external_alb_sg_id      = module.security.external_alb_sg_id
  internal_alb_sg_id      = module.security.internal_alb_sg_id
}


# Identity

module "identity" {
  source = "../../modules/identity"
}


# Compute

module "compute" {
  source = "../../modules/compute"

  private_app_subnet_ids = module.network.private_app_subnet_ids
  public_subnet_ids      = module.network.public_subnet_ids

  frontend_target_group_arn = module.loadbalancer.frontend_target_group_arn
  backend_target_group_arn  = module.loadbalancer.backend_target_group_arn

  frontend_sg_id = module.security.frontend_sg_id
  backend_sg_id  = module.security.backend_sg_id
  bastion_sg_id  = module.security.bastion_sg_id

  frontend_ami_id = var.frontend_ami_id
  backend_ami_id  = var.backend_ami_id
  bastion_ami_id  = var.bastion_ami_id

  frontend_instance_type = "t3.micro"
  backend_instance_type  = "t3.micro"
  bastion_instance_type  = "t3.micro"

  frontend_desired_capacity = 2
  frontend_min_size         = 1
  frontend_max_size         = 3

  backend_desired_capacity = 2
  backend_min_size         = 1
  backend_max_size         = 3
}


# Database

module "database" {
  source = "../../modules/database"

  private_db_subnet_ids = module.network.private_db_subnet_ids
  database_sg_id        = module.security.database_sg_id

  instance_class = "db.t3.medium"

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password
}


# DNS

module "dns" {
  source = "../../modules/dns"

  domain_name           = var.domain_name
  create_hosted_zone    = false
  external_alb_dns_name = module.loadbalancer.external_alb_dns_name
  external_alb_zone_id  = module.loadbalancer.external_alb_arn
}

############################
# Observability
############################
module "observability" {
  source = "../../modules/observability"

  frontend_asg_name = module.compute.frontend_asg_name
  backend_asg_name  = module.compute.backend_asg_name
  account_id        = var.account_id
}
