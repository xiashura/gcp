
include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-vm.git//modules/compute_instance?ref=v8.0.0"
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

dependency "template" {
  config_path = "../../template/vm-ubuntu-e2-micro-10gb"
}

dependency "address" {
  config_path = "../../address/git-server"
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
  // source_image = "ubuntu-os-cloud"
  source_image_family = "ubuntu-2004-lts"
  source_image_project = "ubuntu-os-cloud"
  //ubuntu-2004-focal-v20230125
  auto_delete  = true
  boot = false
  disk_size_gb = 10
  disk_type    = "pd-ssd"

  machine_type = "e2-micro"

  tags = [
    "git",
    "develop",
    local.env.firewall-ssh-public-tag,
    local.env.firewall-git-public.tag,
  ]

  threads_per_core = "1"

  instance_template = dependency.template.outputs.self_link


  access_config = [
    {
      nat_ip = dependency.address.outputs.address
      network_tier = dependency.address.outputs.tier
    },
  ]
}
