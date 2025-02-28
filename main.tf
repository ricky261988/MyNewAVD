module "AVD" {
    source = "./terraform-modules/AVD"

    resource_group_name = "TerraformDemoRG"
    resource_group_location = "Central India"
    workspace_name = "MyDemoWS"
    prefix = "Demo"
    hostpool = "MyDemoHostpool"
    expiration = "2025-03-14T12:43:13Z"
    app_group_name = "MyDemoappgroup"
    avd_host_pool_size = 1
    size = "Standard_D2as_v5"
    avd_register = "sessionhost"
    avd_vnet = "vm1-vnet"
    avd_hostpool_subnet = "default"
    avd_vnet_resource_group = "PackerImage"
    image_name = "packer-windows-image"
    group = "avdusers"
    admin_password = var.admin_password
    admin_username = var.admin_username
    avd_user_upns = ["vinit@hclwpe.xyz"]
    shared_image_gallery = "MyImageGallery"
    shared_image = "MySharedImage"
    os_type = "Windows"
    publisher = "MicrosoftWindowsDesktop"
    offer = "windows-11"
    sku = "win11-23h2-avd"
    shared_image_versions = "1.0.0"
    regional_replica_count = 1
    storage_account_type = "Standard_LRS"
    hyper_v_generation = "V2"
    avd_register_session_host_modules_url = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02872.560.zip"
}