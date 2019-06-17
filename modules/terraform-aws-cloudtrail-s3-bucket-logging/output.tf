output "cloudtrail_trail_arn" {
  description = "ARN for CloudTrail trail"
  value = "${aws_cloudtrail.cloudtrail.arn}"
}
