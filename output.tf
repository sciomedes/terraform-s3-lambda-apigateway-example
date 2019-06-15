output "logging_bucket_arn" {
  description = "The ARN of the S3 logging bucket"
  value = "${module.s3-logging-bucket.logging_bucket_arn}"
}
