variable "region" {
  description = "AWS region to contain resources"
  type        = "string"
}

variable "bucket_name" {
  description = "S3 storage bucket"
  type        = "string"
}

variable "role_name" {
  description = "Name of role that lambda functions will use"
  type        = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the role."
  default     = {}
  type        = "map"
}
