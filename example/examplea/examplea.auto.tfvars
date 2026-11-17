name            = "pikemysqlflex"
location        = "uksouth"
geo_location    = "ukwest"
expiration_date = "2027-12-31T00:00:00Z"

active_directory_administrator = {
  login     = "mysql-admins"
  object_id = "00000000-0000-0000-0000-000000000000"
}

databases = {
  app = {}
}

tags = {
  createdby = "terraform"
  module    = "terraform-azurerm-mysql-flexible"
}
