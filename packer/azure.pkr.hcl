source "azure-arm" "windows" {
    client_id = var.client_id
    client_secret = var.client_secret
    subscription_id = var.subscription_id
    tenant_id = var.tenant_id
    managed_image_name = "${var.image_name}"
    managed_image_resource_group_name = "PackerImage"
    vm_size = "Standard_D4ds_v4"
    temp_resource_group_name = "PackerBuild"
    location = "Central India"
    
    os_type = "Windows"
    image_publisher = "MicrosoftWindowsDesktop"
    image_offer = "windows-11"
    image_sku = "win11-23h2-avd"

    communicator    = "winrm"
    winrm_use_ssl   = true
    winrm_insecure  = true
    winrm_timeout   = "5m"
    winrm_username  = "packer"
}