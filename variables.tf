variable "snowflake_account" {
  description = "Snowflake account identifier"
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

variable "snowflake_role" {
  description = "Name of the Snowflake role to create"
  type        = string
}

variable "snowflake_WH" {
  description = "Name of the Snowflake warehouse"
  type        = string
}

variable "snowflake_WH_SIZE" {
  description = "Size of the Snowflake warehouse"
  type        = string
  validation {
    condition     = contains(["x-small", "small", "medium", "large"], var.snowflake_WH_SIZE)
    error_message = "Valid warehouse sizes are: x-small, small, medium, large"
  }
}

variable "snowflake_schema" {
  description = "Name of the Snowflake schema"
  type        = string
}

variable "snowflake_stage" {
  description = "Name of the Snowflake internal stage"
  type        = string
}
