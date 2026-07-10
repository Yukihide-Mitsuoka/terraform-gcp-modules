locals {
  level_names = [for l in var.levels : l.name]

  # Flatten {level => [members]} into individually addressable bindings.
  reader_bindings = {
    for pair in flatten([
      for level, members in var.fine_grained_readers : [
        for member in members : { level = level, member = member }
      ]
    ]) : "${pair.level}/${pair.member}" => pair
  }
}

resource "google_data_catalog_taxonomy" "this" {
  project                = var.project_id
  region                 = var.location
  display_name           = var.taxonomy_display_name
  activated_policy_types = var.activated_policy_types

  lifecycle {
    precondition {
      condition     = alltrue([for k in keys(var.fine_grained_readers) : contains(local.level_names, k)])
      error_message = "Every fine_grained_readers key must be one of the level names."
    }
  }
}

resource "google_data_catalog_policy_tag" "level" {
  for_each = { for l in var.levels : l.name => l }

  taxonomy     = google_data_catalog_taxonomy.this.id
  display_name = each.value.name
  description  = each.value.description
}

resource "google_data_catalog_policy_tag_iam_member" "fine_grained_reader" {
  for_each = local.reader_bindings

  policy_tag = google_data_catalog_policy_tag.level[each.value.level].name
  role       = "roles/datacatalog.categoryFineGrainedReader"
  member     = each.value.member
}
