output "azure_terraform_resource_group" {
    description = "Name of Resource Group"
    value = azurerm_resource_group.rg.name
}

output "azure_terraform_resource_group_location" {
    description = "Location of Resource Group"
    value = azurerm_resource_group.rg.location
}

output "Workspace_Name" {
    description = "Name of AVD Workspace"
    value = azurerm_virtual_desktop_workspace.ws.name
}

output "Hostpool_Name" {
    description = "Name of HostPool"
    value = azurerm_virtual_desktop_host_pool.hostpool.name
}

output "Application_Group_Name" {
    description = "Name of ApplicationGroup"
    value = azurerm_virtual_desktop_application_group.dag.name
}