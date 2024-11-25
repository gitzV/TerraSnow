terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.1"
    }
  }
}

# Provider block with credentials
provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}



# create role
resource "snowflake_role" "dev_role" {
  name    = var.snowflake_role
  comment = "Developer role for database access"
  #depends_on = [snowflake_database.db]
}


# Create a warehouse
resource "snowflake_warehouse" "warehouse" {
  name           = var.snowflake_WH
  warehouse_size = var.snowflake_WH_SIZE
  auto_suspend   = 60
  depends_on = [snowflake_role.dev_role]
}

# Grant warehouse usage to role
resource "snowflake_warehouse_grant" "warehouse_grant" {
  warehouse_name = snowflake_warehouse.warehouse.name
  privilege      = "USAGE"
  roles         = [snowflake_role.dev_role.name,"ACCOUNTADMIN"]
  depends_on     = [snowflake_warehouse.warehouse, snowflake_role.dev_role]
}


# Outputs

