output "logging_bucket_arn" {
  description = "The ARN of the S3 logging bucket"
  value = "${module.s3-logging-bucket.logging_bucket_arn}"
}

output "iam_role_arn" {
  description = "ARN for IAM role assumed by lambda function"
  value = "${module.iam-role-lambda.iam_role_arn}"
}

output "storage_bucket_arn" {
  description = "The ARN of the S3 storage bucket"
  value = "${module.s3-storage-bucket.storage_bucket_arn}"
}
