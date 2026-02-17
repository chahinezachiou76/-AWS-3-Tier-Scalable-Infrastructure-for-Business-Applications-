output "alb_dns" {
  value = module.loadbalancer.external_alb_dns_name
}

output "db_endpoint" {
  value = module.database.cluster_endpoint
}
