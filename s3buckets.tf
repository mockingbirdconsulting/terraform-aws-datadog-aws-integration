resource "aws_s3_bucket" "cloudtrail_logs" {
    bucket = "${var.log_bucket_name}"
    force_destroy = true
}
