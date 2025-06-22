output "allowed_instance_types" {
  description = "List of EC2 instance types allowed for Karpenter provisioning"
  value       = var.allowed_instance_types
}