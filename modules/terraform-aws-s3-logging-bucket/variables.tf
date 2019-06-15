variable "region" {
  description = "Name of region containing bucket"
  type        = "string"
}

variable "logging_bucket_name" {
  description = "The S3 bucket to send S3 access logs."
  type        = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = "map"
}

variable "logging_lifecycle_tags" {
  description = "A mapping of tags to assign to the set of lifecycle rules."
  default     = {}
  type        = "map"
}

variable "lifecycle_12" {
  description = "Age of object in days at which transition from S3 Standard to S3 Standard-IA should occur"
}

variable "lifecycle_23" {
  description = "Age of object in days at which transition from S3 Standard-IA to S3 Glacier should occur"
}

variable "lifecycle_3X" {
  description = "Age of object in days at which it should expire"
}
