
# DB Subnet Group

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "multi-az-aurora-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.tags, {
    Name = "multi-az-aurora-subnet-group"
  })
}


# Aurora Cluster

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "multi-az-aurora-cluster"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [var.database_sg_id]
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"

  storage_encrypted = true
  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "multi-az-aurora-cluster"
  })
}


# Writer Instance (Primary)

resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier         = "multi-az-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine             = var.engine
  engine_version     = var.engine_version
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "multi-az-aurora-writer"
    Role = "writer"
  })
}


# Reader Instance (Secondary)

resource "aws_rds_cluster_instance" "aurora_reader" {
  identifier         = "multi-az-aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine             = var.engine
  engine_version     = var.engine_version
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "multi-az-aurora-reader"
    Role = "reader"
  })
}
