# AWS CloudTrail trail module

![Amazon CloudTrail icon]

Terraform submodule that creates an AWS CloudTrail trail for writing storage bucket access logs into the logging bucket.
The storage and logging buckets are configured by the other modules called by the [root module].

## Usage

```
module "cloudtrail-s3-bucket-logging" {

  source = "github.com/sciomedes/terraform-s3-lambda-apigateway-example/modules/terraform-aws-cloudtrail-s3-bucket-logging"

  #------------------------------------------------------------------------
  # the following settings are region-specific
  #------------------------------------------------------------------------
  region              = "us-east-2"
  trail_name          = "trail_name"
  logging_bucket_name = "logging_bucket_name"
  storage_bucket_arn  = "arn:aws:s3:::storage_bucket_arn"

  #------------------------------------------------------------------------
  # tag resource:
  #------------------------------------------------------------------------
  tags = {
    SomeTag    = "insert value here"
    AnotherTag = "insert another value"
  }

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| logging\_bucket\_name | Name of S3 bucket to store logs | string | n/a | yes |
| region | AWS region to contain resources | string | n/a | yes |
| storage\_bucket\_arn | ARN of S3 bucket for which access is logged | string | n/a | yes |
| tags | A mapping of tags to assign to the trail. | map | `<map>` | no |
| trail\_name | Name of AWS CloudTrail trail | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_trail\_arn | ARN for CloudTrail trail |

## Description

The features of the created logging bucket coded in this module are itemized in this section.
Following each, a corresponding [AWS Command Line Interface (CLI)] command is suggested for validating
the fulfillment of the desired setting.

#### CloudTrail permissions for logging bucket
The CloudTrail service needs permission to write to the logging bucket.
A description of a bucket policy to accomodate this is found in the documentation page [Amazon S3 Bucket Policy for CloudTrail].
```bash
aws s3api get-bucket-policy --bucket <logging_bucket_name> | jq -rc .Policy | jq .
```
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::logging_bucket_name"
    },
    {
      "Sid": "AWSCloudTrailWrite20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::logging_bucket_name/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
```

#### custom tags can be set

```bash
aws cloudtrail list-tags --resource-id-list  arn:aws:cloudtrail:us-east-2:999999999999:trail/trail_name
```
```json
{
    "ResourceTagList": [
        {
            "ResourceId": "arn:aws:cloudtrail:us-east-2:999999999999:trail/trail_name",
            "TagsList": [
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
    ]
}
```


## IAM permissions
For now, we're using a CloudTrail full-access set of permissions, though this is almost-surely not minimal.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudTrailFullAccess",
            "Effect": "Allow",
            "Action": "cloudtrail:*",
            "Resource": "*"
        }
    ]
}
```

## Authors

Module managed by [sciomedes].

## License

MIT License. See [LICENSE] for full details.


[Amazon CloudTrail icon]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/raw/master/images/ManagementTools_AWSCloudTrail.png
[root module]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example
[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[Amazon S3 Bucket Policy for CloudTrail]: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html
[sciomedes]: https://github.com/sciomedes
[LICENSE]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/blob/master/modules/terraform-aws-cloudtrail-s3-bucket-logging/LICENSE
