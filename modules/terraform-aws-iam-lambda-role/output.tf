output "iam_role_arn" {
  description = "ARN for IAM role assumed by lambda function"
  value = "${aws_iam_role.lambda.arn}"
}
