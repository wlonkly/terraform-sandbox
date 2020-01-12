resource "random_pet" "pet" { count = 20 }

output "pet_name" { value = "${random_pet.pet.*.id}" }

variable "honk" { default = "foo" }
resource "null_resource" "error_test" {
  "ERROR: ${var.honk} honk" = true
}
