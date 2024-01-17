resource "aws_s3_bucket" "app-image-bucket" {
  bucket = var.app_image_bucket_name
}

resource "aws_s3_bucket_public_access_block" "app-image-bucket-public-access-block" {
  bucket                  = aws_s3_bucket.app-image-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_policy" "app-image-bucket-policy" {
  bucket = aws_s3_bucket.app-image-bucket.id
  policy = jsonencode(
    {

      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "${aws_s3_bucket.app-image-bucket.arn}/*"
        }
      ]

    }
  )
  depends_on = [aws_s3_bucket.app-image-bucket]
}
