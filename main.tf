variable "project" {
  description = "The project ID"
}
variable "region" {
  description = "The region"
}
variable "ip_addresses" {
  description = "Whitelist IP addresses"
}

provider "google" {
  project = var.project
  region  = var.region
}

output "load_balancer_ip" {
  value = module.load_balancer.ip_address
}


module "cloud_run" {
  source = "./modules/cloud_run"

  project = var.project
  region  = var.region
}

module "load_balancer" {
  source = "./modules/load_balancer"

  project                = var.project
  cloud_run_service_name = module.cloud_run.service_name
  security_policy        = module.cloud_armor.security_policy
}

module "cloud_armor" {
  source = "./modules/cloud_armor"

  ip_addresses = var.ip_addresses
}
