include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-network"
}


generate "version" {
  path = "versions.tf"
  if_exists = "overwrite"
  contents = <<EOF
  
  EOF
}




inputs = {
  region = local.region.region 
  project = local.account.project

  project_id   = local.account.project
  network_name = "${local.env.env}-network"


  subnets = [
    {
      subnet_name   = "${local.env.env}-subnet"
      subnet_ip     = "10.0.0.0/17"
      subnet_region = local.region.region
    },
    {
      subnet_name   = "${local.env.env}-master-auth-subnetwork"
      subnet_ip     = "10.60.0.0/17"
      subnet_region = local.region.region
    },
  ]

  secondary_ranges = {
    ("${local.env.env}-subnet") = [
      {
        range_name    = "${local.env.env}-local-pods-range"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "${local.env.env}-local-svc-range"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }


}
