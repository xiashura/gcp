include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-vm.git//modules/instance_template?ref=v8.0.0"
}

generate "version" {
  path = "versions.tf"
  if_exists = "overwrite"
  contents = <<EOF
  
  EOF
}

dependency "network" {
  config_path = "${find_in_parent_folders("network")}"
}

inputs = {

  project_id = local.account.project
  region = local.region.region

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

  // threads_per_core = "1"
}
