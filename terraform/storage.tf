//#----- symbiosis/storage.tf -----#
//
//resource "aws_s3_bucket" "symbiosis-bucket" {
//  bucket        = "symbiosis-bucket"
//  force_destroy = true
//
//  versioning {
//    enabled = true
//  }
//
//  tags = {
//    Name        = "symbiosis-bucket"
//  }
//}
//
//resource "aws_s3_bucket_policy" "symbiosis-bucket-policy" {
//  bucket = aws_s3_bucket.symbiosis-bucket.id
//  policy = data.aws_iam_policy_document.symbiosis-bucket-policy.json
//}
//
//data "aws_iam_policy_document" "symbiosis-bucket-policy" {
//  statement {
//    actions   = ["s3:GetObject"]
//    resources = ["${aws_s3_bucket.symbiosis-bucket.arn}/*"]
//
//    principals {
//      type        = "AWS"
//      identifiers = ["*"]
//    }
//  }
//}
//
