resource "random_id" "id" { 
  count = 5 
  byte_length = 2
  prefix = "prod-web-"
}

output "id" { value = "${random_id.id.*.id}" }
