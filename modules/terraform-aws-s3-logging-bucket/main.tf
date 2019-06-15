#------------------------------------------------------------------------
# aws provider specifying region
#------------------------------------------------------------------------
provider "aws" {
  region = "${var.region}"
}


#------------------------------------------------------------------------
# aws_s3_bucket.logging_bucket
# specify which bucket will receive access logs
#------------------------------------------------------------------------
resource "aws_s3_bucket" "logging_bucket" {
  region = "${var.region}"
  bucket = "${var.logging_bucket_name}"
  acl    = "log-delivery-write"      # canned ACL

  # enable default AWS SSE:
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # tag bucket:
  tags = "${var.tags}"

  # disable versioning:
  versioning {
    enabled = false
  }

  # lifecycle rules:
  lifecycle_rule {
    id      = "log"
    enabled = true

    tags = "${var.logging_lifecycle_tags}"

    transition {
      days          = "${var.lifecycle_12}"
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = "${var.lifecycle_23}"
      storage_class = "GLACIER"
    }

    expiration {
      days          = "${var.lifecycle_3X}"
    }
  } // lifecycle

} // aws_s3_bucket.logging_bucket


#------------------------------------------------------------------------
# aws_s3_bucket_public_access_block.policy-block-public-access
# set policy to ensure public assess is fully blocked
#------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "policy-block-public-access" {
  bucket = "${aws_s3_bucket.logging_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
