output subnet_id {
  description = "Generated Subnet ID"
  value       = azurerm_subnet.subnet.id
}

output subnet_name {
  description = "Generated Subnet Name"
  value       = azurerm_subnet.subnet.name
}
