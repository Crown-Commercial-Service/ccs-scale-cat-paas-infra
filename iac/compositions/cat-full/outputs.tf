output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster which contains all the services"
  value       = module.ecs_cluster.cluster_arn
}
