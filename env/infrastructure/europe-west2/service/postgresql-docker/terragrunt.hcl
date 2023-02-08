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

dependency "network" {
  config_path = "../docker-network-credentoals"
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

inputs = {

  name = "postgres"
  image = "postgres"

  ssh-key-private = local.env.path-ssh-private-key

  host = dependency.address.outputs.address
  user = "root"
  env = [
    "POSTGRES_PASSWORD=${local.env.postgres-boundary.password}",
    "POSTGRES_USER=${local.env.postgres-boundary.user}",
    "POSTGRES_DB=${local.env.postgres-boundary.db}",
    "PGDATA=/var/lib/postgresql/data/pgdata",
  ]
  mounts = [
    {
      type = "bind"
      target = "/var/lib/postgresql/data/pgdata"
      source = "/var/pg_data"
    }
  ]

  networks = [
    {
      name = dependency.network.outputs.name
    }
  ]

  ports = [ 
    {
      external = local.env.postgres-boundary.port
      internal = 5432
      ip = "0.0.0.0"
      protocol = "tcp"
    },
  ]
}