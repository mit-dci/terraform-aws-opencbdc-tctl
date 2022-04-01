# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "requester_vpc_id" {
  description = "Requester VPC Id"
  type        = string
  default     = ""
}

variable "accepter_vpc_id" {
  description = "Accepter VPC Id"
  type        = string
  default     = ""
}

variable "requester_route_tables" {
  description = "Route tables associated with requester VPC"
  type = list(string)
}

variable "accepter_route_tables" {
  description = "Route tables associated with accepter VPC"
  type = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
