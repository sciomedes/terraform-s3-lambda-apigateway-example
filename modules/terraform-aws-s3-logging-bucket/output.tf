output "logging_bucket_arn" {
  description = "ARN for logging bucket"
  value = "${aws_s3_bucket.logging_bucket.arn}"
}
