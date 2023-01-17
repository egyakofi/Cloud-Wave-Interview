#Create S3 bucket
resource "aws_s3_bucket" "cloudwave-bucket-198111" {
  bucket = "cloudwave-bucket-198111"
  acl    = "private"
  
}

resource "aws_s3_bucket_public_access_block" "private_bucket_block" {
  bucket = aws_s3_bucket.cloudwave-bucket-198111.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudwave-bucket-198111" {
  bucket = aws_s3_bucket.cloudwave-bucket-198111.id
  rule {
    id = "transition-to-intelligent-tiering"
    prefix = "archives/"
    transition {
      days = 1
      storage_class = "INTELLIGENT_TIERING"
    }
        status = "Enabled"
  }
  
}

resource "aws_kms_key" "cloudwave-mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket_server_side_encryption_configuration" "server-ecrypt" {
  bucket = aws_s3_bucket.cloudwave-bucket-198111.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudwave-mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
