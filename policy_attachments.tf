resource "aws_iam_policy_attachment" "attach_datadog_policy" {
  name       = "DataDog_integration_role_policy"
  roles      = ["${aws_iam_role.datadog.name}"]
  policy_arn = "${aws_iam_policy.datadog.arn}"
}

resource "aws_iam_policy_attachment" "attach_datadog_logging_policy" {
  name       = "DataDog_logging_integration_role_policy"
  roles      = ["${aws_iam_role.datadog_log_lambda_role.name}"]
  policy_arn = "${aws_iam_policy.datadog_log_lambda_policy.arn}"
}

