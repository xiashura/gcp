locals {
  env = "infrastructure-gke-k8s"
  path-ssh-private-key = "/Users/xiashura/.ssh/id_rsa"
  postgres-boundary = {
    user = "postgres"
    port = 5432
    db = "boundary"
  }

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