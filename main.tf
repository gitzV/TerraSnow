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

# Install dependencies and run Python script
resource "null_resource" "run_python" {
  provisioner "local-exec" {
    command = <<-EOT
      pip install snowflake-connector-python
      python ${path.module}/snowflake_executor.py ${path.module}/setup.sql
    EOT
  }
}

# create DB
resource "snowflake_database" "db" {
  name                        = var.database_name
  comment                     = "Database created through Terraform"
  depends_on = [null_resource.run_python]
  
}

# create role
resource "snowflake_role" "dev_role" {
  name    = var.snowflake_role
  comment = "Developer role for database access"
  depends_on = [snowflake_database.db]
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

# Grant stage read access
resource "snowflake_stage_grant" "stage_grant_read" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  stage_name    = snowflake_stage.internal_stage.name
  privilege     = "READ"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_stage.internal_stage, snowflake_role.dev_role]
}

# Grant stage write access
resource "snowflake_stage_grant" "stage_grant_write" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  stage_name    = snowflake_stage.internal_stage.name
  privilege     = "WRITE"
  roles         = [snowflake_role.dev_role.name]
  depends_on    = [snowflake_stage_grant.stage_grant_read]
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

# Define a File Format (CSV Format Example)
resource "snowflake_file_format" "csv_format" {
  name     = "CSV_FORMAT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.schema.name
  format_type = "CSV"
  skip_header = 1
  field_delimiter = ","
}

##
/*
# Install SnowSQL
resource "null_resource" "install_snowsql" {
  provisioner "local-exec" {
    command = <<-EOF
      # Create installation directory
      mkdir -p ~/snowflake
      
      # Download SnowSQL
      curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowsql-1.2.9-linux_x86_64.bash
      
      # Install SnowSQL
      bash snowsql-1.2.9-linux_x86_64.bash
      
      # Create config directory
      mkdir -p ~/.snowsql

      # Create config file
      cat > ~/.snowsql/config <<CONFIG
      [connections.default]
      accountname = var.snowflake_account
      username = var.snowflake_username
      password = var.snowflake_password
      CONFIG
      
      # Make executable
      chmod +x ~/snowflake/snowsql

      # Add SnowSQL directory to PATH
      export PATH=$PATH:~/snowflake


    EOF
  }
}
*/

# Check SnowSQL version with the corrected path
resource "null_resource" "check_snowsql_version" {
  provisioner "local-exec" {
    command = "~/snowflake/snowsql --version  > snowsql_version.txt"
  }

  depends_on = [
   # null_resource.install_snowsql,
    snowflake_stage.internal_stage
  ]
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
  value = null_resource.check_snowsql_version.name
}

# Output the SnowSQL version
output "snowsql_version" {
  value = file("snowsql_version.txt")
  description = "The version of SnowSQL installed."
}
