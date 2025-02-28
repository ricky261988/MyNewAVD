data "azurerm_image" "search" {
  name                = var.image_name
  resource_group_name = var.avd_vnet_resource_group
}

resource "azurerm_shared_image_gallery" "sig" {
  name                = var.shared_image_gallery
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_shared_image" "si" {
  name                = var.shared_image
  gallery_name        = azurerm_shared_image_gallery.sig.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = var.os_type

  identifier {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
  }

  hyper_v_generation           = var.hyper_v_generation

  depends_on = [
    azurerm_shared_image_gallery.sig,
  ]
}

resource "azurerm_shared_image_version" "siv" {

  name                = var.shared_image_versions
  gallery_name        = azurerm_shared_image_gallery.sig.name
  image_name          = azurerm_shared_image.si.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  managed_image_id    = data.azurerm_image.search.id

  target_region {
    name                   = var.resource_group_location
    regional_replica_count = var.regional_replica_count
    storage_account_type   = var.storage_account_type
  }

  depends_on = [
    azurerm_shared_image.si
  ]
}

data "azurerm_virtual_network" "AVD-vNet" {
  name                = var.avd_vnet
  resource_group_name = var.avd_vnet_resource_group
}

data "azurerm_subnet" "subnets" {
  name                  = var.avd_hostpool_subnet
  virtual_network_name  = data.azurerm_virtual_network.AVD-vNet.name
  resource_group_name   = data.azurerm_virtual_network.AVD-vNet.resource_group_name
}

resource "azuread_group" "aad_group" {
  display_name = var.group
  security_enabled = true
}

data "azurerm_role_definition" "vm_user_login" {
  name = "Virtual Machine User Login"
}

data "azurerm_role_definition" "desktop_user" { 
  name = "Desktop Virtualization User"
}

resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.resource_group_location
}

resource "azurerm_virtual_desktop_workspace" "ws" {
    name = var.workspace_name
    resource_group_name = var.resource_group_name
    location = var.resource_group_location
    friendly_name = "${var.prefix}-Workspace"
    description = "${var.prefix}-Workspace"
    depends_on  = [azurerm_resource_group.rg]
}

resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  name                     = var.hostpool
  friendly_name            = var.hostpool
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;"
  description              = "${var.prefix}-HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 2
  load_balancer_type       = "DepthFirst"
  depends_on               = [azurerm_resource_group.rg]
scheduled_agent_updates {
  enabled = true
  timezone = "India Standard Time"
  schedule {
    day_of_week = "Sunday"
    hour_of_day = 1
  }
}
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.expiration
}

resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name = var.resource_group_name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  location            = var.resource_group_location
  type                = "Desktop"
  name                = var.app_group_name
  friendly_name       = var.app_group_name
  description         = "${var.prefix}-AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.ws, azurerm_resource_group.rg]
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.ws.id
}

resource "azurerm_network_interface" "wvd_vm1_nic" {
  count               = var.avd_host_pool_size
  name                = "avd-nic-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  depends_on          = [azurerm_resource_group.rg]

  ip_configuration {
    name                          = "TFip"
    subnet_id                     = data.azurerm_subnet.subnets.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "wvd_vm1" {
  count                 = var.avd_host_pool_size
  name                  = "avd-vm-${count.index}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  size                  = var.size
  network_interface_ids = [azurerm_network_interface.wvd_vm1_nic[count.index].id]
  provision_vm_agent    = true
  timezone              = "India Standard Time"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  depends_on            = [azurerm_resource_group.rg, azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace_application_group_association.ws-dag]

  source_image_id       = azurerm_shared_image_version.siv.id

  additional_capabilities {
  }
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "TFStorage"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = ""
  }
}

resource "azurerm_virtual_machine_extension" "avd_register_session_host" {
  count                = var.avd_host_pool_size
  name                 = var.avd_register
  virtual_machine_id   = azurerm_windows_virtual_machine.wvd_vm1[count.index].id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"

  settings = <<SETTINGS
    {
      "modulesUrl": "${var.avd_register_session_host_modules_url}",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "hostPoolName": "${azurerm_virtual_desktop_host_pool.hostpool.name}",
        "aadJoin": true,
        "UseAgentDownloadEndpoint": true,
        "aadJoinPreview": false,
        "mdmId": "",
        "sessionHostConfigurationLastUpdateTime": "",
        "registrationInfoToken" : "${azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token}"
      }
    }
    SETTINGS

  depends_on = [azurerm_windows_virtual_machine.wvd_vm1, azurerm_virtual_desktop_host_pool.hostpool]
}

resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
    count                             = var.avd_host_pool_size
    name                              = "AADLoginForWindows"
    virtual_machine_id                = azurerm_windows_virtual_machine.wvd_vm1[count.index].id
    publisher                         = "Microsoft.Azure.ActiveDirectory"
    type                              = "AADLoginForWindows"
    type_handler_version              = "1.0"
    auto_upgrade_minor_version        = true
    depends_on = [azurerm_virtual_machine_extension.avd_register_session_host]
}

resource "azurerm_role_assignment" "vm_user_role" {
  scope              = azurerm_resource_group.rg.id
  role_definition_id = data.azurerm_role_definition.vm_user_login.id
  principal_id       = azuread_group.aad_group.object_id
}

resource "azurerm_role_assignment" "desktop_role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = data.azurerm_role_definition.desktop_user.id
  principal_id       = azuread_group.aad_group.object_id
}

data "azuread_user" "avd_users" {
  for_each            = toset(var.avd_user_upns)
  user_principal_name = each.key
}

resource "azuread_group_member" "avd_users" {
  for_each         = data.azuread_user.avd_users
  group_object_id  = azuread_group.aad_group.object_id
  member_object_id = each.value.object_id
}