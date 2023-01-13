locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  accont = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals

  base_source_url = "git::git@github.com:xiashura/gke-k8s//modules/container-registry-gke"
}

inputs = {
  suffix-name-account-admin = local.env.name
  project = local.accont.project
}

