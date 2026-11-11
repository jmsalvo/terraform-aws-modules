# Bootstrap: creates the S3 bucket that holds Terraform state for everything else.
# Run once by hand with LOCAL state (chicken-and-egg: the bucket can't store its own
# state before it exists). Azure equivalent: the storage account + container that
# secure-azure-platform's bootstrap creates.

# S3 bucket names are global across all AWS accounts, so add a random suffix.
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "state" {
  bucket        = "${var.name_prefix}-${random_id.suffix.hex}"
  force_destroy = var.force_destroy
}

# Versioning keeps old copies of the state file so a bad write can be recovered.
# Azure equivalent: blob versioning on the storage account.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt objects at rest. SSE-S3 (AES256) uses AWS-managed keys, like Microsoft-managed
# keys on a storage account. A customer-managed KMS key would be the stricter option.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block every form of public access. Azure equivalent: disabling public blob access
# (allow_nested_items_to_be_public = false) and restricting network access.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Refuse any request that is not over TLS. Azure equivalent: "secure transfer required".
data "aws_iam_policy_document" "tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.tls_only.json

  # The public access block and the policy both edit bucket settings; apply one at a time.
  depends_on = [aws_s3_bucket_public_access_block.state]
}
