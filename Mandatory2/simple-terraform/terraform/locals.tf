locals {
  resource_prefix = "demo"
  rg_name       = "rg-${var.project_name}-${var.environment}-jakob"
  sa_name       = "st${var.project_name}${var.environment}${random_string.suffix.result}"
  sc_name       = "container-${var.environment}"

  tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    app         = "storageaccount"
  }
}
