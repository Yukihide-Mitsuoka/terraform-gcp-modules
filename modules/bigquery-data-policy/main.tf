resource "google_bigquery_datapolicy_data_policy" "this" {
  project          = var.project_id
  location         = var.location
  data_policy_id   = var.data_policy_id
  policy_tag       = var.policy_tag
  data_policy_type = var.data_policy_type

  dynamic "data_masking_policy" {
    for_each = var.data_policy_type == "DATA_MASKING_POLICY" ? [1] : []
    content {
      predefined_expression = var.predefined_expression
    }
  }

  lifecycle {
    precondition {
      condition     = var.data_policy_type != "DATA_MASKING_POLICY" || var.predefined_expression != null
      error_message = "predefined_expression is required when data_policy_type is DATA_MASKING_POLICY."
    }

    precondition {
      condition     = can(regex("^projects/[^/]+/locations/${var.location}/", var.policy_tag))
      error_message = "location must equal the location segment of policy_tag, or the policy will not attach."
    }
  }
}

resource "google_bigquery_datapolicy_data_policy_iam_member" "masked_reader" {
  for_each = toset(var.masked_readers)

  project        = var.project_id
  location       = var.location
  data_policy_id = google_bigquery_datapolicy_data_policy.this.data_policy_id
  role           = "roles/bigquerydatapolicy.maskedReader"
  member         = each.value
}
