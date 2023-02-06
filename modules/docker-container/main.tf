
resource "null_resource" "pre-docker" {

  count = length(var.mounts)

  connection {
    type        = "ssh"
    user        = var.user
    host        = var.host
    private_key = file(var.ssh-key-private)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.mounts[count.index].source}",
    ]
  }

}


resource "docker_container" "boundary" {

  depends_on = [
    null_resource.pre-docker,
  ]

  image = var.image
  name  = var.name

  hostname = var.name

  env = var.env

  dynamic "mounts" {
    for_each = var.mounts
    content {
      type   = mounts.value.type
      target = mounts.value.target
      source = mounts.value.source
    }
  }

  dynamic "ports" {
    for_each = var.ports
    content {
      external = ports.value.external
      ip       = ports.value.ip
      protocol = ports.value.protocol
      internal = ports.value.internal
    }
  }

}
