include {
  path = find_in_parent_folders()
}

locals {

  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-network.git//modules/firewall-rules?ref=v6.0.0"
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
  project_id   = local.account.project
  region = local.region.region
  network_name = dependency.network.outputs.network_name

  rules = [{
    name                    = "allow-ssh-ingress"
    description = ""
    direction               = "INGRESS"
    ranges                  = ["0.0.0.0/0"]
    target_tags             = [
      local.env.firewall-ssh-public-tag,
      "allow-ssh-ingress",
    ]

    priority = 65534
    source_service_accounts = null
    source_tags = null
    target_service_accounts = null
    deny = []
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]

}
