variable "messages" {
  type    = string
  default = ""
}

resource "terraform_data" "hello" {
  provisioner "local-exec" {
    command = "echo ${var.messages}"
  }
}

output "output" {
  value = var.messages
}
