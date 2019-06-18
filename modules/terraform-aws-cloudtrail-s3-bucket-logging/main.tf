#------------------------------------------------------------------------
# aws provider specifying region
#------------------------------------------------------------------------
provider "aws" {
  region = "${var.region}"
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.trail_name}"
  s3_bucket_name                = "${var.logging_bucket_name}"
  tags                          = "${var.tags}"
  include_global_service_events = false

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = ["${var.storage_bucket_arn}/"]
    }
  }

}
