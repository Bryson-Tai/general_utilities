variable "messages" {
  type    = string
  default = ""
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo ${var.messages}"
  }
}

output "output" {
  value = var.messages
}
