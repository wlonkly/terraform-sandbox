
resource "dyn_record" "testing" {
   name = "sales-sandbox"
   type = "A"
   value = "52.9.221.51"
   zone = "pd-sandbox.com"
}
