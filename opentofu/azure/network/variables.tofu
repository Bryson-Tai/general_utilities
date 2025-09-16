variable "env" {
  type = string
}

variable "tags" {
  description = "The tags for assign to each of the available resources"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "The location (region) of deployment"
  type        = string
}

variable "network" {
  type = object({
    address_space = list(string)
    subnet = object({
      address_prefixes = list(string)
    })
  })

  default = {
    address_space = ["10.0.0.0/8"]
    subnet = {
      address_prefixes = ["10.1.0.0/16"]
    }
  }
}
