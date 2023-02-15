
include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "git::git@github.com:xiashura/terraform-google-vm.git//modules/compute_instance?ref=v8.0.1"
}

generate "outputs" {
  path = "outputs.tf"

  if_exists = "overwrite"

  contents = <<EOF
output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = google_compute_instance_from_template.compute_instance.*.self_link
}

output "instances_details" {
  description = "List of all details for compute instances"
  value       = google_compute_instance_from_template.compute_instance.*
  sensitive   = true
}

output "available_zones" {
  description = "List of available zones in region"
  value       = data.google_compute_zones.available.names
}
EOF
}

generate "version" {
  path = "versions.tf"
  if_exists = "overwrite"
  // set version
  contents = <<EOF
  
  EOF
}




dependency "network" {
  config_path = "${find_in_parent_folders("network")}"
}

dependency "firewall-web" {
  config_path = "../../firewall/web-public" 
}


dependency "boundary-public" {
  config_path = "../../firewall/boundary-public" 
}

dependency "template" {
  config_path = "../../template/vm-ubuntu-e2-small-30gb"
}

dependency "address" {
  config_path = "../../address/credentials-manager"
}

inputs = {

  region = local.region.region
  zone = local.region.zone
  num_instances = 1


  
  service_account = {
    email = "terraform@steady-burner-372518.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  subnetwork = dependency.network.outputs.subnets["europe-west2/infrastructure-gke-k8s-subnet"].name

  hostname = "credentials-manager" 

  tags = [
    "develop",

    local.env.firewall-ssh-public-tag,
    dependency.firewall-web.outputs.firewall_rules.allow-web-ingress.name,

    dependency.boundary-public.outputs.firewall_rules.allow-boundary-ingress.name,
  ]

  // threads_per_core = "1"

  instance_template = dependency.template.outputs.self_link

  access_config = [
    {
      nat_ip = dependency.address.outputs.address
      network_tier = dependency.address.outputs.tier
    },
  ]
}
