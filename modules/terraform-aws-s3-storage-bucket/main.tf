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
  // template file for bucket policy
  policy_template = "${path.module}/policy-s3-notprincipal-deny.template"
}

#------------------------------------------------------------------------
# aws_s3_bucket.bucket
#------------------------------------------------------------------------
resource "aws_s3_bucket" "bucket" {
  region = "${var.region}"
  bucket = "${var.bucket_name}"
  acl    = "private"
  tags   = "${var.tags}"
  force_destroy = "${var.force_destroy}"

  # enable default AWS SSE:
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # enable versioning:
  versioning {
    enabled = true
  }

  # lifecycle rules:
  lifecycle_rule {
    id      = "log"
    enabled = true

    tags = "${var.storage_lifecycle_tags}"

    transition {
      days          = "${var.lifecycle_12}"
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = "${var.lifecycle_23}"
      storage_class = "GLACIER"
    }

  } // lifecycle

} // aws_s3_bucket.bucket

#------------------------------------------------------------------------
# data.template_file.policy
#------------------------------------------------------------------------
data "template_file" "policy" {
  template = "${file("${local.policy_template}")}"

  vars = {
    account_number = "${var.account_number}"
    iam_user       = "${var.iam_user}"
    role_name      = "${var.role_name}"
    bucket_name    = "${aws_s3_bucket.bucket.id}"
  }
}

#------------------------------------------------------------------------
# aws_s3_bucket_public_access_block.policy-block-public-access
# set policy to ensure public assess is fully blocked:
#------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "policy-block-public-access" {
  bucket = "${aws_s3_bucket.bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#------------------------------------------------------------------------
# aws_s3_bucket_policy.policy
# attach pre-written notprincipal-deny policy to bucket:
#------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "policy" {
  bucket = "${aws_s3_bucket.bucket.id}"
  policy = "${data.template_file.policy.rendered}"
}

