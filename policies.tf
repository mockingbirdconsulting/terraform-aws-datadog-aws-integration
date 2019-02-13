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

resource "aws_s3_bucket_policy" "datadog_log_read_cloudtrail" {
  bucket = "${var.log_bucket_name}"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::${var.current_account_id}:role/${aws_iam_role.datadog_log_lambda_role.name}"
            ]
        },
        "Action": [
            "s3:*"
        ],
        "Resource": [
            "arn:aws:s3:::${var.log_bucket_name}",
            "arn:aws:s3:::${var.log_bucket_name}/*"
        ]
    }
  ]
}
EOF
}
