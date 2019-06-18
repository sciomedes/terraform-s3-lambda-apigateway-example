variable "region" {
  description = "AWS region to contain resources"
  type        = "string"
}

variable "logging_bucket_name" {
  description = "Name of S3 bucket to store logs"
  type        = "string"
}

variable "storage_bucket_arn" {
  description = "ARN of S3 bucket for which access is logged"
  type        = "string"
}

variable "trail_name" {
  description = "Name of AWS CloudTrail trail"
  type        = "string"
}

variable "tags" {
  description = "A mapping of tags to assign to the trail."
  default     = {}
  type        = "map"
}

