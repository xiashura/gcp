include {
  path = find_in_parent_folders()
}

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  region    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  account    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals

  boundary-postgresql-password = get_env("POSTGRES_BOUNDARY_PASSWORD","veri_strong_p@ssw0rd")
}


terraform {
  source = "${get_repo_root()}/modules/docker-container"
}

dependency "address" {
  config_path = "../../address/credentials-manager"
}

dependency "network" {
  config_path = "../docker-network-credentoals"
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

  name = "boundary"
  image = "hashicorp/boundary"


  ssh-key-private = local.env.path-ssh-private-key
  host = dependency.address.outputs.address
  user = "root"
  privileged = true
  env = [
    "BOUNDARY_POSTGRES_URL=postgresql://${local.env.postgres-boundary.user}:${local.boundary-postgresql-password}@postgres:${local.env.postgres-boundary.port}/${local.env.postgres-boundary.db}?sslmode=disable"
  ]

  networks = [
    {
      name = dependency.network.outputs.name
    }
  ]

  mounts = [
    {
      type = "bind"
      source = "/var/data_boundary"
      target = "/boundary"
    }
  ]

  ports = [ 
    {
      external = "9200"
      internal = "9200"
      ip = "127.0.0.1"
      protocol = "tcp"
    },
    {
      external = "9201"
      internal = "9201"
      ip = "0.0.0.0"
      protocol = "tcp"
    },
    {
      external = "9202"
      internal = "9202"
      ip = "0.0.0.0"
      protocol = "tcp"
    },
  ]
}