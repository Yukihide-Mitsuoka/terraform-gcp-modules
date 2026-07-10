output "taxonomy_id" {
  description = "Full taxonomy resource name (projects/.../locations/.../taxonomies/...)."
  value       = google_data_catalog_taxonomy.this.id
}

output "policy_tag_ids" {
  description = "Map: level name -> full policy-tag resource name. Reference these from dbt (policy_tags) / Dataform (bigqueryPolicyTags) column configs."
  value       = { for k, t in google_data_catalog_policy_tag.level : k => t.name }
}
