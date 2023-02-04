locals {
  credentials_path = "${get_repo_root()}/credentials/infrastructure/credentials.json"
  credentials      = jsondecode(file(local.credentials_path))

  service_account = local.credentials.client_email
  project         = local.credentials.project_id 
}