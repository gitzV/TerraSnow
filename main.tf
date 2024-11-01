# main.tf
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.1"  # Use the latest stable version
    }
  }
}


# Provider block with credentials
provider "snowflake" {
  account    = var.snowflake_account
  user   = var.snowflake_username
  password   = var.snowflake_password
  role       = "ACCOUNTADMIN"
}

# Variables
variable "snowflake_account" {
  description = "The Snowflake account identifier"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

# Database resource
resource "snowflake_database" "db" {
  name                        = var.database_name
  comment                     = "Database created through Terraform"
  data_retention_time_in_days = 1
}
