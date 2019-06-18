# AWS IAM lambda role module

![Amazon IAM icon]

Terraform submodule that creates a project-level Amazon S3 bucket for logging
actions performed on the storage bucket configured by the [root module].

## Usage

```
module "iam-role-lambda" {

  source = "github.com/sciomedes/terraform-s3-lambda-apigateway-example/modules/terraform-aws-iam-lambda-role"

  #------------------------------------------------------------------------
  # bucket details:
  #------------------------------------------------------------------------
  region         = "us-east-2"
  bucket_name    = "storage_bucket_name"

  role_name = "role_name"

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
| bucket\_name | S3 storage bucket | string | n/a | yes |
| region | AWS region to contain resources | string | n/a | yes |
| role\_name | Name of role that lambda functions will use | string | n/a | yes |
| tags | A mapping of tags to assign to the role. | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | ARN for IAM role assumed by lambda function |


## Description

This role will be used by lambda functions to access the specified S3 bucket.
The ARN for the role is output.
Verify the role creation and properties from the [AWS Command Line Interface (CLI)]:
```
aws iam get-role --role-name <role_name>
{
    "Role": {
        "Path": "/",
        "RoleName": "some_role_name",
        "RoleId": "ARZVQ4D7GGPEZPEUF2YPO",
        "Arn": "arn:aws:iam::999999999999:role/docstoreAPI_lambda_function",
        "CreateDate": "2019-06-16T15:47:08Z",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        },
        "MaxSessionDuration": 3600,
        "Tags": [
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
}
```

## IAM permissions
The IAM permissions needed for a user to orchaestrate roles using Terraform are listed in the following policy.
Specific resources could be listed in the `Resource` element in order to minimalize the permissions.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "IAM",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:TagRole",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicies",
                "iam:ListPolicyVersions",
                "iam:SetDefaultPolicyVersion",
                "iam:CreatePolicy",
                "iam:CreatePolicyVersion",
                "iam:DeletePolicy",
                "iam:DeletePolicyVersion",
                "iam:ListInstanceProfilesForRole",
                "iam:AttachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:DetachRolePolicy"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

## Authors

Module managed by [sciomedes].

## License

MIT License. See [LICENSE] for full details.


[Amazon IAM icon]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/raw/master/images/SecurityIdentityCompliance_AWSIAM.png
[root module]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example
[AWS Command Line Interface (CLI)]: https://aws.amazon.com/cli/
[sciomedes]: https://github.com/sciomedes
[LICENSE]: https://github.com/sciomedes/terraform-s3-lambda-apigateway-example/blob/master/modules/terraform-aws-iam-lambda-role/LICENSE
