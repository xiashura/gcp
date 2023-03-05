variable "host" {
  type = string
}
variable "user" {
  type = string
}
variable "image" {
  type = string
}
variable "name" {
  type = string
}
variable "env" {
  type      = list(string)
  sensitive = true
}

variable "command" {
  type = list(string)
}

variable "ssh-key-private" {

}

variable "capabilities" {
  type = list(object({
    add  = optional(list(string), [])
    drop = optional(list(string), [])
  }))
  default = []
}

variable "mounts" {
  type = list(object({
    type   = string
    target = string
    source = string
  }))
  default = []
}

variable "ports" {
  type = list(object({
    ip       = string
    external = number
    internal = number
    protocol = string
  }))
}

variable "networks" {
  type = list(object({
    name = string
  }))
  default = []
}

variable "privileged" {
  type    = bool
  default = false
}
