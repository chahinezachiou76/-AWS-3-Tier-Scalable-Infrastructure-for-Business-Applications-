aws_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

azs = ["us-east-1a", "us-east-1b"]

public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

admin_cidr_blocks = ["YOUR_IP/32"]

domain_name = "example.com"

database_name   = "appdb"
master_username = "admin"
master_password = "StrongPassword123!"

account_id = "123456789012"
