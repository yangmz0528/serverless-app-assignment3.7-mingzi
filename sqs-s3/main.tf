locals {
  name_prefix = "mingzi"
}

# Create SQS
resource "aws_sqs_queue" "q" {
  name = "${local.name_prefix}-trigger-queue"
}
# Create the policy
data "aws_iam_policy_document" "test" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.q.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.example.arn]
    }
  }
}
# Assign the policy to SQS
resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.q.id
  policy    = data.aws_iam_policy_document.test.json
}
# Create S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "${local.name_prefix}-trigger-bucket"
}
# Create trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.example.id

  queue {
    queue_arn = aws_sqs_queue.q.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}