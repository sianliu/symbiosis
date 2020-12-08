#----- symbiosis/storage.tf -----#

resource "aws_s3_bucket" "symbiosis-lb-access-logs-bucket" {
  bucket        = "symbiosis-lb-access-logs-bucket"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name = "terraform-lb-access-logs-bucket"
  }
}

resource "aws_s3_bucket_policy" "symbiosis-bucket-policy" {
  bucket = aws_s3_bucket.symbiosis-lb-access-logs-bucket.id
  policy = data.aws_iam_policy_document.symbiosis-bucket-policy.json
}

data "aws_iam_policy_document" "symbiosis-bucket-policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.symbiosis-lb-access-logs-bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

