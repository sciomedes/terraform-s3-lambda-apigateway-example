#------------------------------------------------------------------------
# aws provider specifying region
#------------------------------------------------------------------------
provider "aws" {
  region = "${var.region}"
}

#------------------------------------------------------------------------
# local values:
#------------------------------------------------------------------------
locals {
  // template file for role policy
  role_policy_template = "${path.module}/policy-allow-logs-s3-bucket.template"
}

#------------------------------------------------------------------------
# aws_iam_role.lambda
# create a role to allow lambda access to resources
#------------------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name                     = "${var.role_name}"
  tags                     = "${var.tags}"
  assume_role_policy       = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

#------------------------------------------------------------------------
# aws_iam_policy.role_policy
# the rendered policy
#------------------------------------------------------------------------
resource "aws_iam_policy" "role_policy" {
  name        = "role-policy"
  description = "Policy for IAM role"
  policy = templatefile("${local.role_policy_template}", { bucket = "${var.bucket_name}" })
}

#------------------------------------------------------------------------
# aws_iam_role_policy_attachment.policy-attach
# attach policy to role
#------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.role_policy.arn}"
}
