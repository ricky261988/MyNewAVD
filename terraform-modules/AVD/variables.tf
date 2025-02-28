variable "resource_group_name" {
    type = string
}

variable "resource_group_location" {
    type = string
}

variable "workspace_name" {
    type = string
}

variable "prefix" {
    type = string
}

variable "hostpool" {
    type = string
}

variable "expiration" {
    type = string
}

variable "app_group_name" {
    type = string
}

variable "avd_host_pool_size" {
    type = number
}

variable "size" {
    type = string
}

variable "admin_username" {
    type = string
}

variable "admin_password" {
    type = string
}

variable "avd_register" {
    type = string
}

variable "avd_register_session_host_modules_url" {
    type = string
}

variable "avd_vnet" {
    type = string
}

variable "avd_hostpool_subnet" {
    type = string
}

variable "avd_vnet_resource_group" {
    type = string
}

variable "image_name" {
    type = string
}

variable "group" {
    type = string
}

variable "avd_user_upns" {
    type = list(string)
    default = []
}

variable "shared_image_gallery" {
    type = string
}

variable "shared_image" {
    type = string
}

variable "os_type" {
    type = string
}

variable "publisher" {
    type = string
}

variable "offer" {
    type = string
}

variable "sku" {
    type = string
}

variable "shared_image_versions" {
  type = string
}

variable "regional_replica_count" {
    type = number
}

variable "storage_account_type" {
    type = string
}

variable "hyper_v_generation" {
    type = string
}