include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals

 vault_root_token = get_env("VAULT_ROOT_TOKEN","veri_strong_p@ssw0rd")
  
}


terraform {
  source = "${get_repo_root()}/modules/docker-container"
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

dependency "address" {
  config_path = "../../address/credentials-manager"
}

dependency "network" {
  config_path = "../docker-network-credentoals"
}

inputs = {

  name = "vault"
  image = "vault:latest"


  ssh-key-private = local.env.path-ssh-private-key
  host = dependency.address.outputs.address
  user = "root"

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=${local.vault_root_token}",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200",
  ]

  networks = [
    {
      name = dependency.network.outputs.name
    }
  ]

  ports = [ 
    {
      external = "8200"
      internal = "8200"
      ip = "127.0.0.1"
      protocol = "tcp"
    },
  ]
}