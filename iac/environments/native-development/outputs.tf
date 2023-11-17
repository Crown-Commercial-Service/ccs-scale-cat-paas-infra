output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster which contains all the services"
  value       = module.cat_full.ecs_cluster_arn
}
