terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/services/container-registry-gke.hcl"
  expose = true
}


inputs = {
  location = "EU"
}