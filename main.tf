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
