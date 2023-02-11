include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}


terraform {
  source = "${get_repo_root()}/modules/gittee-docker-service"
}


dependency "git-server-develop" {
  config_path = "../../vms/gitea"
}

dependency "firewall-git-public" {
  config_path = "../../firewall/git-public"
}

dependency "address" {
  config_path = "../../address/git-server"
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
  path-data = "/home/xiashura/gitea"
  docker-version = "latest"
  port-ssh = local.env.firewall-git-public.port-ssh
  port-git = local.env.firewall-git-public.port-web
}