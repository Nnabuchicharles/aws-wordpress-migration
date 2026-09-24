resource "aws_s3_bucket" "migration_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = { Name = var.bucket_name }
}

resource "aws_s3_bucket_public_access_block" "migration_bucket_block" {
  bucket = aws_s3_bucket.migration_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

