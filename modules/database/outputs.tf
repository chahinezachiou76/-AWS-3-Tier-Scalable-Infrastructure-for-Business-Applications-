output "cluster_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "cluster_id" {
  value = aws_rds_cluster.aurora_cluster.id
}
