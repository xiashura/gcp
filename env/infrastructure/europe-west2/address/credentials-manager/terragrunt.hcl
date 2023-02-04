
include {
  path = find_in_parent_folders()
}

locals {

  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/modules/google-compute-address"
}


inputs = {
  project_id = local.account.project 
  name =  "credentials-manager-address"
  region = local.region.region
  network_tier = "PREMIUM"
}
