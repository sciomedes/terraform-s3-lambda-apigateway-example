# Use Terraform to deploy serverless API for managing AWS S3 storage

## Storage infrastructure

| module                                          | function                                  |
|-------------------------------------------------|-------------------------------------------|
| `terraform-aws-s3-logging-bucket`               | deploy a bucket dedicated to logging      |


## Usage

```
locals {
  region = "us-east-2"

  // should non-empty buckets be removed upon 'terraform destroy'
  force_destroy = true
  
  # logging bucket variables
  logging_bucket_name = "sciomedes-logging-bucket-1ecf263bd0dd5836
  logging_lifecycle_12 = 30   // 1 month
  logging_lifecycle_23 = 90   // 3 months
  logging_lifecycle_3X = 3650 // 10 years
  logging_bucket_tags = {
    Subject        = "sciomedes"
    OrchestratedBy = "Terraform"
    Function       = "log-storage"
    Region         = "${local.region}"
  }
  logging_lifecycle_tags = {
    Subject        = "sciomedes"
    OrchestratedBy = "Terraform"
    Function       = "lifecycle-rules"
    Region         = "${local.region}"
  }

}


#========================================================================
# s3 bucket for catching logs:
#========================================================================
module "s3-logging-bucket" {

  source = "https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/tree/master/modules/terraform-aws-s3-logging-bucket"

  #------------------------------------------------------------------------
  # the following settings are region-specific
  #------------------------------------------------------------------------
  region              = "${local.region}"
  logging_bucket_name = "${local.logging_bucket_name}"

  #------------------------------------------------------------------------
  # tag resource:
  #------------------------------------------------------------------------
  tags = "${local.logging_bucket_tags}"
  logging_lifecycle_tags = "${local.logging_lifecycle_tags}"

  #------------------------------------------------------------------------
  # lifecycle timescales:
  #------------------------------------------------------------------------
  # number of days before transition from S3 Standard to S3 Standard-IA
  # this number MUST be at least 30
  lifecycle_12 = "${local.logging_lifecycle_12}"

  # number of days before transition from S3 Standard-IA to S3 Glacier
  # this number MUST be at least 30 more than lifecycle_12
  lifecycle_23 = "${local.logging_lifecycle_23}"

  # expire after this many days:
  # this number MUST be greater than lifecycle_23
  lifecycle_3X = "${local.logging_lifecycle_3X}"

}
```
