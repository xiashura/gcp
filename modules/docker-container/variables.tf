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
  type = list(string)
}
variable "ssh-key-private" {

}
variable "mounts" {
  type = list(object({
    type   = string
    target = string
    source = string
  }))
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
}

variable "privileged" {
  type    = bool
  default = false
}
