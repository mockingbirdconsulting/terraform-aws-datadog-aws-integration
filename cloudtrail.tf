resource "aws_cloudtrail" "dev_cloudtrail" {
    name = "${var.log_bucket_name}"
    s3_bucket_name = "${aws_s3_bucket.cloudtrail_logs.id}"
}
