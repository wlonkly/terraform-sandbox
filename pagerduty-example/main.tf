provider "pagerduty" {
  token = "${var.pagerduty_token}"
}

resource "pagerduty_team" "example_team" {
  name        = "Terraform Test"
  description = "Testing PagerDuty Terraform provider"
}

resource "pagerduty_user" "example_user" {
  name  = "Rich (Terraform)"
  email = "rlafferty+pdtf@pagerduty.com"
  teams = ["${pagerduty_team.example_team.id}"]
}

resource "pagerduty_user_contact_method" "example_contact_method" {
  user_id      = "${pagerduty_user.example_user.id}"
  type         = "phone_contact_method"
  country_code = "+1"
  address      = "6473771165"
  label        = "Mobile"
}

resource "pagerduty_schedule" "example_schedule" {
  name      = "Terraform Test Schedule"
  time_zone = "America/New_York"

  layer {
    name                         = "Always On-Call"
    start                        = "2018-09-11T00:00:00-05:00"
    rotation_virtual_start       = "2018-09-11T00:00:00-05:00"
    rotation_turn_length_seconds = 86400
    users                        = ["${pagerduty_user.example_user.id}"]
  }
}

resource "pagerduty_escalation_policy" "example_policy" {
  name = "Terraform Escalation Policy"

  rule {
    escalation_delay_in_minutes = 10

    target {
      type = "schedule"
      id   = "${pagerduty_schedule.example_schedule.id}"
    }
  }
}

resource "pagerduty_service" "example_service" {
  name              = "Terraform Test Service"
  escalation_policy = "${pagerduty_escalation_policy.example_policy.id}"
}
