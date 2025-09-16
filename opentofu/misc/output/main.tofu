variable "input" {
  type = map(string)
}

output "output" {
  value = { for key, value in var.input : key => value }
}
