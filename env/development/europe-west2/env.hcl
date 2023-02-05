locals {
  env = "development"

  path-root = "${dirname(find_in_parent_folders())}/"
  path-infrastructure = "${dirname(find_in_parent_folders())}/env/infrastructure/"


}