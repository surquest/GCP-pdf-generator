# Create Service Accounts
resource "google_service_account" "accounts" {

  for_each      = var.services.IAM.serviceAccounts

  account_id = jsondecode(templatefile(
    "../../config/naming.patterns.json",
    {
      solution = var.solution,
      services = var.services,
      GCP  = var.GCP
    }
  ))["IAM"]["serviceAccounts"][each.key]

  display_name  = "${each.value.name} (${upper(var.GCP.env)})"
  description   = "${each.value.desc} for ${upper(var.GCP.env)}"

}

# Summarize map of service accounts and roles
locals {
  service_account_roles = {
    for iamKey, iamVal in flatten([
      for key, value in var.services.IAM.serviceAccounts: [
        for item in value.roles: {
          idx             = "${key}.${item}"
          accountKey      = key
          role            = item

        }
      ]
    ]): iamVal.idx => {
      accountKey = iamVal.accountKey
      role = iamVal.role
    }
  }
}

resource "google_project_iam_member" "sa_iam_binding" {

  for_each = local.service_account_roles

  project = var.GCP.id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.accounts[each.value.accountKey].email}"
}