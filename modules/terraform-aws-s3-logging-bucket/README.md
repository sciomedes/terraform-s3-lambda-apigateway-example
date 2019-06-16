# AWS S3 logging bucket module

![Storage_AmazonS3.png][Amazon S3 icon]

Terraform submodule that creates a project-level Amazon S3 bucket for logging
actions performed on the storage bucket configured by the [root module].

## Usage

```
module "s3_logging_bucket" {
  source = "git::https://github.com/sciomedes/terraform-aws-s3-logging-bucket.git"

  #------------------------------------------------------------------------
  # bucket details:
  #------------------------------------------------------------------------
  region         = "us-west-2"
  logging_bucket = "logging-bucket"

  #------------------------------------------------------------------------
  # tag resources:
  #------------------------------------------------------------------------
  tags = {
    SomeTag    = "insert value here"
    AnotherTag = "insert another value"
  }
  logging_lifecycle_tags = {
    Lifecycle   = "insert value here"
    MakeYourOwn = "tag and values"
  }

  #------------------------------------------------------------------------
  # lifecycle timescales:
  #------------------------------------------------------------------------
  # number of days before transition from S3 Standard to S3 Standard-IA
  # this number MUST be at least 30
  lifecycle_12 = 30

  # number of days before transition from S3 Standard-IA to S3 Glacier
  # this number MUST be at least 30 more than lifecycle_12
  lifecycle_23 = 90

  # expire after this many days:
  # this number MUST be greater than lifecycle_23
  lifecycle_3X = 3650  // expire after ten years

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| lifecycle\_12 | Age of object in days at which transition from S3 Standard to S3 Standard-IA should occur | string | n/a | yes |
| lifecycle\_23 | Age of object in days at which transition from S3 Standard-IA to S3 Glacier should occur | string | n/a | yes |
| lifecycle\_3X | Age of object in days at which it should expire | string | n/a | yes |
| logging\_bucket\_name | The S3 bucket to send S3 access logs. | string | n/a | yes |
| logging\_lifecycle\_tags | A mapping of tags to assign to the set of lifecycle rules. | map | `<map>` | no |
| region | Name of region containing bucket | string | n/a | yes |
| tags | A mapping of tags to assign to the bucket. | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| logging\_bucket\_arn | ARN for logging bucket |


## Description

The features of the created logging bucket coded in this module are itemized in this section.
Following each, a corresponding [AWS Command Line Interface (CLI)] command is suggested for validating
the fulfillment of the desired setting.

#### public access is blocked

```
aws s3api get-public-access-block --bucket <bucket-name>
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

#### Amazon's S3 log delivery group gets needed permissions
The log deliver group is given the needed permissions using the standard [canned ACL] `log-delivery-write`.
```
aws s3api get-bucket-acl --bucket <bucket-name>
{
    "Owner": {
        "ID": "ffc5189fc8e0d3a787150f5107cbad4b18351aff0654a2c2e2f992f930943a2f"
    },
    "Grants": [
        {
            "Grantee": {
                "ID": "ffc5189fc8e0d3a787150f5107cbad4b18351aff0654a2c2e2f992f930943a2f",
                "Type": "CanonicalUser"
            },
            "Permission": "FULL_CONTROL"
        },
        {
            "Grantee": {
                "Type": "Group",
                "URI": "http://acs.amazonaws.com/groups/s3/LogDelivery"
            },
            "Permission": "WRITE"
        },
        {
            "Grantee": {
                "Type": "Group",
                "URI": "http://acs.amazonaws.com/groups/s3/LogDelivery"
            },
            "Permission": "READ_ACP"
        }
    ]
}
```


#### encryption at rest with server-side Amazon managed keys (SSE-S3)
```bash
aws s3api get-bucket-encryption --bucket <bucket-name>
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

#### versioning is not enabled
```
aws s3api get-bucket-versioning --bucket <bucket-name>
{
    "Status": "Suspended",
    "MFADelete": "Disabled"
}
```

#### lifecycle rules are implemented
Log files will transitioned between [Amazon S3 storage classes]
  according specified lifecycle rules.  The defaults are listed in this table:

|  Cumulative age    | Storage class  |
| ----------------- :|:-------------- |
|       t < 30 days  | S3 Standard    |
| 30 <= t < 90 days  | S3 Standard-IA |
|      90 days <= t  | S3 Glacier     |

After creation, the lifecycle state can be checked using the CLI;
```
aws s3api get-bucket-lifecycle-configuration --bucket <bucket-name>
{
    "Rules": [
        {
            "Expiration": {
                "Days": 3650
            },
            "ID": "log",
            "Filter": {
                "And": {
                    "Prefix": "",
                    "Tags": [
                        {
                            "Key": "Function",
                            "Value": "lifecycle-rules"
                        },
                        {
                            "Key": "Subject",
                            "Value": "sciomedes"
                        },
                        {
                            "Key": "Region",
                            "Value": "us-east-2"
                        },
                        {
                            "Key": "OrchestratedBy",
                            "Value": "Terraform"
                        }
                    ]
                }
            },
            "Status": "Enabled",
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 90,
                    "StorageClass": "GLACIER"
                }
            ]
        }
    ]
}
```

#### custom tags can be set

```
aws s3api get-bucket-tagging --bucket <bucket-name>
{
    "TagSet": [
        {
            "Key": "Function",
            "Value": "log-storage"
        },
        {
            "Key": "OrchestratedBy",
            "Value": "Terraform"
        },
        {
            "Key": "Region",
            "Value": "us-east-2"
        },
        {
            "Key": "Subject",
            "Value": "sciomedes"
        }
    ]
}
```

## IAM permissions
We're using an S3 full-access set of permissions, though this is probably not minimal.
Many s3 permissions are needed for the terraform interactions required for bucket creation and deletion as well as
and for interacting with any objects within a bucket.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3FullAccess",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
```

## Authors

Module managed by [sciomedes].

## License

MIT License. See [LICENSE] for full details.


[Amazon S3 icon]: https://raw.githubusercontent.com/sciomedes/terraform-s3-lambda-apigateway-example/master/images/Storage_AmazonS3
[root module]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example
[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[canned ACL]: https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
[Amazon S3 storage classes]: https://aws.amazon.com/s3/storage-classes/png "Storage_AmazonS3.png"
[sciomedes]: https://github.com/sciomedes
[LICENSE]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/blob/master/modules/terraform-aws-s3-logging-bucket/LICENSE
