locals {
  # normalize suffix
  suffix  = length(var.unique_suffix) > 0 ? lower(var.unique_suffix) : ""
  rg_name = "rg-${var.name_prefix}-${local.suffix}"

  # SA must be 3–24, lowercase alphanum. Keep it short.
  sa_name      = "st${var.name_prefix}${local.suffix}"
  kv_name      = "kv-${var.name_prefix}-${local.suffix}"
  final_suffix = var.unique_suffix != "" ? var.unique_suffix : (length(random_string.auto_suffix) == 1 ? random_string.auto_suffix[0].result : "")

  # Recompute names when auto suffix exists
  rg_final = "rg-${var.name_prefix}-${local.final_suffix}"
  sa_final = "st${var.name_prefix}${local.final_suffix}"
  kv_final = "kv-${var.name_prefix}-${local.final_suffix}"

  # Principals to grant roles to
  principals = toset(
    concat(
      var.extra_principal_ids,
      var.assign_current_user ? [data.azurerm_client_config.current.object_id] : []
    )
  )
}