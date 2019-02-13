resource "aws_kms_key" "datadog_api_key" {
  description             = "Dedicated MKS Key for DataDog"
  deletion_window_in_days = 10
  enable_key_rotation    = true
}

resource "aws_kms_alias" "datadog_api_key_alias" {
  name          = "alias/datadog_api_key"
  target_key_id = "${aws_kms_key.datadog_api_key.key_id}"
}

resource "aws_kms_grant" "datadog_kms_lambda_grant" {
  name              = "datadog-kms-lambda-grant"
  key_id            = "${aws_kms_key.datadog_api_key.key_id}"
  grantee_principal = "${aws_iam_role.datadog_lambda_kms_grant_role.arn}"
  operations        = ["Decrypt"]
}
