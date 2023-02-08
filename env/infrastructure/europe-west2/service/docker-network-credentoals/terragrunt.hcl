include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}



dependency "address" {
  config_path = "../../address/credentials-manager"
}

terraform {
  source = "${get_repo_root()}/modules/docker-network"
}

generate "provider" {
  path = "providers.tf"

  if_exists = "overwrite"

  contents = <<EOF
    provider "docker" {
      host     = "ssh://root@${dependency.address.outputs.address}:22"
      ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
    }
  EOF
}

inputs = {
  name = "credentoals"
}