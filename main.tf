# main.tf -

terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.43.0" # adjust this to the latest version as needed
    }
  }
}

provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = "SYSADMIN"
  region   = var.snowflake_region
}

resource "snowflake_database" "example_db" {
  name = var.database_name
}

