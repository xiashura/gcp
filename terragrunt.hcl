locals { 
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  account = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
}

remote_state {
  backend = "gcs"

  config = {
    bucket      = join("-", [local.env.env, "terraform-state"])
    prefix      = "${path_relative_to_include()}"
    credentials = local.account.credentials_path
    project     = local.account.project
    location    = local.region.region
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

provider "google" {

  credentials = "${local.account.credentials_path}"
  project     = "${local.account.project}"
  region      = "${local.region.region}"
  zone        = "${local.region.zone}"
}
  EOF
}

inputs = merge(
  local.env,
  local.account,
  local.region,
)
