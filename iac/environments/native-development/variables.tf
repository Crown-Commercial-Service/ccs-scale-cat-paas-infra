variable "environment_is_ephemeral" {
  type        = bool
  description = "If true, indicates that the environment is expected to be destroyed from time to time - Allows for (e.g.) `force_destroy` on S3 buckets"
}
