variable "region" {
  description = "Name of region containing bucket"
  type        = "string"
}

variable "bucket_name" {
  description = "Name of bucket to manage"
  type        = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  default     = {}
  type        = "map"
}

variable "storage_lifecycle_tags" {
  description = "A mapping of tags to assign to the set of lifecycle rules."
  default     = {}
  type        = "map"
}

variable "lifecycle_12" {
  description = "Age of object in days at which transition from S3 Standard to S3 Standard-IA should occur"
  type        = number
}

variable "lifecycle_23" {
  description = "Age of object in days at which transition from S3 Standard-IA to S3 Glacier should occur"
  type        = number
}

variable "account_number" {
  description = "AWS account number used in ARNs"
  type        = "string"
}

variable "iam_user" {
  description = "AWS IAM user who owns bucket"
  type        = "string"
}

variable "role_name" {
  description = "Name of lambda role used to access bucket"
  type        = "string"
}

variable "force_destroy" {
  description = "Should non-empty bucket be removed upon performing 'terraform destroy'"
  default     = false
}
