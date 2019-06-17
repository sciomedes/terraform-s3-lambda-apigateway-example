# AWS S3 storage bucket module

![Amazon S3 icon]

Terraform submodule that creates a project-level Amazon S3 bucket for data storage
as configured by the [root module].
Access to the bucket is restricted to the bucket owner and a specific defined role.

## Usage

```
module "s3-storage-bucket" {

  source = "git::https://github.com/sciomedes/terraform-aws-s3-storage-bucket.git"

  #------------------------------------------------------------------------
  # account specific information:
  #------------------------------------------------------------------------
  account_number = "999999999999"
  iam_user       = "user_name"
  role_name      = "lambda_role_name"

  #------------------------------------------------------------------------
  # the following settings are bucket-specific
  #------------------------------------------------------------------------
  region              = "us-east-2"
  bucket_name         = "storage_bucket_name"
  
  #------------------------------------------------------------------------
  # tag resource:
  #------------------------------------------------------------------------
  tags = {
    SomeTag    = "insert value here"
    AnotherTag = "insert another value"
  }

  #------------------------------------------------------------------------
  # lifecycle timescales:
  #------------------------------------------------------------------------
  # number of days before transition from S3 Standard to S3 Standard-IA
  # this number MUST be at least 30
  lifecycle_12 = 30

  # number of days before transition from S3 Standard-IA to S3 Glacier
  # this number MUST be at least 30 more than lifecycle_12
  lifecycle_23 = 365

}
```

## Description
The S3 storage bucket settings are described next.
These settings can be checked using the [AWS Command Line Interface (CLI)].


#### public access is blocked

```bash
aws s3api get-public-access-block --bucket <bucket-name>
```
```json
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

#### permissions are restricted to the bucket owner and a specific role
The lambda functions will use the specified role to access the bucket.
```bash
aws s3api get-bucket-policy --bucket <bucket-name> | jq -rc .Policy | jq .
```
```json
{
  "Version": "2012-10-17",
  "Id": "Policy1556373503472",
  "Statement": [
    {
      "Sid": "S3BucketFullAccessUserOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::999999999999:role/lambda_role_name",
          "arn:aws:iam::999999999999:user/user_name",
          "arn:aws:iam::999999999999:root"
        ]
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::storage_bucket_name",
        "arn:aws:s3:::storage_bucket_name/*"
      ]
    }
  ]
}
```

#### encryption at rest with server-side Amazon managed keys (SSE-S3)
```bash
aws s3api get-bucket-encryption --bucket <bucket-name>
```
```json
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }
}
```

#### versioning is enabled
```bash
aws s3api get-bucket-versioning --bucket <bucket-name>
```
```json
{
    "Status": "Enabled",
    "MFADelete": "Disabled"
}
```

#### lifecycle rules are implemented
Log files will transitioned between [Amazon S3 storage classes]
according to specified lifecycle rules.  The transitions suggested
by the above example settings are shown in this table:

|  Cumulative age     | Storage class  |
|--------------------:|:---------------|
|       t < 30 days   | S3 Standard    |
| 30 <= t < 365 days  | S3 Standard-IA |
|      365 days <= t  | S3 Glacier     |

```bash
aws s3api get-bucket-lifecycle-configuration --bucket <bucket-name>
```
```json
{
    "Rules": [
        {
            "ID": "log",
            "Filter": {
                "Prefix": "log/"
            },
            "Status": "Enabled",
            "Transitions": [
                {
                    "Days": 185,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 1095,
                    "StorageClass": "GLACIER"
                }
            ]
        }
    ]
}
```

#### custom tags can be set

```bash
aws s3api get-bucket-tagging --bucket <bucket-name>
```
```json
{
    "TagSet": [
        {
            "Key": "SomeTag",
            "Value": "insert value here"
        },
        {
            "Key": "AnotherTag",
            "Value": "insert another value"
        }
    ]
}
```

## IAM permissions
We're using the same S3 full-access set of permissions described and used in the [terraform-aws-s3-logging-bucket module].

## Authors

Module managed by [sciomedes](https://github.com/sciomedes).

## License

MIT License. See [LICENSE](LICENSE) for full details.


[Amazon S3 icon]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/raw/master/images/Storage_AmazonS3.png
[root module]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example
[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[Amazon S3 storage classes]: https://aws.amazon.com/s3/storage-classes/
[terraform-aws-s3-logging-bucket module]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/tree/master/modules/terraform-aws-s3-logging-bucket
[sciomedes]: https://github.com/sciomedes
[LICENSE]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/blob/master/modules/terraform-aws-s3-logging-bucket/LICENSE
