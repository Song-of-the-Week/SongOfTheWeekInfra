data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.5"
}

resource "azurerm_resource_group" "rg" {
  name     = "sotwGroup"
  location = "eastus1"
}

# we have manually created the logical server and azure database 
# because terraform does not allow users to create a
# free-tier database through terraform at this time