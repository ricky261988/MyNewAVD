variable "subscription_id" {
    type = string
    default = "890c8b4a-e9fc-448c-a68e-7a0d35f11f22"
}

variable "tenant_id" {
    type = string
    default = "5466e6a0-7dd5-4e4c-bc92-e5351ab5a526"
}

variable "client_id" {
    type = string
    default = "a0084691-eeb7-42b1-840c-5e6387b79cbd"
}

variable "client_secret" {
    type = string
    default = "Cer8Q~v2SxFBlzjzXT44vOG5C1y5BR~RYqOtAcn."
}

variable "image_name" {
    type = string
    default = "packer-windows-image"
}

variable image_version {
    type = string
    default = "1.0.0"
}