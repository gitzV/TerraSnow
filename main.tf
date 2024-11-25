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



# Outputs

