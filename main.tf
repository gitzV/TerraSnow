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

# Database resource with drop cascade option
resource "snowflake_database" "db" {
  name                        = var.database_name
  comment                     = "Database created through Terraform"
  data_retention_time_in_days = 1
  lifecycle {
    create_before_destroy = false
  }
}

# Create DEV role
resource "snowflake_role" "dev_role" {
  name    = var.snowflake_role
  comment = "Developer role for database access"
  lifecycle {
    create_before_destroy = false
  }
}

# Create a warehouse
resource "snowflake_warehouse" "warehouse" {
  name           = var.snowflake_WH
  warehouse_size = var.snowflake_WH_SIZE
  auto_suspend   = 60
  auto_resume    = true
  lifecycle {
    create_before_destroy = false
  }
}

# Grant warehouse usage to role
resource "snowflake_warehouse_grant" "warehouse_grant" {
  warehouse_name = snowflake_warehouse.warehouse.name
  privilege      = "USAGE"
  roles         = [snowflake_role.dev_role.name]
  depends_on     = [snowflake_warehouse.warehouse, snowflake_role.dev_role]
}

# Create schema
resource "snowflake_schema" "schema" {
  database = snowflake_database.db.name
  name     = var.snowflake_schema
  comment  = "Schema for development work"
  depends_on = [snowflake_database.db]
}

# Grant schema usage
resource "snowflake_schema_grant" "schema_grant" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  privilege     = "USAGE"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_schema.schema, snowflake_role.dev_role]
}

# Create internal stage
resource "snowflake_stage" "internal_stage" {
  name        = var.snowflake_stage
  database    = snowflake_database.db.name
  schema      = snowflake_schema.schema.name
  comment     = "Internal stage for file loading"
  depends_on  = [snowflake_schema.schema]
}

# Grant stage read/write access
# Grant stage read/write access
resource "snowflake_stage_grant" "stage_grant" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  stage_name    = snowflake_stage.internal_stage.name
  privilege    =  "READ"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_stage.internal_stage, snowflake_role.dev_role]
}


resource "snowflake_stage_grant" "stage_grant" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  stage_name    = snowflake_stage.internal_stage.name
  privilege    =  "WRITE"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_stage.internal_stage, snowflake_role.dev_role]
}

# Additional necessary grants
resource "snowflake_database_grant" "database_grant" {
  database_name = snowflake_database.db.name
  privilege     = "USAGE"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_database.db, snowflake_role.dev_role]
}

resource "snowflake_schema_grant" "schema_create_table" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  privilege     = "CREATE TABLE"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_schema.schema, snowflake_role.dev_role]
}

resource "snowflake_schema_grant" "schema_create_view" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  privilege     = "CREATE VIEW"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_schema.schema, snowflake_role.dev_role]
}

# Outputs
output "database_name" {
  value = snowflake_database.db.name
}

output "warehouse_name" {
  value = snowflake_warehouse.warehouse.name
}

output "schema_name" {
  value = snowflake_schema.schema.name
}

output "stage_name" {
  value = snowflake_stage.internal_stage.name
}

output "role_name" {
  value = snowflake_role.dev_role.name
}
