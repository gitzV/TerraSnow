# main.tf
terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.1"  # Use the latest stable version
    }
  }
}

provider "snowflake" {
  account    = var.snowflake_account
  username   = var.snowflake_username
  password   = var.snowflake_password
  region     = var.snowflake_region
  role       = "ACCOUNTADMIN"  # Or another appropriate role
  
  # Specify authentication method
  authenticator = "snowflake"  # For username/password auth
}

# Define your variables
variable "snowflake_account" {
  type        = string
  description = "Snowflake account identifier"
}

variable "snowflake_username" {
  type        = string
  description = "Snowflake username"
}

variable "snowflake_password" {
  type        = string
  sensitive   = true
  description = "Snowflake password"
}

variable "snowflake_region" {
  type        = string
  description = "Snowflake region"
}

variable "database_name" {
  type        = string
  description = "Name of the database to create"
}
