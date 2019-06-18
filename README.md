# Use Terraform to deploy serverless API for managing AWS S3 storage

## Storage infrastructure

| module                                          | function                                  |
|-------------------------------------------------|-------------------------------------------|
| `terraform-aws-s3-logging-bucket`               | deploy a bucket dedicated to logging      |
| `terraform-aws-s3-storage-bucket`               | create Amazon S3 storage bucket           |
| `terraform-aws-s3-cloudtrail-s3-bucket-logging` | create AWS CloudTrail trail for logging   |

## Serverless backend

| module                                          | function                                  |
|-------------------------------------------------|-------------------------------------------|
| `terraform-aws-iam-lambda-role`                 | create Lambda role for S3 bucket access   |
| `terraform-aws-lambda-function`                 | coming soon ...                           |

## API endpoints for front end

| module                                          | function                                  |
|-------------------------------------------------|-------------------------------------------|
| `terraform-aws-api-gateway`                     | coming soon ...                           |


## Usage
Replace the variable values in the `locals` block with values that make sense to your own deployment.
One way to have terraform perform the deployment is with this sequence of commands:
```bash
terraform init
terraform plan -out tf.plan
terraform apply tf.plan
```

#### errors due to eventual consistency issues
Due to 'eventual consistency' issues, one may require cycling through several `plan` and `apply` commands
before the entire deployment will complete.  Example errors that may occur in such cases include
`InsufficientS3BucketPolicyException` and `Error putting S3 policy: OperationAborted`.

```
locals {
  region = "us-east-2"

  # logging bucket variables
  logging_bucket_name = "sciomedes-logging-bucket-1ecf263bd0dd5836"
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

  # storage bucket variables
  storage_bucket_name = "sciomedes-storage-1ecf263bd0dd5836"
  storage_lifecycle_12 = 185  // 0.5 year
  storage_lifecycle_23 = 1095 // 3 years
  storage_bucket_tags = {
    Subject        = "sciomedes"
    OrchestratedBy = "Terraform"
    Function       = "data-storage"
    Region         = "${local.region}"
  }

  // should non-empty buckets be removed upon 'terraform destroy'
  // this is useful during development and testing
  logging_force_destroy = true
  storage_force_destroy = true

  # iam role variables
  role_name = "lambda_role_name"
  iam_role_tags = {
    Subject        = "sciomedes"
    OrchestratedBy = "Terraform"
    Function       = "iam-role"
    Region         = "${local.region}"
  }

  # cloudtrail specs
  trail_name = "sciomedes-1ecf263bd0dd5836"
  cloudtrail_tags = {
    Subject        = "sciomedes"
    OrchestratedBy = "Terraform"
    Function       = "cloudtrail"
    Region         = "${local.region}"
  }

  # account info used to permission storage bucket
  account_number = "999999999999"
  iam_user       = "iam_user"

}


#========================================================================
# s3 bucket for catching logs:
#========================================================================
module "s3-logging-bucket" {

  source = "github.com/sciomedes/terraform-s3-lambda-apigateway-example/modules/terraform-aws-s3-logging-bucket"

  #------------------------------------------------------------------------
  # the following settings are region-specific
  #------------------------------------------------------------------------
  region              = "${local.region}"
  logging_bucket_name = "${local.logging_bucket_name}"
  force_destroy       = "${local.logging_force_destroy}"

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

#========================================================================
# role for lambda functions:
#========================================================================
module "iam-role-lambda" {

  source = "github.com/sciomedes/terraform-s3-lambda-apigateway-example/modules/terraform-aws-iam-lambda-role"

  #------------------------------------------------------------------------
  # the following settings are bucket-specific
  #------------------------------------------------------------------------
  region         = "${local.region}"
  bucket_name    = "${local.storage_bucket_name}"

  role_name      = "${local.role_name}"

  #------------------------------------------------------------------------
  # tag resource:
  #------------------------------------------------------------------------
  tags = "${local.iam_role_tags}"

}

#========================================================================
# s3 bucket for storing data:
#========================================================================
module "s3-storage-bucket" {

  source = "github.com/sciomedes/terraform-s3-lambda-apigateway-example/modules/terraform-aws-s3-storage-bucket"

  #------------------------------------------------------------------------
  # account specific information:
  #------------------------------------------------------------------------
  account_number = "${local.account_number}"
  iam_user       = "${local.iam_user}"
  role_name      = "${local.role_name}"

  #------------------------------------------------------------------------
  # the following settings are bucket-specific
  #------------------------------------------------------------------------
  region              = "${local.region}"
  bucket_name         = "${local.storage_bucket_name}"
  force_destroy       = "${local.force_destroy}"

  #------------------------------------------------------------------------
  # tag resource:
  #------------------------------------------------------------------------
  tags = "${local.storage_bucket_tags}"

  #------------------------------------------------------------------------
  # lifecycle timescales:
  #------------------------------------------------------------------------
  # number of days before transition from S3 Standard to S3 Standard-IA
  # this number MUST be at least 30
  lifecycle_12 = "${local.storage_lifecycle_12}"

  # number of days before transition from S3 Standard-IA to S3 Glacier
  # this number MUST be at least 30 more than lifecycle_12
  lifecycle_23 = "${local.storage_lifecycle_23}"

}

#========================================================================
# s3 bucket for catching logs:
#========================================================================
module "cloudtrail-s3-bucket-logging" {

  source = "./modules/terraform-aws-cloudtrail-s3-bucket-logging"

  #------------------------------------------------------------------------
  # the following settings are region-specific
  #------------------------------------------------------------------------
  region              = "${local.region}"
  trail_name          = "${local.trail_name}"
  storage_bucket_name = "${local.storage_bucket_name}"
  logging_bucket_name = "${local.logging_bucket_name}"

  #------------------------------------------------------------------------
  # tag resource:
  #------------------------------------------------------------------------
  tags = "${local.cloudtrail_tags}"

}
```

## Authors

Module managed by [sciomedes](https://github.com/sciomedes).

## License

MIT License. See [LICENSE](LICENSE) for full details.


[sciomedes]: https://github.com/sciomedes
[LICENSE]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/LICENSE
