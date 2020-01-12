resource "random_integer" "int" { 
  count = 5
  min = 1
  max = 1000
}

output "int" { value = "${random_integer.int.*.result}" }
