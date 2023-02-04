locals {
  env = "infrastructure-gke-k8s"


  firewall-web-public = {
    name = "allow-web-ingress"
    tag = "web-public"
    ports-tcp = [
      80,
      443
    ]
  }

  firewall-ssh-public-tag = "ssh-public"

  firewall-git-public = {
    name = "allow-git-ingress"
    tag = "git-public"
    port-web = 3000
    port-ssh = 2224
    ports-tcp = [
      "2224",
      "3000",
    ]
  }
}