output "mysql" {
  description = "Everything the mysql module returns"
  sensitive   = true
  value       = module.mysql
}
