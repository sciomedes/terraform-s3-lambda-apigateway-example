output "storage_bucket_arn" {
  description = "ARN for storage bucket"
  value = "${aws_s3_bucket.bucket.arn}"
}

