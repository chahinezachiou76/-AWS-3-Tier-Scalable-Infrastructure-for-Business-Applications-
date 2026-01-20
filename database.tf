# DB Subnet Group (Aurora)
resource "aws_rds_cluster_subnet_group" "aurora_subnets" {
  name       = "aurora-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id
  description = "Aurora subnet group for private DB subnets"

  tags = merge(local.common_tags, { Name = "aurora-subnet-group" })
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-cluster"
  engine                  = var.aurora_engine
  engine_version          = var.aurora_engine_version
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_rds_cluster_subnet_group.aurora_subnets.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  multi_az                = true

  tags = merge(local.common_tags, { Name = "aurora-cluster" })
}

# Aurora Cluster Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.aurora_cluster_size
  identifier         = "aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.aurora_instance_class
  engine             = var.aurora_engine
  engine_version     = var.aurora_engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_rds_cluster_subnet_group.aurora_subnets.name

  tags = merge(local.common_tags, { Name = "aurora-instance-${count.index + 1}" })
}