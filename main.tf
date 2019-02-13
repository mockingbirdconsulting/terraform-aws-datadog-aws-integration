resource "aws_iam_role" "datadog" {
  name = "DataDogIntegration"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::464622532012:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.datadog_aws_external_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "datadog" {
  name        = "DataDogIntegration"
  description = "Access for DataDog to the AWS API"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "budgets:ViewBudget",
                "cloudfront:GetDistributionConfig",
                "cloudfront:ListDistributions",
                "cloudtrail:DescribeTrails",
                "cloudtrail:GetTrailStatus",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "cloudwatch:List*",
                "codedeploy:List*",
                "codedeploy:BatchGet*",
                "directconnect:Describe*",
                "dynamodb:List*",
                "dynamodb:Describe*",
                "ec2:Describe*",
                "ecs:Describe*",
                "ecs:List*",
                "elasticache:Describe*",
                "elasticache:List*",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeTags",
                "elasticloadbalancing:Describe*",
                "elasticmapreduce:List*",
                "elasticmapreduce:Describe*",
                "es:ListTags",
                "es:ListDomainNames",
                "es:DescribeElasticsearchDomains",
                "health:describeEvents",
                "health:describeEventDetails",
                "health:describeAffectedEntities",
                "kinesis:List*",
                "kinesis:Describe*",
                "lambda:AddPermission",
                "lambda:GetPolicy",
                "lambda:List*",
                "lambda:RemovePermission",
                "logs:Get*",
                "logs:Describe*",
                "logs:FilterLogEvents",
                "logs:TestMetricFilter",
                "logs:PutSubscriptionFilter",
                "logs:DeleteSubscriptionFilter",
                "logs:DescribeSubscriptionFilters",
                "rds:Describe*",
                "rds:List*",
                "redshift:DescribeClusters",
                "redshift:DescribeLoggingStatus",
                "route53:List*",
                "s3:GetBucketLogging",
                "s3:GetBucketLocation",
                "s3:GetBucketNotification",
                "s3:GetBucketTagging",
                "s3:ListAllMyBuckets",
                "s3:PutBucketNotification",
                "ses:Get*",
                "sns:List*",
                "sns:Publish",
                "sqs:ListQueues",
                "support:*",
                "tag:GetResources",
                "tag:GetTagKeys",
                "tag:GetTagValues"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_datadog_policy" {
  name       = "DataDog_integration_role_policy"
  roles      = ["${aws_iam_role.datadog.name}"]
  policy_arn = "${aws_iam_policy.datadog.arn}"
}

resource "aws_kms_key" "datadog_api_key" {
  description             = "Dedicated MKS Key for DataDog"
  deletion_window_in_days = 10
  enable_key_rotation    = true
}

resource "aws_kms_alias" "datadog_api_key_alias" {
  name          = "alias/datadog_api_key"
  target_key_id = "${aws_kms_key.datadog_api_key.key_id}"
}

resource "aws_iam_role" "datadog_lambda_kms_grant_role" {
  name = "datadog-lambda-kms-grant"

  assume_role_policy = <<EOF
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

resource "aws_kms_grant" "datadog_kms_lambda_grant" {
  name              = "datadog-kms-lambda-grant"
  key_id            = "${aws_kms_key.datadog_api_key.key_id}"
  grantee_principal = "${aws_iam_role.datadog_lambda_kms_grant_role.arn}"
  operations        = ["Decrypt"]
}

resource "aws_iam_role" "datadog_log_lambda_role" {
  name = "datadog_logging_lambda"
  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "datadog_log_lambda_policy" {
  name = "datadog_logging_policy"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "logs:CreateLogGroup",
               "logs:CreateLogStream",
               "logs:PutLogEvents"
           ],
           "Resource":"arn:aws:logs:*:*:*"
       },
       {
            "Effect": "Allow",
            "Action": [
              "kms:Decrypt"
            ],
            "Resource": [
              "${aws_kms_key.datadog_api_key.arn}"
            ]
          }
   ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_datadog_logging_policy" {
  name       = "DataDog_logging_integration_role_policy"
  roles      = ["${aws_iam_role.datadog_log_lambda_role.name}"]
  policy_arn = "${aws_iam_policy.datadog_log_lambda_policy.arn}"
}


resource "aws_lambda_function" "datadog_logging_lambda" {
  filename         = "../artefacts/aws-logs-monitoring.zip"
  function_name    = "datadog_aws_log_ingestion"
  role             = "${aws_iam_role.datadog_log_lambda_role.arn}"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = "${base64sha256(file("../artefacts/aws-logs-monitoring.zip"))}"
  runtime          = "python2.7"
  kms_key_arn      = "${aws_kms_key.datadog_api_key.arn}"

  environment {
    variables = {
      DD_KMS_API_KEY = "${var.dd_logging_kms_encrypted_keys}"
    }
  }
}
